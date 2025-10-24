#!/bin/bash
# Register Bundle ID via App Store Connect API

# Load environment variables
source .env

# Generate JWT token (simplified - using Python)
python3 - <<EOF
import jwt
import time
from pathlib import Path

# Read the private key
with open("$APP_STORE_CONNECT_API_KEY_KEY_FILEPATH", "r") as f:
    private_key = f.read()

# Create JWT token
token = jwt.encode(
    {
        "iss": "$APP_STORE_CONNECT_API_KEY_ISSUER_ID",
        "exp": int(time.time()) + 1200,  # 20 minutes
        "aud": "appstoreconnect-v1"
    },
    private_key,
    algorithm="ES256",
    headers={
        "kid": "$APP_STORE_CONNECT_API_KEY_KEY_ID",
        "typ": "JWT"
    }
)
print(token)
EOF
