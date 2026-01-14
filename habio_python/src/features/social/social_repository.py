from src.services.http_client import client


def send_gift(receiver_id: int, inventory_id: int, message: str = None):
    return client.post('/gifts/send', json={'receiver_id': receiver_id, 'inventory_id': inventory_id, 'message': message})


def list_received():
    return client.get('/gifts/received')


def claim_gift(gift_id: int):
    return client.post('/gifts/claim', json={'gift_id': gift_id})
