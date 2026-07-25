import asyncio
from app.database import engine
from app.core.auth.models import User
from sqlalchemy import select
from httpx import AsyncClient
from app.main import app

async def test():
    async with AsyncClient(app=app, base_url="http://test") as client:
        pass # To properly test this, I need an auth token for the superadmin.
