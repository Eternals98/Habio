from peewee import CharField, IntegerField, ForeignKeyField

from src.core.database import BaseModel

class User(BaseModel):
    username = CharField(unique=True)
    email = CharField(unique=True)
    password_hash = CharField()
    level = IntegerField(default=1)
    xp = IntegerField(default=0)
    coins = IntegerField(default=0)
    
    # Pet Stats
    pet_name = CharField(default="Pet")
    pet_hp = IntegerField(default=100)
    pet_type = CharField(default="blob") # basic, cat, dog...

class Friend(BaseModel):
    user = ForeignKeyField(User, backref='friends')
    friend = ForeignKeyField(User, backref='friend_of')

# Circular dependency for Gifting might need DeferredRelation if Item is used here directly, 
# but we will likely link via Item ID or a separate Gift model in Inventory.
