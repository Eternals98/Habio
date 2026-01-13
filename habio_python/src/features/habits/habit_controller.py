from src.models.habit import Habit
from src.models.room import Room
from src.features.auth.auth_controller import AuthController
from src.features.habits import habit_repository
from datetime import datetime

class HabitController:
    @staticmethod
    def get_user_habits():
        user = AuthController.get_current_user()
        if not user:
            return []
        # Try server
        try:
            resp = habit_repository.list_habits()
            return resp
        except Exception:
            # Fallback to local DB
            return list(Habit.select().where(Habit.user == user))

    @staticmethod
    def create_habit(name, personality="disciplined", room=None):
        user = AuthController.get_current_user()
        if not user:
            return False, "Not logged in"

        # Prefer server API
        try:
            room_id = room.id if room else None
            resp = habit_repository.create_habit(name, room_id)
            return True, "Habit created"
        except Exception:
            # Local fallback
            if not room:
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
        # Try server
        try:
            resp = habit_repository.complete_habit(habit_id)
            return True, "Completed"
        except Exception:
            # Local fallback
            try:
                habit = Habit.get_by_id(habit_id)
                if not habit.is_completed_today:
                    habit.complete()
                    user = habit.user
                    user.xp += habit.xp_reward
                    user.coins += habit.coin_reward
                    user.save()
                    return True, f"Completed! +{habit.xp_reward} XP, +{habit.coin_reward} Coins"
                return False, "Already completed today"
            except Habit.DoesNotExist:
                return False, "Habit not found"