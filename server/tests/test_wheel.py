import os
from fastapi.testclient import TestClient
from app.main import app
from app.db import init_db
from app.models import WheelPrize, ShopItem

client = TestClient(app)


def setup_module(module):
    os.environ["DATABASE_URL"] = "sqlite:///./test_habio.db"
    init_db()


def test_wheel_spin_flow():
    # Ensure there is at least one shop item and wheel prize
    if ShopItem.select().count() == 0:
        ShopItem.create(name="Test Item", description="desc", icon_path="item.png", price=1, category="misc", value=0)
    if WheelPrize.select().count() == 0:
        wp = WheelPrize.create(name="10 coins", prize_type="coins", value=10, weight=10)

    # Register a user
    resp = client.post("/auth/register", json={"username": "wheeluser", "email": "wheel@example.com", "password": "secret"})
    assert resp.status_code == 200
    token = resp.json().get("access_token")
    assert token

    headers = {"Authorization": f"Bearer {token}"}

    # Get prizes
    resp2 = client.get("/wheel/", headers=headers)
    assert resp2.status_code == 200
    prizes = resp2.json()
    assert isinstance(prizes, list)

    # Spin
    resp3 = client.post("/wheel/spin", headers=headers)
    assert resp3.status_code == 200
    data = resp3.json()
    assert data.get("ok") is True
    assert "prize" in data
