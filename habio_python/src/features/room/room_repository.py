from src.services.http_client import client


def list_rooms():
    return client.get("/rooms/")


def create_room(name: str):
    return client.post("/rooms/", json={"name": name})
