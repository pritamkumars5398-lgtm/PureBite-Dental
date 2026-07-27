from httpx import AsyncClient

from app.main import app


async def test():
    async with AsyncClient(app=app, base_url="http://test"):
        pass  # To properly test this, I need an auth token for the superadmin.
