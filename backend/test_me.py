import asyncio

from sqlalchemy import select

from app.core.auth.models import User
from app.database import engine


async def run():
    async with engine.begin() as conn:
        result = await conn.execute(select(User).limit(1))
        user = result.scalar_one_or_none()
        print(user.email)


asyncio.run(run())
