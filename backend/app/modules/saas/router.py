import logging
import uuid
from datetime import UTC, datetime
from typing import Annotated

from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy import select, text
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
    ClinicAdminInfo,
    ClinicDirectoryResponse,
    ClinicStatsResponse,
    ClinicUpdate,
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


def _subscription_to_response(
    sub: SaasSubscription, *, now: datetime | None = None
) -> SubscriptionResponse:
    """Derive `effective_status` from start/end vs. now.

    The stored `status` column is written as "active" at creation time
    regardless of whether the subscription is live yet (a stacked renewal
    starts in the future), so callers that need "is this actually active
    right now" must use this instead of the raw column.
    """
    now = now or datetime.now(UTC)
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
            logger.warning(
                "New SaaS lead submitted but no active platform-admin user exists to notify"
            )
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
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN, detail="Platform administrators only"
        )

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
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN, detail="Platform administrators only"
        )

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
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN, detail="Platform administrators only"
        )

    # Check if email exists
    email_check = await db.execute(select(User).where(User.email == req.admin_email))
    if email_check.scalar_one_or_none():
        raise HTTPException(status_code=400, detail="User with this email already exists")

    # Create Clinic
    initial_settings = {}
    if req.logo_url or req.primary_color or req.theme_preset:
        initial_settings = {
            "logo_url": req.logo_url,
            "primary_color": req.primary_color or "#0284c7",
            "theme_preset": req.theme_preset or "ocean_blue",
            "branding": {
                "logo_url": req.logo_url,
                "primary_color": req.primary_color or "#0284c7",
                "theme_preset": req.theme_preset or "ocean_blue",
            },
        }

    clinic = Clinic(
        id=uuid.uuid4(),
        name=req.clinic_name,
        tax_id=req.tax_id,
        timezone=req.timezone,
        currency=req.currency,
        settings=initial_settings,
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

    # Automatically seed standard catalog (categories, treatments, VAT types)
    try:
        from app.modules.catalog.seed import seed_catalog

        await seed_catalog(db, clinic.id)
        await db.commit()
    except Exception as exc:
        logger.warning("Could not auto-seed catalog for clinic %s: %s", clinic.id, exc)

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
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN, detail="Platform administrators only"
        )

    now = datetime.now(UTC)
    result = await db.execute(
        select(Clinic)
        .where(Clinic.name != PLATFORM_ADMIN_CLINIC_NAME)
        .order_by(Clinic.created_at.desc())
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
        c_settings = clinic.settings or {}
        c_branding = c_settings.get("branding") or {}
        directory.append(
            ClinicDirectoryResponse(
                id=clinic.id,
                name=clinic.name,
                tax_id=clinic.tax_id,
                created_at=clinic.created_at,
                subscription_active=bool(latest and latest.end_date > now),
                subscription_end_date=latest.end_date if latest else None,
                subscription_count=len(subs),
                logo_url=c_branding.get("logo_url") or c_settings.get("logo_url"),
                primary_color=c_branding.get("primary_color") or c_settings.get("primary_color") or "#0284c7",
                theme_preset=c_branding.get("theme_preset") or c_settings.get("theme_preset") or "ocean_blue",
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
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN, detail="Platform administrators only"
        )

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
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN, detail="Platform administrators only"
        )

    result = await db.execute(select(SaasPricingPlan).where(SaasPricingPlan.id == plan_id))
    plan = result.scalar_one_or_none()
    if not plan:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Pricing plan not found")

    for field, value in payload.model_dump(exclude_unset=True).items():
        setattr(plan, field, value)

    await db.commit()
    await db.refresh(plan)
    return plan


@router.delete("/plans/{plan_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_pricing_plan(
    plan_id: uuid.UUID,
    ctx: Annotated[ClinicContext, Depends(get_clinic_context)],
    _: Annotated[None, Depends(require_permission("subscriptions.write"))],
    db: Annotated[AsyncSession, Depends(get_db)],
):
    """Superadmin: Delete a pricing plan."""
    if not is_platform_clinic(ctx.clinic.name):
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN, detail="Platform administrators only"
        )

    result = await db.execute(select(SaasPricingPlan).where(SaasPricingPlan.id == plan_id))
    plan = result.scalar_one_or_none()
    if not plan:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Pricing plan not found")

    await db.delete(plan)
    await db.commit()
    return None


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
        query = (
            select(SaasSubscription)
            .options(joinedload(SaasSubscription.plan))
            .where(SaasSubscription.clinic_id == ctx.clinic_id)
        )

    result = await db.execute(query.order_by(SaasSubscription.end_date.desc()))
    now = datetime.now(UTC)
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
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN, detail="Platform administrators only"
        )

    clinic_result = await db.execute(select(Clinic).where(Clinic.id == req.clinic_id))
    if not clinic_result.scalar_one_or_none():
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Clinic not found")

    # Find current active subscription to handle stacking
    now = datetime.now(UTC)
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


