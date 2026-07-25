import logging
import uuid
from datetime import datetime, timedelta, timezone
from typing import Annotated

from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy import select
from sqlalchemy.exc import IntegrityError
from sqlalchemy.ext.asyncio import AsyncSession

from sqlalchemy.orm import joinedload

from app.core.auth.dependencies import ClinicContext, get_clinic_context, require_permission
from app.core.auth.models import Clinic, ClinicMembership, User
from app.core.auth.service import hash_password
from app.core.email import EmailMessage, email_service
from app.database import get_db

from .constants import PLATFORM_ADMIN_CLINIC_NAME, is_platform_clinic
from .models import SaasLead, SaasPricingPlan, SaasSubscription
from .schemas import (
    ClinicDirectoryResponse,
    LeadCreate,
    LeadResponse,
    LeadStatusUpdate,
    PricingPlanCreate,
    PricingPlanResponse,
    PricingPlanUpdate,
    SubscriptionCreate,
    SubscriptionResponse,
    TenantProvisionRequest,
    TenantProvisionResponse,
)

logger = logging.getLogger(__name__)
router = APIRouter(tags=["saas"])


def _subscription_to_response(sub: SaasSubscription, *, now: datetime | None = None) -> SubscriptionResponse:
    """Derive `effective_status` from start/end vs. now.

    The stored `status` column is written as "active" at creation time
    regardless of whether the subscription is live yet (a stacked renewal
    starts in the future), so callers that need "is this actually active
    right now" must use this instead of the raw column.
    """
    now = now or datetime.now(timezone.utc)
    if sub.end_date <= now:
        effective_status = "expired"
    elif sub.start_date > now:
        effective_status = "upcoming"
    else:
        effective_status = "active"

    return SubscriptionResponse(
        id=sub.id,
        clinic_id=sub.clinic_id,
        start_date=sub.start_date,
        end_date=sub.end_date,
        status=sub.status,
        effective_status=effective_status,
        plan_id=sub.plan_id,
        plan=sub.plan,
        created_at=sub.created_at,
        updated_at=sub.updated_at,
    )


async def _notify_superadmins_of_lead(db: AsyncSession, lead: SaasLead) -> None:
    """Best-effort email to every platform-admin user about a new lead.

    Must never raise — a misconfigured SMTP provider (or none configured
    at all, which is the default) must not block lead submission for the
    public, unauthenticated landing page.
    """
    try:
        result = await db.execute(
            select(User.email)
            .join(ClinicMembership, ClinicMembership.user_id == User.id)
            .join(Clinic, Clinic.id == ClinicMembership.clinic_id)
            .where(Clinic.name == PLATFORM_ADMIN_CLINIC_NAME, User.is_active.is_(True))
        )
        recipient_emails = [row[0] for row in result.all()]
        if not recipient_emails:
            logger.warning("New SaaS lead submitted but no active platform-admin user exists to notify")
            return

        body_html = (
            "<p>A new lead was submitted via the landing page.</p>"
            "<ul>"
            f"<li><strong>Contact:</strong> {lead.contact_name}</li>"
            f"<li><strong>Clinic:</strong> {lead.clinic_name}</li>"
            f"<li><strong>Email:</strong> {lead.email}</li>"
            f"<li><strong>Phone:</strong> {lead.phone or '—'}</li>"
            f"<li><strong>Expected users:</strong> {lead.expected_users or '—'}</li>"
            "</ul>"
        )
        for to_email in recipient_emails:
            await email_service.send(
                EmailMessage(
                    to_email=to_email,
                    subject=f"New SaaS lead: {lead.clinic_name}",
                    body_html=body_html,
                )
            )
    except Exception:
        logger.exception("Failed to send lead notification email for lead %s", lead.id)


@router.post("/leads", response_model=LeadResponse, status_code=status.HTTP_201_CREATED)
async def create_lead(
    lead_in: LeadCreate,
    db: Annotated[AsyncSession, Depends(get_db)],
):
    """Submit a new lead from the public landing page (Unauthenticated)."""
    db_lead = SaasLead(
        id=uuid.uuid4(),
        contact_name=lead_in.contact_name,
        clinic_name=lead_in.clinic_name,
        phone=lead_in.phone,
        email=lead_in.email,
        expected_users=lead_in.expected_users,
        message=lead_in.message,
        status="pending",
    )
    db.add(db_lead)
    await db.commit()
    await db.refresh(db_lead)

    await _notify_superadmins_of_lead(db, db_lead)

    return db_lead


@router.get("/leads", response_model=list[LeadResponse])
async def list_leads(
    ctx: Annotated[ClinicContext, Depends(get_clinic_context)],
    _: Annotated[None, Depends(require_permission("leads.read"))],
    db: Annotated[AsyncSession, Depends(get_db)],
):
    """Superadmin: List all leads."""
    if not is_platform_clinic(ctx.clinic.name):
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Platform administrators only")
        
    result = await db.execute(select(SaasLead).order_by(SaasLead.created_at.desc()))
    return result.scalars().all()


