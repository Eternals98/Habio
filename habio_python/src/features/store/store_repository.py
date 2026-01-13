from src.services.http_client import client


def list_items():
    return client.get("/shop/")


def buy_item(item_id: int):
    return client.post("/shop/buy", json={"item_id": item_id})


def list_inventory():
    return client.get("/shop/inventory")
