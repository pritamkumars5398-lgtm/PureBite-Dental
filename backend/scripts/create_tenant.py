#!/usr/bin/env python3
"""Script to dynamically provision a new clinic and its first admin user."""

import argparse
import asyncio
import sys
from uuid import uuid4

from sqlalchemy import select

from app.core.auth.models import Clinic, ClinicMembership, User
from app.core.auth.service import hash_password
from app.database import async_session_maker


def _register_all_models() -> None:
    """Import every module's models so SQLAlchemy can resolve the string
    relationships on ``Clinic`` (``Patient``, ``Appointment``, ``Cabinet``…).

    Those classes live in feature modules that this standalone script never
    imports, so without this the mapper fails with
    ``failed to locate a name ('Patient')``. Discover modules the same way
    the running app does and touch each one's ``get_models()``.
    """
    from app.core.plugins.loader import discover_modules

    for module in discover_modules():
        module.get_models()


async def create_tenant(
    clinic_name: str,
    tax_id: str,
    email: str,
    password: str,
    first_name: str,
    last_name: str,
    currency: str = "INR",
    timezone: str = "Asia/Kolkata",
):
    _register_all_models()
    async with async_session_maker() as db:
        # 1. Check if email already exists
        email_check = await db.execute(select(User).where(User.email == email))
        if email_check.scalar_one_or_none():
            print(f"Error: A user with email '{email}' already exists.", file=sys.stderr)
            return

        # 2. Create the Clinic
        clinic = Clinic(
            id=uuid4(),
            name=clinic_name,
            tax_id=tax_id,
            timezone=timezone,
            currency=currency.upper(),
            settings={
                "slot_duration_min": 15,
                "budget_expiry_days": 30,
                "budget_reminders_enabled": False,
            },
        )
        db.add(clinic)

        # 3. Create the Admin User
        user = User(
            id=uuid4(),
            email=email,
            password_hash=hash_password(password),
            first_name=first_name,
            last_name=last_name,
            is_active=True,
        )
        db.add(user)
        await db.flush()  # Ensures IDs are generated/flushed

        # 4. Create the ClinicMembership
        membership = ClinicMembership(
            id=uuid4(),
            user_id=user.id,
            clinic_id=clinic.id,
            role="admin",
        )
        db.add(membership)

        await db.commit()

        print("==================================================")
        print("🎉 SUCCESS: Tenant Provisioned Successfully!")
        print("==================================================")
        print(f"Clinic Name : {clinic.name}")
        print(f"Clinic ID   : {clinic.id}")
        print(f"Admin Email : {user.email}")
        print("Admin Role  : admin")
        print("==================================================")


def main():
    parser = argparse.ArgumentParser(description="Create a new clinic tenant and admin user.")
    parser.add_argument("--clinic-name", required=True, help="Name of the clinic")
    parser.add_argument("--tax-id", required=True, help="Tax identification number (CIF/NIF)")
    parser.add_argument("--email", required=True, help="Email of the admin user")
    parser.add_argument("--password", required=True, help="Password for the admin user")
    parser.add_argument("--first-name", required=True, help="Admin first name")
    parser.add_argument("--last-name", required=True, help="Admin last name")
    parser.add_argument(
        "--currency",
        default="INR",
        help="ISO 4217 currency code for the clinic (default: INR)",
    )
    parser.add_argument(
        "--timezone",
        default="Asia/Kolkata",
        help="IANA timezone id for the clinic (default: Asia/Kolkata)",
    )

    args = parser.parse_args()

    asyncio.run(
        create_tenant(
            clinic_name=args.clinic_name,
            tax_id=args.tax_id,
            email=args.email,
            password=args.password,
            first_name=args.first_name,
            last_name=args.last_name,
            currency=args.currency,
            timezone=args.timezone,
        )
    )


if __name__ == "__main__":
    main()