@router.patch("/leads/{lead_id}", response_model=LeadResponse)
async def update_lead_status(
    lead_id: uuid.UUID,
    payload: LeadStatusUpdate,
    ctx: Annotated[ClinicContext, Depends(get_clinic_context)],
    _: Annotated[None, Depends(require_permission("leads.write"))],
    db: Annotated[AsyncSession, Depends(get_db)],
):
    """Superadmin: Mark a lead as contacted/processed/rejected."""
    if not is_platform_clinic(ctx.clinic.name):
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Platform administrators only")

    result = await db.execute(select(SaasLead).where(SaasLead.id == lead_id))
    lead = result.scalar_one_or_none()
    if not lead:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Lead not found")

    lead.status = payload.status
    await db.commit()
    await db.refresh(lead)
    return lead


@router.post("/clinics/provision", response_model=TenantProvisionResponse)
async def provision_tenant(
    req: TenantProvisionRequest,
    ctx: Annotated[ClinicContext, Depends(get_clinic_context)],
    _: Annotated[None, Depends(require_permission("subscriptions.write"))],
    db: Annotated[AsyncSession, Depends(get_db)],
):
    """Superadmin: Provision a new clinic tenant."""
    if not is_platform_clinic(ctx.clinic.name):
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Platform administrators only")

    # Check if email exists
    email_check = await db.execute(select(User).where(User.email == req.admin_email))
    if email_check.scalar_one_or_none():
        raise HTTPException(status_code=400, detail="User with this email already exists")

    # Create Clinic
    clinic = Clinic(
        id=uuid.uuid4(),
        name=req.clinic_name,
        tax_id=req.tax_id,
        timezone=req.timezone,
        currency=req.currency,
        settings={},
    )
    db.add(clinic)

    # Create Admin User
    user = User(
        id=uuid.uuid4(),
        email=req.admin_email,
        password_hash=hash_password(req.admin_password),
        first_name=req.admin_first_name,
        last_name=req.admin_last_name,
        is_active=True,
    )
    db.add(user)
    await db.flush()

    # Create Membership
    membership = ClinicMembership(
        id=uuid.uuid4(),
        user_id=user.id,
        clinic_id=clinic.id,
        role="admin",
    )
    db.add(membership)

    try:
        await db.commit()
    except IntegrityError:
        await db.rollback()
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="A clinic or user with these details already exists",
        ) from None

    return TenantProvisionResponse(
        clinic_id=clinic.id,
        clinic_name=clinic.name,
        admin_user_id=user.id,
        admin_email=user.email,
    )


@router.get("/clinics", response_model=list[ClinicDirectoryResponse])
async def list_clinics(
    ctx: Annotated[ClinicContext, Depends(get_clinic_context)],
    _: Annotated[None, Depends(require_permission("subscriptions.read"))],
    db: Annotated[AsyncSession, Depends(get_db)],
):
    """Superadmin: directory of every provisioned clinic with subscription status.

    Platform administrators only — a clinic listing everyone else's
    tenants would violate multi-tenancy for non-admin roles.
    """
    if not is_platform_clinic(ctx.clinic.name):
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Platform administrators only")

    now = datetime.now(timezone.utc)
    result = await db.execute(
        select(Clinic).where(Clinic.name != PLATFORM_ADMIN_CLINIC_NAME).order_by(Clinic.created_at.desc())
    )
    clinics = result.scalars().all()

    directory: list[ClinicDirectoryResponse] = []
    for clinic in clinics:
        subs_result = await db.execute(
            select(SaasSubscription)
            .where(SaasSubscription.clinic_id == clinic.id)
            .order_by(SaasSubscription.end_date.desc())
        )
        subs = subs_result.scalars().all()
        latest = subs[0] if subs else None
        directory.append(
            ClinicDirectoryResponse(
                id=clinic.id,
                name=clinic.name,
                tax_id=clinic.tax_id,
                created_at=clinic.created_at,
                subscription_active=bool(latest and latest.end_date > now),
                subscription_end_date=latest.end_date if latest else None,
                subscription_count=len(subs),
            )
        )
    return directory


@router.get("/plans", response_model=list[PricingPlanResponse])
async def list_pricing_plans(
    db: Annotated[AsyncSession, Depends(get_db)],
    include_inactive: bool = False,
):
    """Public/Admin: List pricing plans (shown on the public landing page)."""
    query = select(SaasPricingPlan)
    if not include_inactive:
        query = query.where(SaasPricingPlan.is_active.is_(True))
    result = await db.execute(query)
    return result.scalars().all()


