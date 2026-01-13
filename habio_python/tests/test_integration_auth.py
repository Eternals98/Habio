import os
from src.services.http_client import client

# Assumes server is running at HABIO_API_URL or default http://localhost:8000

def test_register_and_login():
    username = "ci_test_user"
    email = "ci_test@example.com"
    password = "secret123"

    # Register
    r = client.post("/auth/register", json={"username": username, "email": email, "password": password})
    assert "access_token" in r

    # Login
    r2 = client.post("/auth/login", json={"username": username, "password": password})
    assert "access_token" in r2

    # Me
    client.set_token(r2["access_token"])
    me = client.get("/auth/me")
    assert me["username"] == username
