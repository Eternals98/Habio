from peewee import CharField, IntegerField, ForeignKeyField, BooleanField
from src.core.database import BaseModel
from src.models.user import User

class ShopItem(BaseModel):
    name = CharField()
    description = CharField()
    icon_path = CharField()
    price = IntegerField()
    category = CharField() # food, accessory, decoration, background
    value = IntegerField(default=0) # e.g. amount of health restored

class InventoryItem(BaseModel):
    user = ForeignKeyField(User, backref='inventory')
    item = ForeignKeyField(ShopItem, backref='owners')
    quantity = IntegerField(default=1)
    is_equipped = BooleanField(default=False)

class Gift(BaseModel):
    sender = ForeignKeyField(User, backref='sent_gifts')
    receiver = ForeignKeyField(User, backref='received_gifts')
    item = ForeignKeyField(ShopItem)
    message = CharField(null=True)
    is_claimed = BooleanField(default=False)
