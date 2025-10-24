"""Build and Upload"""

import subprocess
from pathlib import Path
from .config import (
    XCODE_SCHEME, ARCHIVE_PATH, EXPORT_PATH,
    IPA_NAME, EXPORT_OPTIONS, KEY_ID, ISSUER_ID
)


def update_version_numbers(version: str, build_number: str) -> bool:
    """Update version and build number in Xcode project"""
    print(f"\n🔢 Updating version to {version} (build {build_number})...")

    try:
        # Update marketing version
        subprocess.run([
            "xcrun", "agvtool", "new-marketing-version", version
        ], check=True, capture_output=True)

        # Update build number
        subprocess.run([
            "xcrun", "agvtool", "new-version", "-all", build_number
        ], check=True, capture_output=True)

        print(f"✅ Version updated")
        return True
    except subprocess.CalledProcessError as e:
        print(f"❌ Failed to update version: {e.stderr.decode()}")
        return False


def build_archive() -> bool:
    """Build Xcode archive"""
    print(f"\n🔨 Building archive...")

    # Clean build directory
    Path("build").mkdir(exist_ok=True)

    try:
        result = subprocess.run([
            "xcodebuild",
            "-scheme", XCODE_SCHEME,
            "-configuration", "Release",
            "-archivePath", ARCHIVE_PATH,
            "-destination", "generic/platform=iOS",
            "archive"
        ], check=True, capture_output=True, text=True)

        print(f"✅ Archive built successfully")
        return True
    except subprocess.CalledProcessError as e:
        print(f"❌ Build failed:")
        print(e.stderr)
        return False


def export_ipa() -> bool:
    """Export IPA from archive"""
    print(f"\n📦 Exporting IPA...")

    try:
        result = subprocess.run([
            "xcodebuild",
            "-exportArchive",
            "-archivePath", ARCHIVE_PATH,
            "-exportPath", EXPORT_PATH,
            "-exportOptionsPlist", EXPORT_OPTIONS
        ], check=True, capture_output=True, text=True)

        print(f"✅ IPA exported successfully")
        return True
    except subprocess.CalledProcessError as e:
        print(f"❌ Export failed:")
        print(e.stderr)
        return False


def upload_build() -> bool:
    """Upload IPA to App Store Connect using altool"""
    print(f"\n⬆️  Uploading build to App Store Connect...")

    ipa_path = f"{EXPORT_PATH}/{IPA_NAME}"

    if not Path(ipa_path).exists():
        print(f"❌ IPA not found: {ipa_path}")
        return False

    try:
        # Set environment variable for API key location
        env = {"API_PRIVATE_KEYS_DIR": "./fastlane"}

        result = subprocess.run([
            "xcrun", "altool",
            "--upload-app",
            "-f", ipa_path,
            "--type", "ios",
            "--apiKey", KEY_ID,
            "--apiIssuer", ISSUER_ID
        ], check=True, capture_output=True, text=True, env={**subprocess.os.environ, **env})

        print("✅ Build uploaded successfully")
        print("   Processing may take a few minutes in App Store Connect")
        return True
    except subprocess.CalledProcessError as e:
        print(f"❌ Upload failed:")
        print(e.stderr)
        return False


def build_and_upload(version: str, build_number: str) -> bool:
    """Complete build and upload workflow"""
    steps = [
        ("Update version numbers", lambda: update_version_numbers(version, build_number)),
        ("Build archive", build_archive),
        ("Export IPA", export_ipa),
        ("Upload to App Store", upload_build)
    ]

    for step_name, step_func in steps:
        if not step_func():
            print(f"\n❌ Build failed at: {step_name}")
            return False

    return True
