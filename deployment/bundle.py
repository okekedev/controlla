"""Bundle ID Registration"""

from .api import AppStoreAPI
from .config import BUNDLE_ID, APP_NAME


def register_bundle_id(api: AppStoreAPI) -> bool:
    """
    Register bundle ID in Developer Portal via API
    Returns True if successful or already exists
    """
    print(f"\n🔧 Registering Bundle ID: {BUNDLE_ID}")

    # Check if exists first
    result = api.get(f"bundleIds?filter[identifier]={BUNDLE_ID}")
    if result.get("data"):
        print(f"✅ Bundle ID already registered")
        return True

    # Create new bundle ID (use IOS for universal iOS + macOS apps)
    payload = {
        "data": {
            "type": "bundleIds",
            "attributes": {
                "name": APP_NAME,
                "identifier": BUNDLE_ID,
                "platform": "IOS"
            }
        }
    }

    result = api.post("bundleIds", payload)
    if "data" in result:
        print(f"✅ Bundle ID registered successfully")
        return True
    else:
        print(f"❌ Failed to register bundle ID: {result.get('error')}")
        return False


def get_app_id(api: AppStoreAPI) -> str:
    """
    Get app ID from App Store Connect
    Returns app_id or None if not found
    """
    print(f"\n🔍 Looking for app: {BUNDLE_ID}")
    result = api.get(f"apps?filter[bundleId]={BUNDLE_ID}")

    if result.get("data") and len(result["data"]) > 0:
        app_id = result["data"][0]["id"]
        print(f"✅ Found app: {app_id}")
        return app_id

    print("❌ App not found in App Store Connect")
    print("\n⚠️  MANUAL STEP REQUIRED (one-time only):")
    print("    Apple's API does not support creating apps programmatically.")
    print("    You must create it manually:")
    print()
    print("    1. Go to: https://appstoreconnect.apple.com")
    print("    2. My Apps → + → New App")
    print(f"    3. Name: {APP_NAME}")
    print(f"    4. Bundle ID: {BUNDLE_ID} (now in dropdown!)")
    print(f"    5. SKU: controlla-2025")
    print()
    print("    Then run this script again.")
    return None
