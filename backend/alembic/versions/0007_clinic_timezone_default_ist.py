"""core — change clinics.timezone server default Europe/Madrid → Asia/Kolkata.

The project's market is now India, so new clinics provisioned without an
explicit timezone should default to IST (Asia/Kolkata). Timezone drives
appointment availability windows, working-hours math and schedule
analytics, so the default must match the operating region. Existing rows
are left untouched — this migration only changes the fallback used when a
row is inserted with no explicit timezone.

Revision ID: 0007
Revises: 0006
Create Date: 2026-07-22
"""

from collections.abc import Sequence

from alembic import op

revision: str = "0007"
down_revision: str | None = "0006"
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None


def upgrade() -> None:
    op.alter_column("clinics", "timezone", server_default="Asia/Kolkata")


def downgrade() -> None:
    op.alter_column("clinics", "timezone", server_default="Europe/Madrid")
