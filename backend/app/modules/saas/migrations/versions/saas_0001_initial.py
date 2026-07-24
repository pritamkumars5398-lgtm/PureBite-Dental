"""saas initial.

Initial schema for the `saas` module.

Revision ID: saas_0001
Revises:
Create Date: 2026-07-24

"""

from collections.abc import Sequence

import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

from alembic import op

revision: str = "saas_0001"
down_revision: str | None = "0001"
branch_labels: str | Sequence[str] | None = ("saas",)
depends_on: str | Sequence[str] | None = None


def upgrade() -> None:
    # saas_leads
    op.create_table(
        "saas_leads",
        sa.Column("id", sa.UUID(), nullable=False),
        sa.Column("contact_name", sa.String(length=255), nullable=False),
        sa.Column("clinic_name", sa.String(length=255), nullable=False),
        sa.Column("phone", sa.String(length=50), nullable=True),
        sa.Column("email", sa.String(length=255), nullable=False),
        sa.Column("expected_users", sa.Integer(), nullable=True),
        sa.Column("status", sa.String(length=50), nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False),
        sa.PrimaryKeyConstraint("id"),
    )

    # saas_pricing_plans
    op.create_table(
        "saas_pricing_plans",
        sa.Column("id", sa.UUID(), nullable=False),
        sa.Column("name", sa.String(length=255), nullable=False),
        sa.Column("duration_months", sa.Integer(), nullable=False),
        sa.Column("price", sa.Numeric(precision=10, scale=2), nullable=False),
        sa.Column("is_active", sa.Boolean(), nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False),
        sa.PrimaryKeyConstraint("id"),
    )

    # saas_subscriptions
    op.create_table(
        "saas_subscriptions",
        sa.Column("id", sa.UUID(), nullable=False),
        sa.Column("clinic_id", sa.UUID(), nullable=False),
        sa.Column("start_date", sa.DateTime(timezone=True), nullable=False),
        sa.Column("end_date", sa.DateTime(timezone=True), nullable=False),
        sa.Column("status", sa.String(length=50), nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False),
        sa.ForeignKeyConstraint(
            ["clinic_id"],
            ["clinics.id"],
            ondelete="CASCADE",
        ),
        sa.PrimaryKeyConstraint("id"),
    )
    op.create_index(op.f("ix_saas_subscriptions_clinic_id"), "saas_subscriptions", ["clinic_id"], unique=False)


def downgrade() -> None:
    op.drop_index(op.f("ix_saas_subscriptions_clinic_id"), table_name="saas_subscriptions")
    op.drop_table("saas_subscriptions")
    op.drop_table("saas_pricing_plans")
    op.drop_table("saas_leads")
