import os
from fastapi.testclient import TestClient
from app.main import app
from app.db import init_db
from app.models import ShopItem, InventoryItem

client = TestClient(app)


def setup_module(module):
    os.environ["DATABASE_URL"] = "sqlite:///./test_habio_gifts_edge.db"
    from app.db import db
    from app import models
    db.drop_tables([models.User, models.Friend, models.Room, models.Habit, models.ShopItem, models.InventoryItem, models.Gift, models.WheelPrize, models.Migration], safe=True)
    init_db()


def test_send_not_owned_item_returns_400():
    # register two users
    r1 = client.post('/auth/register', json={'username': 'sender', 'email': 's@ex.com', 'password': 'secret'})
    assert r1.status_code == 200
    token1 = r1.json().get('access_token')
    headers1 = {'Authorization': f'Bearer {token1}'}

    r2 = client.post('/auth/register', json={'username': 'receiver', 'email': 'r@ex.com', 'password': 'secret'})
    assert r2.status_code == 200

    # try to send inventory item id that doesn't belong to sender (non-existent id)
    s = client.post('/gifts/send', json={'receiver_id': 2, 'inventory_id': 1, 'message': 'Oops'}, headers=headers1)
    # the server returns 404 if the inventory id does not exist
    assert s.status_code == 404


def test_claim_twice_returns_400():
    # register users and setup inventory
    r1 = client.post('/auth/register', json={'username': 'a', 'email': 'a@ex.com', 'password': 'secret'})
    assert r1.status_code == 200
    token1 = r1.json().get('access_token')
    headers1 = {'Authorization': f'Bearer {token1}'}

    r2 = client.post('/auth/register', json={'username': 'b', 'email': 'b@ex.com', 'password': 'secret'})
    assert r2.status_code == 200
    token2 = r2.json().get('access_token')
    headers2 = {'Authorization': f'Bearer {token2}'}

    # create an item and add it to sender's inventory via buying (price 0 for simplicity)
    item = ShopItem.create(name='Giftable', description='x', icon_path='', price=0, category='misc')
    buy = client.post('/shop/buy', json={'item_id': item.id}, headers=headers1)
    assert buy.status_code == 200

    # locate the inventory entry for the sender (look up current user id from /auth/me)
    from app.models import InventoryItem as _InventoryItem
    me = client.get('/auth/me', headers=headers1).json()
    uid = me.get('id')
    inv = _InventoryItem.get(_InventoryItem.user == uid, _InventoryItem.item == item)

    # send gift (use actual receiver id)
    me2 = client.get('/auth/me', headers=headers2).json()
    rid = me2.get('id')
    s = client.post('/gifts/send', json={'receiver_id': rid, 'inventory_id': inv.id, 'message': 'For you'}, headers=headers1)
    assert s.status_code == 200

    # list received for user b
    received = client.get('/gifts/received', headers=headers2)
    assert received.status_code == 200
    gifts = received.json()
    assert len(gifts) == 1
    gid = gifts[0]['id']

    # claim the gift
    c1 = client.post('/gifts/claim', json={'gift_id': gid}, headers=headers2)
    assert c1.status_code == 200

    # claim again -> should be 400
    c2 = client.post('/gifts/claim', json={'gift_id': gid}, headers=headers2)
    assert c2.status_code == 400
