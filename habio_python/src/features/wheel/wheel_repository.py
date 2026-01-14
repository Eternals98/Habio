from src.services.http_client import client


def list_prizes():
    return client.get("/wheel/")


def spin():
    return client.post("/wheel/spin")
