import os
from fastapi.testclient import TestClient

from app.main import app
from app.db import init_db

client = TestClient(app)


def setup_module(module):
    # Ensure database exists and tables
    os.environ["DATABASE_URL"] = "sqlite:///./test_habio.db"
    init_db()


def test_register_and_login_flow():
    username = "testuser"
    email = "test@example.com"
    password = "password123"

    # Register
    resp = client.post("/auth/register", json={"username": username, "email": email, "password": password})
    assert resp.status_code == 200
    data = resp.json()
    assert "access_token" in data

    # Login
    resp2 = client.post("/auth/login", json={"username": username, "password": password})
    assert resp2.status_code == 200
    data2 = resp2.json()
    assert "access_token" in data2

    # Me endpoint
    headers = {"Authorization": f"Bearer {data2['access_token']}"}
    resp3 = client.get("/auth/me", headers=headers)
    assert resp3.status_code == 200
    me = resp3.json()
    assert me["username"] == username
