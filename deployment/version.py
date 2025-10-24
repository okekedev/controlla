"""Version Management"""

from .api import AppStoreAPI
from .metadata import upload_version_metadata


def create_version(api: AppStoreAPI, app_id: str, version: str) -> str:
    """
    Create new app version
    Returns version_id or None
    """
    print(f"\n📦 Creating version {version}...")

    payload = {
        "data": {
            "type": "appStoreVersions",
            "attributes": {
                "platform": "IOS",
                "versionString": version
            },
            "relationships": {
                "app": {
                    "data": {
                        "type": "apps",
                        "id": app_id
                    }
                }
            }
        }
    }

    result = api.post("appStoreVersions", payload)

    if "data" in result:
        version_id = result["data"]["id"]
        print(f"✅ Version created: {version_id}")

        # Upload version-specific metadata
        upload_version_metadata(api, version_id)

        return version_id
    else:
        # Check if version already exists
        if "ENTITY_ALREADY_EXISTS" in result.get("error", ""):
            print(f"ℹ️  Version {version} already exists, fetching it...")
            existing = api.get(f"apps/{app_id}/appStoreVersions?filter[versionString]={version}&filter[appStoreState]=PREPARE_FOR_SUBMISSION")
            if existing.get("data"):
                version_id = existing["data"][0]["id"]
                print(f"✅ Using existing version: {version_id}")
                return version_id

        print(f"❌ Failed to create version: {result.get('error')}")
        return None


def get_latest_build(api: AppStoreAPI, app_id: str) -> str:
    """Get the latest uploaded build"""
    print(f"\n🔍 Finding latest build...")

    result = api.get(f"builds?filter[app]={app_id}&sort=-uploadedDate&limit=1")

    if result.get("data") and len(result["data"]) > 0:
        build_id = result["data"][0]["id"]
        version = result["data"][0]["attributes"]["version"]
        print(f"✅ Found build: {version} ({build_id})")
        return build_id

    print("❌ No builds found")
    return None


def attach_build_to_version(api: AppStoreAPI, version_id: str, build_id: str) -> bool:
    """Attach build to version"""
    print(f"\n🔗 Attaching build to version...")

    payload = {
        "data": {
            "type": "appStoreVersions",
            "id": version_id,
            "relationships": {
                "build": {
                    "data": {
                        "type": "builds",
                        "id": build_id
                    }
                }
            }
        }
    }

    result = api.patch(f"appStoreVersions/{version_id}", payload)

    if "data" in result:
        print("✅ Build attached to version")
        return True
    else:
        print(f"❌ Failed to attach build: {result.get('error')}")
        return False


def submit_for_review(api: AppStoreAPI, version_id: str) -> bool:
    """Submit version for App Store review"""
    print(f"\n📬 Submitting for review...")

    payload = {
        "data": {
            "type": "appStoreReviewSubmissions",
            "relationships": {
                "appStoreVersion": {
                    "data": {
                        "type": "appStoreVersions",
                        "id": version_id
                    }
                }
            }
        }
    }

    result = api.post("appStoreReviewSubmissions", payload)

    if "data" in result:
        print("✅ Submitted for review")
        return True
    else:
        print(f"❌ Failed to submit: {result.get('error')}")
        return False
