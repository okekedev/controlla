"""Metadata Upload"""

from pathlib import Path
from .api import AppStoreAPI


def upload_metadata(api: AppStoreAPI, app_id: str) -> bool:
    """
    Upload app metadata (name, subtitle, description, etc.)
    """
    print(f"\n📝 Uploading metadata...")

    # Get app info localization ID
    result = api.get(f"apps/{app_id}/appInfos")
    if not result.get("data"):
        print("❌ Could not find app info")
        return False

    app_info_id = result["data"][0]["id"]

    # Get localization
    result = api.get(f"appInfos/{app_info_id}/appInfoLocalizations")
    if not result.get("data"):
        print("❌ Could not find localization")
        return False

    localization_id = result["data"][0]["id"]

    # Read metadata files
    metadata_path = Path("fastlane/metadata/en-US")

    metadata = {}
    if (metadata_path / "name.txt").exists():
        metadata["name"] = (metadata_path / "name.txt").read_text().strip()
    if (metadata_path / "subtitle.txt").exists():
        metadata["subtitle"] = (metadata_path / "subtitle.txt").read_text().strip()
    if (metadata_path / "privacy_url.txt").exists():
        metadata["privacyPolicyUrl"] = (metadata_path / "privacy_url.txt").read_text().strip()

    # Update app info localization
    payload = {
        "data": {
            "type": "appInfoLocalizations",
            "id": localization_id,
            "attributes": metadata
        }
    }

    result = api.patch(f"appInfoLocalizations/{localization_id}", payload)
    if "data" in result:
        print("✅ App info metadata uploaded")
    else:
        print(f"⚠️  App info upload failed: {result.get('error')}")

    # Now upload version-specific metadata (description, keywords, release notes)
    # This requires a version to exist first, so we'll do it in version.py

    return True


def upload_version_metadata(api: AppStoreAPI, version_id: str) -> bool:
    """
    Upload version-specific metadata (description, keywords, release notes)
    """
    print(f"\n📝 Uploading version metadata...")

    # Get version localization
    result = api.get(f"appStoreVersions/{version_id}/appStoreVersionLocalizations")
    if not result.get("data"):
        print("❌ Could not find version localization")
        return False

    localization_id = result["data"][0]["id"]

    # Read metadata files
    metadata_path = Path("fastlane/metadata/en-US")

    metadata = {}
    if (metadata_path / "description.txt").exists():
        metadata["description"] = (metadata_path / "description.txt").read_text().strip()
    if (metadata_path / "keywords.txt").exists():
        metadata["keywords"] = (metadata_path / "keywords.txt").read_text().strip()
    if (metadata_path / "release_notes.txt").exists():
        metadata["whatsNew"] = (metadata_path / "release_notes.txt").read_text().strip()
    if (metadata_path / "promotional_text.txt").exists():
        metadata["promotionalText"] = (metadata_path / "promotional_text.txt").read_text().strip()
    if (metadata_path / "support_url.txt").exists():
        metadata["supportUrl"] = (metadata_path / "support_url.txt").read_text().strip()
    if (metadata_path / "marketing_url.txt").exists():
        metadata["marketingUrl"] = (metadata_path / "marketing_url.txt").read_text().strip()

    # Update version localization
    payload = {
        "data": {
            "type": "appStoreVersionLocalizations",
            "id": localization_id,
            "attributes": metadata
        }
    }

    result = api.patch(f"appStoreVersionLocalizations/{localization_id}", payload)
    if "data" in result:
        print("✅ Version metadata uploaded")
        return True
    else:
        print(f"❌ Version metadata upload failed: {result.get('error')}")
        return False
