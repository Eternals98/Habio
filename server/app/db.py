import os
from playhouse.db_url import connect
from peewee import Model

from app.config import settings

DATABASE_URL = os.getenv("DATABASE_URL", settings.DATABASE_URL)

# Use playhouse.db_url.connect which understands postgres:// and sqlite:///
db = connect(DATABASE_URL)

class BaseModel(Model):
    class Meta:
        database = db


def init_db():
    from app import models
    db.connect(reuse_if_open=True)
    # Apply migrations instead of direct table creation
    try:
        from app.manage_migrations import apply_migrations
        apply_migrations()
    except Exception:
        # fallback to legacy create_tables if migrations fail
        db.create_tables([
            models.User,
            models.Friend,
            models.Room,
            models.Habit,
            models.ShopItem,
            models.InventoryItem,
            models.Gift,
        ])
        # Seed shop items if empty
        if models.ShopItem.select().count() == 0:
            models.ShopItem.create(name="Apple", description="A healthy snack", icon_path="🍎", price=10, category="food", value=20)
            models.ShopItem.create(name="Teddy Bear", description="A cute accessory", icon_path="🧸", price=50, category="accessory", value=0)
            models.ShopItem.create(name="Pizza", description="Delicious food", icon_path="🍕", price=25, category="food", value=30)


if __name__ == "__main__":
    init_db()
