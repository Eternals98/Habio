from peewee import SqliteDatabase, Model
from playhouse.db_url import connect
import os

# Choose DB: if DATABASE_URL is set, connect to that (Postgres), otherwise fallback to local sqlite
DATABASE_URL = os.getenv("DATABASE_URL")
if DATABASE_URL:
    db = connect(DATABASE_URL)
else:
    # Ensure the database file is stored in a proper location
    DB_PATH = os.getenv("HABIO_DB_PATH", "habio.db")
    db = SqliteDatabase(DB_PATH)

class BaseModel(Model):
    class Meta:
        database = db


def initialize_database():
    from src.models.user import User, Friend
    from src.models.habit import Habit
    from src.models.inventory import ShopItem, InventoryItem, Gift
    from src.models.room import Room
    
    db.connect(reuse_if_open=True)
    db.create_tables([User, Friend, Habit, ShopItem, InventoryItem, Gift, Room])

    # Seed some shop items if empty
    if ShopItem.select().count() == 0:
        ShopItem.create(name="Apple", description="A healthy snack", icon_path="🍎", price=10, category="food", value=20)
        ShopItem.create(name="Teddy Bear", description="A cute accessory", icon_path="🧸", price=50, category="accessory", value=0)
        ShopItem.create(name="Pizza", description="Delicious food", icon_path="🍕", price=25, category="food", value=30)

