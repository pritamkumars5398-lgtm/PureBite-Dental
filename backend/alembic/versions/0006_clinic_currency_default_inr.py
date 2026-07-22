"""core — change clinics.currency server default EUR → INR.

The project's market is now India, so new clinics provisioned without an
explicit currency should default to INR rather than EUR. Currency is set
once at provisioning/seed time and is no longer editable via the admin
API, so this only affects the fallback used when a row is inserted with
no explicit currency. Existing rows are left untouched — this migration
does not rewrite any clinic's stored currency.

Revision ID: 0006
Revises: 0005
Create Date: 2026-07-22
"""

from collections.abc import Sequence

from alembic import op

revision: str = "0006"
down_revision: str | None = "0005"
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None


def upgrade() -> None:
    op.alter_column("clinics", "currency", server_default="INR")


def downgrade() -> None:
    op.alter_column("clinics", "currency", server_default="EUR")
