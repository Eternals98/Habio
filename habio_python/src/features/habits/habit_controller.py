from src.models.habit import Habit
from src.models.room import Room
from src.features.auth.auth_controller import AuthController
from datetime import datetime

class HabitController:
    @staticmethod
    def get_user_habits():
        user = AuthController.get_current_user()
        if not user:
            return []
        return list(Habit.select().where(Habit.user == user))

    @staticmethod
    def create_habit(name, personality="disciplined", room=None):
        user = AuthController.get_current_user()
        if not user:
            return False, "Not logged in"
        
        if not room:
            # Get or create default room
            room, created = Room.get_or_create(
                user=user,
                defaults={'name': 'My Room'}
            )
        
        try:
            Habit.create(
                user=user,
                room=room,
                name=name,
                personality=personality
            )
            return True, "Habit created"
        except Exception as e:
            return False, str(e)

    @staticmethod
    def complete_habit(habit_id):
        try:
            habit = Habit.get_by_id(habit_id)
            if not habit.is_completed_today:
                habit.complete()
                
                # Gamification: Reward User
                user = habit.user
                user.xp += habit.xp_reward
                user.coins += habit.coin_reward
                user.save()
                
                return True, f"Completed! +{habit.xp_reward} XP, +{habit.coin_reward} Coins"
            return False, "Already completed today"
        except Habit.DoesNotExist:
            return False, "Habit not found"
