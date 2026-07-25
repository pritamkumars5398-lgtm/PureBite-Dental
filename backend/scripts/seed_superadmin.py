#!/usr/bin/env python3
"""Script to seed or update the default Superadmin user."""

import argparse
import asyncio
import sys
from uuid import uuid4

from sqlalchemy import select
from sqlalchemy.orm import selectinload

from app.core.auth.models import Clinic, ClinicMembership, User
from app.core.auth.service import hash_password
from app.database import async_session_maker


def _register_all_models() -> None:
    from app.core.plugins.loader import discover_modules

    for module in discover_modules():
        module.get_models()


async def seed_superadmin(
    email: str,
    password: str,
    first_name: str,
    last_name: str,
):
    _register_all_models()
    async with async_session_maker() as db:
        # Check if user already exists
        result = await db.execute(select(User).options(selectinload(User.memberships)).where(User.email == email))
        user = result.scalar_one_or_none()

        if user:
            print(f"User {email} already exists. Updating details (UPSERT).")
            user.first_name = first_name
            user.last_name = last_name
            if password:
                user.password_hash = hash_password(password)
        else:
            print(f"Creating new superadmin user {email}.")
            user = User(
                id=uuid4(),
                email=email,
                password_hash=hash_password(password),
                first_name=first_name,
                last_name=last_name,
                is_active=True,
            )
            db.add(user)
            await db.flush()

        # Check if superadmin clinic exists (required for ClinicContext)
        clinic_result = await db.execute(select(Clinic).where(Clinic.name == "Platform Administration"))
        clinic = clinic_result.scalar_one_or_none()

        if not clinic:
            clinic = Clinic(
                id=uuid4(),
                name="Platform Administration",
                tax_id="PLATFORM-ADMIN",
                timezone="UTC",
                currency="USD",
                settings={},
            )
            db.add(clinic)
            await db.flush()

        # Check if user has membership in the platform clinic with superadmin role
        membership_result = await db.execute(
            select(ClinicMembership).where(
                ClinicMembership.user_id == user.id,
                ClinicMembership.clinic_id == clinic.id,
            )
        )
        membership = membership_result.scalar_one_or_none()

        if not membership:
            membership = ClinicMembership(
                id=uuid4(),
                user_id=user.id,
                clinic_id=clinic.id,
                role="admin",  # They are admin of the Platform Admin clinic
            )
            db.add(membership)
        else:
            membership.role = "admin"

        await db.commit()

        print("==================================================")
        print("🎉 SUCCESS: Superadmin Seeded/Updated Successfully!")
        print("==================================================")
        print(f"Admin Email : {user.email}")
        print("==================================================")


def main():
    parser = argparse.ArgumentParser(description="Seed the superadmin user.")
    parser.add_argument("--email", default="superadmin@purebite.com", help="Email of the superadmin")
    parser.add_argument("--password", default="superadmin123", help="Password for the superadmin")
    parser.add_argument("--first-name", default="Super", help="Admin first name")
    parser.add_argument("--last-name", default="Admin", help="Admin last name")

    args = parser.parse_args()

    asyncio.run(
        seed_superadmin(
            email=args.email,
            password=args.password,
            first_name=args.first_name,
            last_name=args.last_name,
        )
    )


if __name__ == "__main__":
    main()
