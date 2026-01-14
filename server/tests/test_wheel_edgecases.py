import os
from fastapi.testclient import TestClient
from app.main import app
from app.db import init_db
from app.models import WheelPrize

client = TestClient(app)


def setup_module(module):
    os.environ["DATABASE_URL"] = "sqlite:///./test_habio_wheel.db"
    from app.db import db
    from app import models
    db.drop_tables([models.User, models.Friend, models.Room, models.Habit, models.ShopItem, models.InventoryItem, models.Gift, models.WheelPrize, models.Migration], safe=True)
    init_db()


def test_spin_no_prizes_returns_404():
    r = client.post('/auth/register', json={'username': 'wheeluser', 'email': 'w@ex.com', 'password': 'secret'})
    assert r.status_code == 200
    token = r.json().get('access_token')
    headers = {'Authorization': f'Bearer {token}'}

    # remove seeded prizes to simulate empty wheel
    from app.models import WheelPrize as _WP
    _WP.delete().execute()

    resp = client.post('/wheel/spin', headers=headers)
    assert resp.status_code == 404


def test_spin_item_prize_missing_shopitem_returns_500():
    r = client.post('/auth/register', json={'username': 'wheel2', 'email': 'w2@ex.com', 'password': 'secret'})
    assert r.status_code == 200
    token = r.json().get('access_token')
    headers = {'Authorization': f'Bearer {token}'}

    # clear any existing prizes and create only a ghost prize that references a missing shop item
    from app.models import WheelPrize as _WP
    _WP.delete().execute()
    _WP.create(name='Ghost Item', prize_type='item', value=9999, weight=1)

    resp = client.post('/wheel/spin', headers=headers)
    assert resp.status_code == 500