@router.post("/plans", response_model=PricingPlanResponse)
async def create_pricing_plan(
    plan: PricingPlanCreate,
    ctx: Annotated[ClinicContext, Depends(get_clinic_context)],
    _: Annotated[None, Depends(require_permission("subscriptions.write"))],
    db: Annotated[AsyncSession, Depends(get_db)],
):
    """Superadmin: Create a new pricing plan."""
    if not is_platform_clinic(ctx.clinic.name):
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Platform administrators only")

    db_plan = SaasPricingPlan(
        id=uuid.uuid4(),
        name=plan.name,
        duration_months=plan.duration_months,
        price=plan.price,
        is_active=plan.is_active,
    )
    db.add(db_plan)
    await db.commit()
    await db.refresh(db_plan)
    return db_plan


@router.patch("/plans/{plan_id}", response_model=PricingPlanResponse)
async def update_pricing_plan(
    plan_id: uuid.UUID,
    payload: PricingPlanUpdate,
    ctx: Annotated[ClinicContext, Depends(get_clinic_context)],
    _: Annotated[None, Depends(require_permission("subscriptions.write"))],
    db: Annotated[AsyncSession, Depends(get_db)],
):
    """Superadmin: Edit a pricing plan, or retire it via `is_active=false`."""
    if not is_platform_clinic(ctx.clinic.name):
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Platform administrators only")

    result = await db.execute(select(SaasPricingPlan).where(SaasPricingPlan.id == plan_id))
    plan = result.scalar_one_or_none()
    if not plan:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Pricing plan not found")

    for field, value in payload.model_dump(exclude_unset=True).items():
        setattr(plan, field, value)

    await db.commit()
    await db.refresh(plan)
    return plan


@router.get("/subscriptions", response_model=list[SubscriptionResponse])
async def list_subscriptions(
    ctx: Annotated[ClinicContext, Depends(get_clinic_context)],
    _: Annotated[None, Depends(require_permission("subscriptions.read"))],
    db: Annotated[AsyncSession, Depends(get_db)],
    filter_clinic_id: Annotated[uuid.UUID | None, Query()] = None,
):
    """List subscriptions.

    Platform admins see everything, optionally filtered to one clinic via
    `?clinic_id=` (used by the clinic directory's history view). Regular
    clinic members always see only their own clinic's history — a
    client-supplied `clinic_id` is ignored for them rather than trusted,
    per the multi-tenancy rule.
    """
    if is_platform_clinic(ctx.clinic.name):
        query = select(SaasSubscription).options(joinedload(SaasSubscription.plan))
        if filter_clinic_id is not None:
            query = query.where(SaasSubscription.clinic_id == filter_clinic_id)
    else:
        query = select(SaasSubscription).options(joinedload(SaasSubscription.plan)).where(SaasSubscription.clinic_id == ctx.clinic_id)

    result = await db.execute(query.order_by(SaasSubscription.end_date.desc()))
    now = datetime.now(timezone.utc)
    return [_subscription_to_response(sub, now=now) for sub in result.scalars().all()]


@router.post("/subscriptions", response_model=SubscriptionResponse)
async def grant_subscription(
    req: SubscriptionCreate,
    ctx: Annotated[ClinicContext, Depends(get_clinic_context)],
    _: Annotated[None, Depends(require_permission("subscriptions.write"))],
    db: Annotated[AsyncSession, Depends(get_db)],
):
    """Superadmin: Grant or renew a subscription for a clinic (Stacking Logic)."""
    if not is_platform_clinic(ctx.clinic.name):
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Platform administrators only")

    clinic_result = await db.execute(select(Clinic).where(Clinic.id == req.clinic_id))
    if not clinic_result.scalar_one_or_none():
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Clinic not found")

    # Find current active subscription to handle stacking
    now = datetime.now(timezone.utc)
    current_sub_result = await db.execute(
        select(SaasSubscription)
        .where(SaasSubscription.clinic_id == req.clinic_id, SaasSubscription.end_date > now)
        .order_by(SaasSubscription.end_date.desc())
        .limit(1)
    )
    current_sub = current_sub_result.scalar_one_or_none()

    start_date = current_sub.end_date if current_sub else now

    import calendar
    month = start_date.month - 1 + req.duration_months
    year = start_date.year + month // 12
    month = month % 12 + 1
    day = min(start_date.day, calendar.monthrange(year, month)[1])
    end_date = start_date.replace(year=year, month=month, day=day)

    db_sub = SaasSubscription(
        id=uuid.uuid4(),
        clinic_id=req.clinic_id,
        plan_id=req.plan_id,
        start_date=start_date,
        end_date=end_date,
        status="active",
    )
    db.add(db_sub)
    await db.commit()
    
    result = await db.execute(
        select(SaasSubscription)
        .options(joinedload(SaasSubscription.plan))
        .where(SaasSubscription.id == db_sub.id)
    )
    db_sub = result.scalar_one()
    
    return _subscription_to_response(db_sub, now=now)
