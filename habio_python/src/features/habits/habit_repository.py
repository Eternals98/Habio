from src.services.http_client import client


def list_habits():
    return client.get("/habits/")


def create_habit(name: str, room_id: int = None):
    payload = {"name": name}
    if room_id:
        payload["room_id"] = room_id
    return client.post("/habits/", json=payload)


def complete_habit(habit_id: int):
    return client.put(f"/habits/{habit_id}/complete") if hasattr(client, 'put') else client.post(f"/habits/{habit_id}/complete")
