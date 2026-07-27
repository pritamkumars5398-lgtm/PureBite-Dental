import asyncio
import os

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession, create_async_engine
from sqlalchemy.orm import sessionmaker

from app.core.auth.models import User
from app.core.auth.service import create_access_token


async def main():
    os.environ["DATABASE_URL"] = (
        "postgresql+asyncpg://neondb_owner:npg_UKLeREGcuJ40@ep-snowy-star-aixtxi7u.c-4.us-east-1.aws.neon.tech/neondb?ssl=require"
    )
    os.environ["SECRET_KEY"] = "dev-secret-key-min-32-chars-long-1234567890"

    engine = create_async_engine(os.environ["DATABASE_URL"])
    async_session = sessionmaker(engine, class_=AsyncSession, expire_on_commit=False)

    async with async_session() as db:
        result = await db.execute(select(User).where(User.email == "pushpendra@dental.com"))
        user = result.scalar_one_or_none()
        if not user:
            print("User not found")
            return

        print("User:", user.email, user.id)
        token = create_access_token(
            subject=str(user.id), token_version=user.token_version, expires_delta=None
        )
        print("\nTOKEN=" + token)


asyncio.run(main())
