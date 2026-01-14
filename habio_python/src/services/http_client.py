import os
import requests
from typing import Optional

BASE_URL = os.getenv("HABIO_API_URL", os.getenv("API_URL", "http://127.0.0.1:8000"))


class APIError(Exception):
    """Custom exception to preserve API error details"""
    def __init__(self, status_code: int, message: str):
        self.status_code = status_code
        self.message = message
        super().__init__(message)


class HttpClient:
    def __init__(self, base_url: Optional[str] = None):
        self.base_url = base_url or BASE_URL
        self.token: Optional[str] = None

    def set_token(self, token: str):
        self.token = token

    def _headers(self):
        headers = {"Content-Type": "application/json"}
        if self.token:
            headers["Authorization"] = f"Bearer {self.token}"
        return headers

    def post(self, path: str, json: dict = None, timeout: int = 10):
        url = f"{self.base_url}{path}"
        print(f"[HTTP POST] {url} - payload: {json}")
        try:
            resp = requests.post(url, json=json, headers=self._headers(), timeout=timeout)
            print(f"[HTTP RESPONSE] Status: {resp.status_code}, Body: {resp.text}")
            resp.raise_for_status()
            return resp.json()
        except requests.exceptions.HTTPError as e:
            try:
                error_data = resp.json()
                detail = error_data.get("detail", str(e))
                print(f"[HTTP ERROR] {detail}")
                raise APIError(resp.status_code, detail)
            except (ValueError, AttributeError):
                print(f"[HTTP ERROR] {e}")
                raise APIError(resp.status_code, str(e))
        except Exception as e:
            print(f"[HTTP ERROR] {e}")
            raise

    def get(self, path: str, params: dict = None, timeout: int = 10):
        url = f"{self.base_url}{path}"
        print(f"[HTTP GET] {url} - params: {params}")
        try:
            resp = requests.get(url, params=params, headers=self._headers(), timeout=timeout)
            print(f"[HTTP RESPONSE] Status: {resp.status_code}, Body: {resp.text}")
            resp.raise_for_status()
            return resp.json()
        except requests.exceptions.HTTPError as e:
            try:
                error_data = resp.json()
                detail = error_data.get("detail", str(e))
                print(f"[HTTP ERROR] {detail}")
                raise APIError(resp.status_code, detail)
            except (ValueError, AttributeError):
                print(f"[HTTP ERROR] {e}")
                raise APIError(resp.status_code, str(e))
        except Exception as e:
            print(f"[HTTP ERROR] {e}")
            raise

    def put(self, path: str, json: dict = None, timeout: int = 10):
        url = f"{self.base_url}{path}"
        resp = requests.put(url, json=json, headers=self._headers(), timeout=timeout)
        resp.raise_for_status()
        return resp.json()

    def delete(self, path: str, timeout: int = 10):
        url = f"{self.base_url}{path}"
        resp = requests.delete(url, headers=self._headers(), timeout=timeout)
        resp.raise_for_status()
        return resp.json() if resp.text else {"ok": True}

    # Convenience helpers
    def login(self, username: str, password: str):
        return self.post("/auth/login", json={"username": username, "password": password})

    def register(self, username: str, email: str, password: str):
        return self.post("/auth/register", json={"username": username, "email": email, "password": password})


# Single global client for simple usage in the app
client = HttpClient()

# Load token from session if available
try:
    from src.core.session import get_token
    token = get_token()
    if token:
        client.set_token(token)
except Exception:
    pass
