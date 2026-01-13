from peewee import CharField, ForeignKeyField
from src.core.database import BaseModel
from src.models.user import User

class Room(BaseModel):
    name = CharField()
    user = ForeignKeyField(User, backref='rooms')