@router.patch("/clinics/{target_clinic_id}", response_model=ClinicDirectoryResponse)
async def update_clinic(
    target_clinic_id: uuid.UUID,
    payload: ClinicUpdate,
    ctx: Annotated[ClinicContext, Depends(get_clinic_context)],
    _: Annotated[None, Depends(require_permission("subscriptions.write"))],
    db: Annotated[AsyncSession, Depends(get_db)],
):
    """Superadmin: Update a clinic's core details."""
    if not is_platform_clinic(ctx.clinic.name):
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN, detail="Platform administrators only"
        )
    if target_clinic_id == ctx.clinic_id:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST, detail="Cannot modify the platform admin clinic"
        )

    result = await db.execute(select(Clinic).where(Clinic.id == target_clinic_id))
    clinic = result.scalar_one_or_none()
    if not clinic:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Clinic not found")

    settings = dict(clinic.settings or {})
    branding = dict(settings.get("branding") or {})
    for field, value in payload.model_dump(exclude_unset=True).items():
        if field in ("logo_url", "primary_color", "theme_preset"):
            branding[field] = value
            settings[field] = value
        elif hasattr(clinic, field):
            setattr(clinic, field, value)
    settings["branding"] = branding
    clinic.settings = settings

    await db.commit()
    await db.refresh(clinic)

    # Re-fetch subscription info for the response
    subs_result = await db.execute(
        select(SaasSubscription)
        .where(SaasSubscription.clinic_id == clinic.id)
        .order_by(SaasSubscription.end_date.desc())
    )
    subs = subs_result.scalars().all()
    latest = subs[0] if subs else None
    
    c_settings = clinic.settings or {}
    c_branding = c_settings.get("branding") or {}
    return ClinicDirectoryResponse(
        id=clinic.id,
        name=clinic.name,
        tax_id=clinic.tax_id,
        created_at=clinic.created_at,
        subscription_active=bool(latest and latest.end_date > datetime.now(UTC)),
        subscription_end_date=latest.end_date if latest else None,
        subscription_count=len(subs),
        logo_url=c_branding.get("logo_url") or c_settings.get("logo_url"),
        primary_color=c_branding.get("primary_color") or c_settings.get("primary_color") or "#0284c7",
        theme_preset=c_branding.get("theme_preset") or c_settings.get("theme_preset") or "ocean_blue",
    )


@router.delete("/clinics/{target_clinic_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_clinic(
    target_clinic_id: uuid.UUID,
    ctx: Annotated[ClinicContext, Depends(get_clinic_context)],
    _: Annotated[None, Depends(require_permission("subscriptions.write"))],
    db: Annotated[AsyncSession, Depends(get_db)],
):
    """Superadmin: Permanently delete a clinic (Hard Delete).
    
    This cascades and wipes all data associated with this clinic.
    """
    if not is_platform_clinic(ctx.clinic.name):
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN, detail="Platform administrators only"
        )
    if target_clinic_id == ctx.clinic_id:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST, detail="Cannot delete the platform admin clinic"
        )

    result = await db.execute(select(Clinic).where(Clinic.id == target_clinic_id))
    clinic = result.scalar_one_or_none()
    if not clinic:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Clinic not found")

    await db.delete(clinic)
    await db.commit()
    return None


