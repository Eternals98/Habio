from peewee import CharField, IntegerField, ForeignKeyField, DateTimeField, BooleanField
from src.core.database import BaseModel
from src.models.user import User
from src.models.room import Room
import datetime

class Habit(BaseModel):
    user = ForeignKeyField(User, backref='habits')
    room = ForeignKeyField(Room, backref='habits', null=True)
    name = CharField()
    description = CharField(null=True)
    
    # Gamification
    difficulty = IntegerField(default=1) # 1=Easy, 2=Med, 3=Hard
    xp_reward = IntegerField(default=10)
    coin_reward = IntegerField(default=5)
    
    # Personality/Type (from existing app analysis)
    personality = CharField(default="disciplined") 
    
    # Stats
    streak = IntegerField(default=0)
    is_completed_today = BooleanField(default=False)
    last_completed_date = DateTimeField(null=True)
    created_at = DateTimeField(default=datetime.datetime.now)

    def complete(self):
        self.is_completed_today = True
        self.last_completed_date = datetime.datetime.now()
        self.streak += 1
        self.save()
        
    def reset_daily(self):
        # Logic to be called daily
        if not self.is_completed_today:
             self.streak = 0
        self.is_completed_today = False
        self.save()
