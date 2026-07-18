"""patients: add human-readable patient_number column.

Adds ``patient_number`` (e.g. ``PT-AMA-000123``) as a nullable,
unique column. Nullable so that existing rows are not broken —
the application layer will back-fill on next update, and new
patients always receive one at creation time.

Revision ID: pat_0004
Revises: pat_0003
Create Date: 2026-07-18

"""

from collections.abc import Sequence

import sqlalchemy as sa

from alembic import op

revision: str = "pat_0004"
down_revision: str | None = "pat_0003"
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None


def upgrade() -> None:
    # Nullable so existing patients are not broken.
    # Unique so no two patients ever share the same ID.
    op.add_column(
        "patients",
        sa.Column(
            "patient_number",
            sa.String(20),
            nullable=True,
        ),
    )
    op.create_unique_constraint(
        "uq_patients_patient_number",
        "patients",
        ["patient_number"],
    )
    op.create_index(
        "ix_patients_patient_number",
        "patients",
        ["patient_number"],
        unique=True,
    )


def downgrade() -> None:
    op.drop_index("ix_patients_patient_number", table_name="patients")
    op.drop_constraint("uq_patients_patient_number", "patients", type_="unique")
    op.drop_column("patients", "patient_number")