@router.get("/clinics/{target_clinic_id}/stats", response_model=ClinicStatsResponse)
async def get_clinic_stats(
    target_clinic_id: uuid.UUID,
    ctx: Annotated[ClinicContext, Depends(get_clinic_context)],
    _: Annotated[None, Depends(require_permission("subscriptions.read"))],
    db: Annotated[AsyncSession, Depends(get_db)],
):
    """Superadmin: Detailed operational statistics and counts for a clinic tenant."""
    if not is_platform_clinic(ctx.clinic.name):
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN, detail="Platform administrators only"
        )

    clinic = await db.get(Clinic, target_clinic_id)
    if not clinic:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Clinic not found")

    cid = str(target_clinic_id)

    # Patients count
    p_cnt = (
        await db.execute(text("SELECT COUNT(*) FROM patients WHERE clinic_id = :cid"), {"cid": cid})
    ).scalar() or 0

    # Staff / Users count
    u_cnt = (
        await db.execute(text("SELECT COUNT(*) FROM clinic_memberships WHERE clinic_id = :cid"), {"cid": cid})
    ).scalar() or 0

    # Appointments count
    a_cnt = (
        await db.execute(text("SELECT COUNT(*) FROM appointments WHERE clinic_id = :cid"), {"cid": cid})
    ).scalar() or 0

    # Categories count
    c_cnt = (
        await db.execute(text("SELECT COUNT(*) FROM treatment_categories WHERE clinic_id = :cid"), {"cid": cid})
    ).scalar() or 0

    # Treatment catalog items count
    t_cnt = (
        await db.execute(text("SELECT COUNT(*) FROM treatment_catalog_items WHERE clinic_id = :cid"), {"cid": cid})
    ).scalar() or 0

    # Invoices count and total billed
    inv_res = (
        await db.execute(text("SELECT COUNT(*), COALESCE(SUM(total), 0) FROM invoices WHERE clinic_id = :cid"), {"cid": cid})
    ).fetchone()
    inv_cnt = inv_res[0] if inv_res else 0
    inv_total = float(inv_res[1]) if inv_res else 0.0

    # Primary Admin User
    admin_row = (
        await db.execute(
            text("""
                SELECT u.id, u.email, u.first_name, u.last_name, cm.role
                FROM users u
                JOIN clinic_memberships cm ON u.id = cm.user_id
                WHERE cm.clinic_id = :cid
                ORDER BY CASE WHEN cm.role = 'admin' THEN 0 ELSE 1 END, u.created_at ASC
                LIMIT 1
            """),
            {"cid": cid},
        )
    ).fetchone()

    admin_info = (
        ClinicAdminInfo(
            id=admin_row[0],
            email=admin_row[1],
            first_name=admin_row[2],
            last_name=admin_row[3],
            role=admin_row[4],
        )
        if admin_row
        else None
    )

    return ClinicStatsResponse(
        clinic_id=clinic.id,
        clinic_name=clinic.name,
        tax_id=clinic.tax_id or "",
        currency=clinic.currency or "USD",
        timezone=clinic.timezone or "UTC",
        patient_count=p_cnt,
        user_count=u_cnt,
        appointment_count=a_cnt,
        treatment_count=t_cnt,
        category_count=c_cnt,
        invoice_count=inv_cnt,
        total_billed=inv_total,
        has_catalog=bool(c_cnt > 0 and t_cnt > 0),
        admin_user=admin_info,
    )


@router.post("/clinics/{target_clinic_id}/seed-catalog")
async def seed_clinic_catalog(
    target_clinic_id: uuid.UUID,
    ctx: Annotated[ClinicContext, Depends(get_clinic_context)],
    _: Annotated[None, Depends(require_permission("subscriptions.write"))],
    db: Annotated[AsyncSession, Depends(get_db)],
):
    """Superadmin: seed standard catalog (categories, treatments, VAT) for a clinic tenant."""
    if not is_platform_clinic(ctx.clinic.name):
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN, detail="Platform administrators only"
        )

    clinic = await db.get(Clinic, target_clinic_id)
    if not clinic:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Clinic not found")

    from app.modules.catalog.seed import seed_catalog

    summary = await seed_catalog(db, clinic.id)
    await db.commit()
    return {
        "message": "Catalog initialized successfully",
        "clinic_id": clinic.id,
        "summary": summary,
    }


