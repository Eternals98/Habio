from src.models.user import User
from src.models.room import Room
from src.core.session import set_token, get_token, clear_token
from src.features.auth.auth_repository import login as api_login, register as api_register, me as api_me

class AuthController:
    current_user_id = None

    @classmethod
    def login(cls, username, password):
        try:
            resp = api_login(username, password)
            token = resp.get("access_token")
            if not token:
                return False, "Login failed"
            set_token(token)
            # Fetch user
            user_data = api_me()
            # Upsert local user
            user, created = User.get_or_create(username=user_data.get("username"), defaults={
                "email": user_data.get("email"),
                "password_hash": "", # server-managed
            })
            cls.current_user_id = user.id
            return True, "Login successful"
        except Exception as e:
            return False, str(e)

    @classmethod
    def register(cls, username, email, password):
        try:
            resp = api_register(username, email, password)
            token = resp.get("access_token")
            if not token:
                return False, "Registration failed"
            set_token(token)
            # Fetch user
            user_data = api_me()
            user, created = User.get_or_create(username=user_data.get("username"), defaults={
                "email": user_data.get("email"),
                "password_hash": "",
            })
            # Create default room locally if not exists
            if not Room.select().where((Room.user == user) & (Room.name == "My Room")).exists():
                Room.create(user=user, name="My Room")
            cls.current_user_id = user.id
            return True, "Registration successful"
        except Exception as e:
            return False, str(e)

    @classmethod
    def logout(cls):
        clear_token()
        cls.current_user_id = None
        return True

    @classmethod
    def get_current_user(cls):
        if cls.current_user_id:
            return User.get_by_id(cls.current_user_id)
        # Try from token
        token = get_token()
        if token:
            try:
                user_data = api_me()
                user, created = User.get_or_create(username=user_data.get("username"), defaults={
                    "email": user_data.get("email"),
                    "password_hash": "",
                })
                cls.current_user_id = user.id
                return user
            except Exception:
                return None
        return None
