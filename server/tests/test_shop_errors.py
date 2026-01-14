import os
from fastapi.testclient import TestClient
from app.main import app
from app.db import init_db

client = TestClient(app)


def setup_module(module):
    os.environ["DATABASE_URL"] = "sqlite:///./test_habio_shop_errors.db"
    from app.db import db
    from app import models
    db.drop_tables([models.User, models.Friend, models.Room, models.Habit, models.ShopItem, models.InventoryItem, models.Gift, models.WheelPrize, models.Migration], safe=True)
    init_db()


def test_buy_nonexistent_item_returns_404():
    r = client.post('/auth/register', json={'username': 'shopuser', 'email': 's@ex.com', 'password': 'secret'})
    assert r.status_code == 200
    token = r.json().get('access_token')
    headers = {'Authorization': f'Bearer {token}'}

    resp = client.post('/shop/buy', json={'item_id': 9999}, headers=headers)
    assert resp.status_code == 404


def test_buy_insufficient_coins_returns_400():
    r = client.post('/auth/register', json={'username': 'pooruser', 'email': 'p@ex.com', 'password': 'secret'})
    assert r.status_code == 200
    token = r.json().get('access_token')
    headers = {'Authorization': f'Bearer {token}'}

    # create an expensive item
    from app.models import ShopItem
    ShopItem.create(name='Expensive', description='Too pricey', icon_path='', price=1000, category='misc')

    resp = client.post('/shop/buy', json={'item_id': 1}, headers=headers)
    assert resp.status_code == 400
    assert 'Not enough coins' in resp.json().get('detail', '')
