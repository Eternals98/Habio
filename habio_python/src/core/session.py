import os
import json

SESSION_FILE = os.getenv("HABIO_SESSION_FILE", ".habio_session.json")


def _read_session():
    if not os.path.exists(SESSION_FILE):
        return {}
    try:
        with open(SESSION_FILE, "r", encoding="utf-8") as f:
            return json.load(f)
    except Exception:
        return {}


def _write_session(data: dict):
    with open(SESSION_FILE, "w", encoding="utf-8") as f:
        json.dump(data, f)


def set_token(token: str):
    data = _read_session()
    data["access_token"] = token
    _write_session(data)


def get_token() -> str | None:
    data = _read_session()
    token = data.get("access_token")
    if isinstance(token, str) and token.lower().startswith("bearer "):
        return token.split(" ", 1)[1]
    return token


def clear_token():
    data = _read_session()
    if "access_token" in data:
        del data["access_token"]
        _write_session(data)
