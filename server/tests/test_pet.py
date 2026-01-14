import os
from fastapi.testclient import TestClient
from app.main import app
from app.db import init_db
from app.models import User

client = TestClient(app)


def setup_module(module):
    os.environ["DATABASE_URL"] = "sqlite:///./test_habio.db"
    from app.db import db
    from app import models
    db.drop_tables([models.User, models.Friend, models.Room, models.Habit, models.ShopItem, models.InventoryItem, models.Gift, models.WheelPrize, models.Migration], safe=True)
    init_db()


def test_pet_chat():
    # Register user
    r = client.post('/auth/register', json={'username':'petuser','email':'pet@ex.com','password':'secret'})
    assert r.status_code == 200
    token = r.json().get('access_token')
    headers = {'Authorization': f'Bearer {token}'}
    # Chat
    resp = client.post('/pet/chat', json={'message':'I want to exercise'}, headers=headers)
    assert resp.status_code == 200
    data = resp.json()
    assert 'reply' in data
    assert 'personality' in data

    # List personalities
    r2 = client.get('/pet/personalities')
    assert r2.status_code == 200
    names = [p['name'] for p in r2.json()]
    assert 'alegre' in names

    # Set a specific personality and verify
    r3 = client.post('/pet/personality', json={'personality':'energetico'}, headers=headers)
    assert r3.status_code == 200
    assert r3.json().get('personality') == 'energetico'

    resp2 = client.post('/pet/chat', json={'message':'Run!'}, headers=headers)
    assert resp2.status_code == 200
    assert resp2.json().get('personality') == 'energetico'
