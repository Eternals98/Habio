import os
from fastapi.testclient import TestClient
from app.main import app
from app.db import init_db

client = TestClient(app)


def setup_module(module):
    os.environ["DATABASE_URL"] = "sqlite:///./test_habio_rooms.db"
    from app.db import db
    from app import models
    db.drop_tables([models.User, models.Friend, models.Room, models.Habit, models.ShopItem, models.InventoryItem, models.Gift, models.WheelPrize, models.Migration], safe=True)
    init_db()


def test_create_and_list_rooms():
    r = client.post('/auth/register', json={'username': 'roomuser', 'email': 'r@ex.com', 'password': 'secret'})
    assert r.status_code == 200
    token = r.json().get('access_token')
    headers = {'Authorization': f'Bearer {token}'}

    # create a room
    cr = client.post('/rooms/', json={'name': 'Living'}, headers=headers)
    assert cr.status_code == 200
    data = cr.json()
    assert data.get('name') == 'Living'

    # list rooms
    lst = client.get('/rooms/', headers=headers)
    assert lst.status_code == 200
    rooms = lst.json()
    assert any(r['name'] == 'Living' for r in rooms)
