from src.features.auth.auth_controller import AuthController
from src.features.habits.habit_controller import HabitController
from src.features.social.social_controller import SocialController
from src.core.database import db, initialize_database
from src.models.user import User
import os

# Setup Test DB
TEST_DB = "test_habio.db"
if os.path.exists(TEST_DB):
    os.remove(TEST_DB)

db.init(TEST_DB)
initialize_database()

print("--- START VERIFICATION ---")

# 1. Register Users
print("1. Registering users...")
ok, msg = AuthController.register("Alice", "alice@example.com", "password123")
print(f"Alice Reg: {ok} - {msg}")
ok, msg = AuthController.register("Bob", "bob@example.com", "password123")
print(f"Bob Reg: {ok} - {msg}")

# 2. Login Alice
print("\n2. Login Alice...")
ok, msg = AuthController.login("Alice", "password123")
print(f"Login: {ok} - {msg}")
alice = AuthController.get_current_user()
print(f"Current User: {alice.username}, XP: {alice.xp}, Coins: {alice.coins}")

# 3. Habit Flow
print("\n3. Habit Flow...")
HabitController.create_habit("Exercise")
habits = HabitController.get_user_habits()
print(f"Habits found: {len(habits)}")
if habits:
    h = habits[0]
    print(f"Completing habit '{h.name}'...")
    ok, msg = HabitController.complete_habit(h.id)
    print(f"Result: {ok} - {msg}")
    
    # Reload Alice to check stats
    alice = AuthController.get_current_user()
    print(f"Updated Stats -> XP: {alice.xp}, Coins: {alice.coins}")
    if alice.xp > 0:
        print("✅ Gamification Logic Works")
    else:
        print("❌ Gamification Logic Failed")

# 4. Social Flow
print("\n4. Social Flow...")
ok, msg = SocialController.add_friend("Bob")
print(f"Add Bob: {ok} - {msg}")

friends = SocialController.get_friends()
print(f"Friends count: {len(friends)}")
if len(friends) > 0:
    print(f"Friend found: {friends[0].username}")
    print("✅ Social Logic Works")
else:
    print("❌ Social Logic Failed")

print("\n--- VERIFICATION COMPLETE ---")
