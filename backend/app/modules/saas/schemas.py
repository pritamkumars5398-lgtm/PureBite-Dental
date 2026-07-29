from datetime import datetime
from decimal import Decimal
from typing import Literal
from uuid import UUID

from pydantic import BaseModel, ConfigDict, EmailStr, Field

LEAD_STATUSES = ("pending", "contacted", "processed", "rejected")


class LeadCreate(BaseModel):
    contact_name: str = Field(..., max_length=255)
    clinic_name: str = Field(..., max_length=255)
    phone: str | None = Field(None, max_length=50)
    email: EmailStr
    expected_users: int | None = Field(None, ge=1)
    message: str | None = Field(None, max_length=2000)


class LeadResponse(BaseModel):
    id: UUID
    contact_name: str
    clinic_name: str
    phone: str | None
    email: str
    expected_users: int | None
    message: str | None
    status: str
    created_at: datetime
    updated_at: datetime

    model_config = ConfigDict(from_attributes=True)


class LeadStatusUpdate(BaseModel):
    status: Literal["pending", "contacted", "processed", "rejected"]


class PricingPlanCreate(BaseModel):
    name: str = Field(..., max_length=255)
    duration_months: int = Field(..., ge=1)
    price: Decimal = Field(..., ge=0)
    is_active: bool = True


class PricingPlanUpdate(BaseModel):
    name: str | None = Field(None, max_length=255)
    duration_months: int | None = Field(None, ge=1)
    price: Decimal | None = Field(None, ge=0)
    is_active: bool | None = None


class PricingPlanResponse(PricingPlanCreate):
    id: UUID
    created_at: datetime
    updated_at: datetime
    model_config = ConfigDict(from_attributes=True)


class TenantProvisionRequest(BaseModel):
    clinic_name: str = Field(..., max_length=255)
    tax_id: str = Field(..., max_length=50)
    admin_email: EmailStr
    admin_password: str = Field(..., min_length=8)
    admin_first_name: str = Field(..., max_length=100)
    admin_last_name: str = Field(..., max_length=100)
    currency: str = "USD"
    timezone: str = "UTC"


class TenantProvisionResponse(BaseModel):
    clinic_id: UUID
    clinic_name: str
    admin_user_id: UUID
    admin_email: str


class SubscriptionCreate(BaseModel):
    clinic_id: UUID
    duration_months: int = Field(..., ge=1)
    plan_id: UUID | None = None


class SubscriptionResponse(BaseModel):
    id: UUID
    clinic_id: UUID
    plan_id: UUID | None = None
    plan: PricingPlanResponse | None = None
    start_date: datetime
    end_date: datetime
    status: str
    # Computed at request time from start/end vs. now — `status` on the row
    # is written as "active" at creation regardless of whether it's live
    # yet, so a stacked/future-dated renewal needs this to read correctly
    # as "upcoming" rather than "active".
    effective_status: Literal["upcoming", "active", "expired"]
    created_at: datetime
    updated_at: datetime
    model_config = ConfigDict(from_attributes=True)


class ClinicDirectoryResponse(BaseModel):
    id: UUID
    name: str
    tax_id: str
    created_at: datetime
    subscription_active: bool
    subscription_end_date: datetime | None
    subscription_count: int


class ClinicUpdate(BaseModel):
    name: str | None = Field(None, max_length=255)
    tax_id: str | None = Field(None, max_length=50)
    currency: str | None = None
    timezone: str | None = None

