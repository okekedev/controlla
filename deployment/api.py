"""App Store Connect API Client"""

import jwt
import time
import requests
from typing import Optional, Dict, Any
from .config import KEY_ID, ISSUER_ID, KEY_FILE, BASE_URL


class AppStoreAPI:
    """Wrapper for App Store Connect API with JWT authentication"""

    def __init__(self):
        self.token = self._generate_jwt()
        self.headers = {
            "Authorization": f"Bearer {self.token}",
            "Content-Type": "application/json"
        }

    def _generate_jwt(self) -> str:
        """Generate JWT token for API authentication"""
        with open(KEY_FILE, 'r') as f:
            private_key = f.read()

        token = jwt.encode(
            {
                "iss": ISSUER_ID,
                "exp": int(time.time()) + 1200,  # 20 minutes
                "aud": "appstoreconnect-v1"
            },
            private_key,
            algorithm="ES256",
            headers={"kid": KEY_ID, "typ": "JWT"}
        )
        return token

    def get(self, endpoint: str) -> Dict[Any, Any]:
        """GET request"""
        url = f"{BASE_URL}/{endpoint}"
        response = requests.get(url, headers=self.headers)

        if response.status_code == 200:
            return response.json()
        else:
            return {
                "error": response.text,
                "status": response.status_code
            }

    def post(self, endpoint: str, data: Dict) -> Dict[Any, Any]:
        """POST request"""
        url = f"{BASE_URL}/{endpoint}"
        response = requests.post(url, headers=self.headers, json=data)

        if response.status_code in [200, 201]:
            return response.json()
        else:
            return {
                "error": response.text,
                "status": response.status_code
            }

    def patch(self, endpoint: str, data: Dict) -> Dict[Any, Any]:
        """PATCH request"""
        url = f"{BASE_URL}/{endpoint}"
        response = requests.patch(url, headers=self.headers, json=data)

        if response.status_code == 200:
            return response.json()
        else:
            return {
                "error": response.text,
                "status": response.status_code
            }

    def delete(self, endpoint: str) -> bool:
        """DELETE request"""
        url = f"{BASE_URL}/{endpoint}"
        response = requests.delete(url, headers=self.headers)

        if response.status_code == 204:
            return True
        else:
            return False
