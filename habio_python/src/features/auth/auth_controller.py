from src.models.user import User
from src.models.room import Room
import hashlib

class AuthController:
    current_user_id = None

    @staticmethod
    def _hash_password(password: str) -> str:
        # Simple hash for MVP. In prod use bcrypt/argon2
        return hashlib.sha256(password.encode()).hexdigest()

    @classmethod
    def login(cls, username, password):
        try:
            user = User.get(User.username == username)
            if user.password_hash == cls._hash_password(password):
                cls.current_user_id = user.id
                return True, "Login successful"
            return False, "Invalid password"
        except User.DoesNotExist:
            return False, "User not found"

    @classmethod
    def register(cls, username, email, password):
        try:
            if User.select().where((User.username == username) | (User.email == email)).exists():
                return False, "Username or Email already exists"
                
            user = User.create(
                username=username,
                email=email,
                password_hash=cls._hash_password(password)
            )
            # Create default room
            Room.create(user=user, name="My Room")
            return True, "Registration successful"
        except Exception as e:
            return False, str(e)

    @classmethod
    def get_current_user(cls):
        if cls.current_user_id:
            return User.get_by_id(cls.current_user_id)
        return None
