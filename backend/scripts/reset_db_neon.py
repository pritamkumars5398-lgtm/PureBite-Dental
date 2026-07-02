import asyncio
from sqlalchemy import text
from app.database import engine

async def main():
    print("Connecting to database and dropping all tables...")
    async with engine.begin() as conn:
        # Get list of tables in public schema
        res = await conn.execute(text("""
            SELECT tablename FROM pg_tables WHERE schemaname = 'public';
        """))
        tables = [row[0] for row in res.fetchall()]
        print(f"Found {len(tables)} tables to drop.")
        for table in tables:
            print(f"Dropping table: {table}")
            await conn.execute(text(f'DROP TABLE IF EXISTS "{table}" CASCADE;'))
        print("All tables dropped successfully!")

if __name__ == "__main__":
    asyncio.run(main())
