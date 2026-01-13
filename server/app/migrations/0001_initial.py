import datetime


def apply(db):
    # Create initial tables and seed shop items
    from app import models
    db.create_tables([
        models.User,
        models.Friend,
        models.Room,
        models.Habit,
        models.ShopItem,
        models.InventoryItem,
        models.Gift,
        models.Migration,
    ])
    if models.ShopItem.select().count() == 0:
        models.ShopItem.create(name="Apple", description="A healthy snack", icon_path="🍎", price=10, category="food", value=20)
        models.ShopItem.create(name="Teddy Bear", description="A cute accessory", icon_path="🧸", price=50, category="accessory", value=0)
        models.ShopItem.create(name="Pizza", description="Delicious food", icon_path="🍕", price=25, category="food", value=30)
