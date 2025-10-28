"""Screenshot Upload via App Store Connect API"""

import os
import requests
import hashlib
from pathlib import Path
from .api import AppStoreAPI


# Display size type mapping for App Store Connect API
DISPLAY_TYPES = {
    "iphone67": "APP_IPHONE_67",      # iPhone 16 Pro Max (1320x2868) - 6.7" Display
    "iphone65": "APP_IPHONE_65",      # iPhone 11/12/13/14 Pro Max (1284x2778) - 6.5" Display
    "iphone61": "APP_IPHONE_61",      # iPhone 14 Pro, 15 Pro (1179x2556)
    "ipad": "APP_IPAD_PRO_3GEN_129",  # iPad Pro 13" (2064x2752)
    "mac": "APP_DESKTOP"              # macOS Desktop (1440x900)
}


def get_file_info(file_path: str):
    """Get file size and checksum"""
    file_size = os.path.getsize(file_path)

    # Calculate MD5 checksum
    md5_hash = hashlib.md5()
    with open(file_path, 'rb') as f:
        for chunk in iter(lambda: f.read(4096), b''):
            md5_hash.update(chunk)

    return file_size, md5_hash.hexdigest()


def upload_screenshots(api: AppStoreAPI, version_id: str, screenshots_dir: str = "deployment/screenshots/en-US"):
    """
    Upload screenshots for app version

    Args:
        api: AppStoreAPI instance
        version_id: App Store version ID
        screenshots_dir: Directory containing screenshots
    """
    print(f"\n📸 Uploading screenshots from {screenshots_dir}...")

    screenshots_path = Path(screenshots_dir)
    if not screenshots_path.exists():
        print(f"❌ Screenshots directory not found: {screenshots_dir}")
        return False

    # Get version's localizations
    print(f"\n🔍 Getting version localizations...")
    localizations = api.get(f"appStoreVersions/{version_id}/appStoreVersionLocalizations")

    if not localizations.get("data"):
        print("❌ No localizations found for version")
        return False

    # Assume en-US localization (first one)
    localization_id = localizations["data"][0]["id"]
    locale = localizations["data"][0]["attributes"]["locale"]
    print(f"✅ Using localization: {locale} ({localization_id})")

    # Group screenshots by display type
    screenshot_groups = {
        "iphone67": [],
        "iphone65": [],
        "iphone61": [],
        "ipad": [],
        "mac": []
    }

    for file in sorted(screenshots_path.glob("*.png")):
        filename = file.name
        if filename.startswith("1_iphone67"):
            screenshot_groups["iphone67"].append(str(file))
        elif filename.startswith("1b_iphone65"):
            screenshot_groups["iphone65"].append(str(file))
        elif filename.startswith("2_iphone61"):
            screenshot_groups["iphone61"].append(str(file))
        elif filename.startswith("3_ipad"):
            screenshot_groups["ipad"].append(str(file))
        elif filename.startswith("4_mac"):
            screenshot_groups["mac"].append(str(file))

    # Upload each group
    success = True
    for display_key, files in screenshot_groups.items():
        if not files:
            continue

        display_type = DISPLAY_TYPES[display_key]
        print(f"\n📱 Processing {display_key} ({len(files)} screenshots)...")

        # Get or create screenshot set
        screenshot_set_id = get_or_create_screenshot_set(api, localization_id, display_type)
        if not screenshot_set_id:
            print(f"❌ Failed to create screenshot set for {display_key}")
            success = False
            continue

        # Upload each screenshot in the group
        for idx, file_path in enumerate(files, 1):
            print(f"\n  📤 Uploading {Path(file_path).name} ({idx}/{len(files)})...")
            if not upload_single_screenshot(api, screenshot_set_id, file_path):
                print(f"  ❌ Failed to upload {Path(file_path).name}")
                success = False
            else:
                print(f"  ✅ Uploaded {Path(file_path).name}")

    if success:
        print(f"\n✅ All screenshots uploaded successfully!")
    else:
        print(f"\n⚠️  Some screenshots failed to upload")

    return success


