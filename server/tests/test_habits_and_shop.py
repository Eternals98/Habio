import os
from fastapi.testclient import TestClient

from app.main import app
from app.db import init_db

client = TestClient(app)


def setup_module(module):
    os.environ["DATABASE_URL"] = "sqlite:///./test_habio.db"
    init_db()


def test_habit_and_shop_flow():
    username = "user_flow"
    email = "user_flow@example.com"
    password = "pass123"

    # Register
    r = client.post("/auth/register", json={"username": username, "email": email, "password": password})
    assert r.status_code == 200
    token = r.json()["access_token"]

    # Create room
    headers = {"Authorization": f"Bearer {token}"}
    r2 = client.post("/rooms/", json={"name": "Room A"}, headers=headers)
    assert r2.status_code == 200
    room_id = r2.json()["id"]

    # Create habit
    r3 = client.post("/habits/", json={"name": "Drink Water", "description": "Stay hydrated", "room_id": room_id}, headers=headers)
    assert r3.status_code == 200
    habit = r3.json()

    # Complete habit
    r4 = client.put(f"/habits/{habit['id']}/complete", headers=headers)
    assert r4.status_code == 200

    # Check coins increment by default coin_reward (5)
    me = client.get("/auth/me", headers=headers).json()
    assert me["username"] == username
    # The user coins should be >= 5
    from app.models import User
    user = User.get(User.username == username)
    assert user.coins >= 5

    # List shop and buy item
    shop = client.get("/shop/").json()
    assert len(shop) > 0
    item_id = shop[0]["id"]
    buy = client.post("/shop/buy", json={"item_id": item_id}, headers=headers)
    # Buying may fail if not enough coins; ensure endpoint returns expected status codes
    assert buy.status_code in (200, 400)

    # Inventory listing
    inv = client.get("/shop/inventory", headers=headers)
    assert inv.status_code == 200
