import os
from fastapi.testclient import TestClient
from app.main import app
from app.db import init_db
from app.models import ShopItem

client = TestClient(app)


def setup_module(module):
    os.environ["DATABASE_URL"] = "sqlite:///./test_habio.db"
    from app.db import db
    from app import models
    db.drop_tables([models.User, models.Friend, models.Room, models.Habit, models.ShopItem, models.InventoryItem, models.Gift, models.WheelPrize, models.Migration], safe=True)
    init_db()


def test_send_and_claim_gift_flow():
    # create a shop item
    if ShopItem.select().count() == 0:
        ShopItem.create(name='Teddy', description='Cute', icon_path='teddy.png', price=10, category='accessory', value=0)

    # register sender and receiver
    r1 = client.post('/auth/register', json={'username':'sender','email':'s@e.com','password':'p'})
    r2 = client.post('/auth/register', json={'username':'rcv','email':'r@e.com','password':'p'})
    assert r1.status_code == 200 and r2.status_code == 200
    token1 = r1.json()['access_token']
    token2 = r2.json()['access_token']
    headers1 = {'Authorization': f'Bearer {token1}'}
    headers2 = {'Authorization': f'Bearer {token2}'}

    # Credit sender with coins so they can buy
    from app.models import User
    sender = User.get(User.username == 'sender')
    sender.coins = 100
    sender.save()

    # Buy item for sender
    buy = client.post('/shop/buy', json={'item_id': 1}, headers=headers1)
    assert buy.status_code == 200

    # list sender inventory to get inventory id
    inv = client.get('/shop/inventory', headers=headers1).json()
    assert len(inv) > 0
    inv_id = inv[0]['item_id']

    # send gift (note: using inventory item id may be item_id, our server expects inventory id, but SocialController uses inventory id; for API we use item_id semantics)
    s = client.post('/gifts/send', json={'receiver_id':2, 'inventory_id': 1, 'message':'Hi!'}, headers=headers1)
    assert s.status_code == 200

    # receiver lists gifts
    rec = client.get('/gifts/received', headers=headers2)
    assert rec.status_code == 200
    gifts = rec.json()
    assert len(gifts) >= 1

    # claim gift
    gift_id = gifts[0]['id']
    c = client.post('/gifts/claim', json={'gift_id': gift_id}, headers=headers2)
    assert c.status_code == 200
