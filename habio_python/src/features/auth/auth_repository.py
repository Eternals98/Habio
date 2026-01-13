from src.services.http_client import client


def login(username: str, password: str):
    resp = client.login(username, password)
    # Expected: {"access_token": "...", "token_type": "bearer"}
    return resp


def register(username: str, email: str, password: str):
    resp = client.register(username, email, password)
    return resp


def me():
    return client.get("/auth/me")
