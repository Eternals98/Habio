import importlib
import os
from app.db import db
from app.models import Migration

MIGRATIONS_DIR = os.path.join(os.path.dirname(__file__), "migrations")


def apply_migrations():
    """Apply all migrations found in server/app/migrations in order and record them."""
    # Ensure migration table exists
    if Migration.table_exists() is False:
        db.create_tables([Migration])

    applied = {m.name for m in Migration.select()}
    files = sorted([f for f in os.listdir(MIGRATIONS_DIR) if f.endswith('.py') and f[0].isdigit()])
    for f in files:
        name = f[:-3]
        if name in applied:
            continue
        module_name = f"app.migrations.{name}"
        module = importlib.import_module(module_name)
        if hasattr(module, 'apply'):
            module.apply(db)
            Migration.create(name=name)
            print(f"Applied migration: {name}")
        else:
            print(f"Skipping migration {name}: no apply(db) function found")


if __name__ == '__main__':
    apply_migrations()