def get_or_create_screenshot_set(api: AppStoreAPI, localization_id: str, display_type: str) -> str:
    """Get existing screenshot set or create new one"""

    # Check if screenshot set already exists
    existing = api.get(f"appStoreVersionLocalizations/{localization_id}/appScreenshotSets")

    # Filter manually to find matching display type
    for screenshot_set in existing.get("data", []):
        if screenshot_set["attributes"]["screenshotDisplayType"] == display_type:
            screenshot_set_id = screenshot_set["id"]
            print(f"  ✅ Found existing screenshot set: {screenshot_set_id}")

            # Delete existing screenshots in the set
            screenshots = api.get(f"appScreenshotSets/{screenshot_set_id}/appScreenshots")
            if screenshots.get("data"):
                print(f"  🗑️  Deleting {len(screenshots['data'])} existing screenshots...")
                for screenshot in screenshots["data"]:
                    api.delete(f"appScreenshots/{screenshot['id']}")

            return screenshot_set_id

    # Create new screenshot set
    print(f"  📦 Creating new screenshot set for {display_type}...")
    payload = {
        "data": {
            "type": "appScreenshotSets",
            "attributes": {
                "screenshotDisplayType": display_type
            },
            "relationships": {
                "appStoreVersionLocalization": {
                    "data": {
                        "type": "appStoreVersionLocalizations",
                        "id": localization_id
                    }
                }
            }
        }
    }

    result = api.post("appScreenshotSets", payload)

    if "data" in result:
        screenshot_set_id = result["data"]["id"]
        print(f"  ✅ Created screenshot set: {screenshot_set_id}")
        return screenshot_set_id
    else:
        print(f"  ❌ Failed to create screenshot set: {result.get('error')}")
        return None


def upload_single_screenshot(api: AppStoreAPI, screenshot_set_id: str, file_path: str) -> bool:
    """Upload a single screenshot"""

    file_size, checksum = get_file_info(file_path)
    filename = Path(file_path).name

    # Step 1: Reserve screenshot slot
    reserve_payload = {
        "data": {
            "type": "appScreenshots",
            "attributes": {
                "fileName": filename,
                "fileSize": file_size
            },
            "relationships": {
                "appScreenshotSet": {
                    "data": {
                        "type": "appScreenshotSets",
                        "id": screenshot_set_id
                    }
                }
            }
        }
    }

    reserve_result = api.post("appScreenshots", reserve_payload)

    if "data" not in reserve_result:
        print(f"    ❌ Failed to reserve screenshot slot: {reserve_result.get('error')}")
        return False

    screenshot_id = reserve_result["data"]["id"]
    upload_operations = reserve_result["data"]["attributes"]["uploadOperations"]

    # Step 2: Upload file parts
    with open(file_path, 'rb') as f:
        for operation in upload_operations:
            offset = operation["offset"]
            length = operation["length"]
            url = operation["url"]
            headers = {header["name"]: header["value"] for header in operation.get("requestHeaders", [])}

            # Read the chunk
            f.seek(offset)
            chunk = f.read(length)

            # Upload chunk
            response = requests.put(url, data=chunk, headers=headers)
            if response.status_code not in [200, 201, 204]:
                print(f"    ❌ Failed to upload chunk at offset {offset}: {response.status_code}")
                return False

    # Step 3: Commit the upload
    commit_payload = {
        "data": {
            "type": "appScreenshots",
            "id": screenshot_id,
            "attributes": {
                "sourceFileChecksum": checksum,
                "uploaded": True
            }
        }
    }

    commit_result = api.patch(f"appScreenshots/{screenshot_id}", commit_payload)

    if "data" in commit_result:
        return True
    else:
        print(f"    ❌ Failed to commit screenshot: {commit_result.get('error')}")
        return False
