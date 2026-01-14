from peewee import CharField, IntegerField, ForeignKeyField, BooleanField, DateTimeField
from app.db import BaseModel
import datetime


class User(BaseModel):
    username = CharField(unique=True)
    email = CharField(unique=True)
    password_hash = CharField()
    level = IntegerField(default=1)
    xp = IntegerField(default=0)
    coins = IntegerField(default=0)

    pet_name = CharField(default="Pet")
    pet_hp = IntegerField(default=100)
    pet_type = CharField(default="blob")
    pet_personality = CharField(default="alegre")


class Friend(BaseModel):
    user = ForeignKeyField(User, backref='friends')
    friend = ForeignKeyField(User, backref='friend_of')


class Room(BaseModel):
    name = CharField()
    user = ForeignKeyField(User, backref='rooms')


class Habit(BaseModel):
    user = ForeignKeyField(User, backref='habits')
    room = ForeignKeyField(Room, backref='habits', null=True)
    name = CharField()
    description = CharField(null=True)

    difficulty = IntegerField(default=1)
    xp_reward = IntegerField(default=10)
    coin_reward = IntegerField(default=5)

    personality = CharField(default="disciplined")

    streak = IntegerField(default=0)
    is_completed_today = BooleanField(default=False)
    last_completed_date = DateTimeField(null=True)
    created_at = DateTimeField(default=datetime.datetime.now)


class ShopItem(BaseModel):
    name = CharField()
    description = CharField()
    icon_path = CharField()
    price = IntegerField()
    category = CharField()
    value = IntegerField(default=0)


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


class WheelPrize(BaseModel):
    name = CharField()
    prize_type = CharField(default="coins")  # 'coins' or 'item'
    value = IntegerField(default=0)  # coins amount or item id if prize_type=='item'
    item = ForeignKeyField(ShopItem, null=True, backref='wheel_prizes')
    icon_path = CharField(null=True)
    weight = IntegerField(default=1)


class Migration(BaseModel):
    name = CharField(unique=True)
    applied_at = DateTimeField(default=datetime.datetime.now)
