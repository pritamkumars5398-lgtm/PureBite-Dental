"""
Backfill script: generate patient_number for all existing patients that have NULL.

Format: PT-{FIRST3}-{6-digit-seq}
  - FIRST3  = first 3 letters of first_name, uppercased
  - 6-digit-seq = per-clinic sequential number (1-indexed, zero-padded)

Run from the backend directory:
  python scripts/backfill_patient_numbers.py
"""

import asyncio
import os
import sys

# Make sure the app package is importable when run from backend/
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from sqlalchemy import text
from sqlalchemy.ext.asyncio import AsyncSession, create_async_engine
from sqlalchemy.orm import sessionmaker

DATABASE_URL = os.environ.get("DATABASE_URL") or open(
    os.path.join(os.path.dirname(__file__), "..", ".env")
).read().split("DATABASE_URL=")[1].split("\n")[0].strip()


async def backfill():
    engine = create_async_engine(DATABASE_URL, echo=False)
    async_session = sessionmaker(engine, class_=AsyncSession, expire_on_commit=False)

    async with async_session() as session:
        # Fetch all patients with NULL patient_number, grouped by clinic
        result = await session.execute(
            text("""
                SELECT id, clinic_id, first_name
                FROM patients
                WHERE patient_number IS NULL
                ORDER BY clinic_id, created_at ASC
            """)
        )
        patients = result.fetchall()

        if not patients:
            print("No patients with NULL patient_number found. Nothing to do.")
            await engine.dispose()
            return

        print(f"Found {len(patients)} patients to backfill...")

        # We'll assign seq numbers starting from (already_numbered_count + 1)

        # by tracking within each clinic
        already_numbered_result = await session.execute(
            text("""
                SELECT clinic_id, COUNT(*) as cnt
                FROM patients
                WHERE patient_number IS NOT NULL
                GROUP BY clinic_id
            """)
        )
        clinic_offset = {str(row.clinic_id): row.cnt for row in already_numbered_result.fetchall()}

        # Count within this batch per clinic
        clinic_counter: dict[str, int] = {}

        updates = []
        for row in patients:
            clinic_key = str(row.clinic_id)
            base_offset = clinic_offset.get(clinic_key, 0)
            clinic_counter[clinic_key] = clinic_counter.get(clinic_key, 0) + 1
            seq = base_offset + clinic_counter[clinic_key]

            prefix = (row.first_name or "XXX")[:3].upper()
            patient_number = f"PT-{prefix}-{seq:06d}"
            updates.append({"pid": str(row.id), "pnum": patient_number})

        # Apply all updates
        for u in updates:
            await session.execute(
                text("UPDATE patients SET patient_number = :pnum WHERE id = CAST(:pid AS uuid)"),
                {"pnum": u["pnum"], "pid": u["pid"]},
            )

        await session.commit()
        print(f"DONE: Successfully backfilled {len(updates)} patients!")
        for u in updates[:10]:
            print(f"   {u['pid']} -> {u['pnum']}")
        if len(updates) > 10:
            print(f"   ... and {len(updates) - 10} more.")

    await engine.dispose()


if __name__ == "__main__":
    asyncio.run(backfill())
