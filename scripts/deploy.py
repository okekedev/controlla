#!/usr/bin/env python3
"""
Controlla App Store Deployment
Complete automation using App Store Connect API

Usage:
    ./deploy.py                    # Full deployment workflow
    ./deploy.py --setup            # Setup only (bundle ID + app check)
    ./deploy.py --metadata         # Upload metadata only
    ./deploy.py --build 1.0.0 1    # Build and upload only
    ./deploy.py --screenshots      # Upload screenshots only
"""

import sys
from deployment import AppStoreAPI
from deployment.bundle import register_bundle_id, get_app_id
from deployment.metadata import upload_metadata
from deployment.build import build_and_upload
from deployment.screenshots import upload_screenshots
from deployment.version import (
    create_version,
    get_latest_build,
    attach_build_to_version,
    submit_for_review
)


def print_header():
    print("=" * 70)
    print("  Controlla - App Store Deployment")
    print("  TRUE Automation with App Store Connect API")
    print("=" * 70)


def main():
    print_header()

    # Parse arguments
    args = sys.argv[1:]
    setup_only = "--setup" in args
    metadata_only = "--metadata" in args
    build_only = "--build" in args
    screenshots_only = "--screenshots" in args

    # Initialize API
    api = AppStoreAPI()

    # Step 1: Register Bundle ID
    if not register_bundle_id(api):
        print("\n❌ Failed to register bundle ID")
        return 1

    # Step 2: Get App ID
    app_id = get_app_id(api)
    if not app_id:
        print("\n⚠️  Create the app in App Store Connect, then run this again")
        return 1

    if setup_only:
        print("\n✅ Setup complete!")
        return 0

    # Step 3: Upload Metadata
    upload_metadata(api, app_id)

    if metadata_only:
        print("\n✅ Metadata uploaded!")
        return 0

    # Screenshots only mode
    if screenshots_only:
        # Get the iOS version ID (filter by platform)
        versions = api.get(f"apps/{app_id}/appStoreVersions?filter[appStoreState]=PREPARE_FOR_SUBMISSION&filter[platform]=IOS")
        if versions.get("data") and len(versions["data"]) > 0:
            version_id = versions["data"][0]["id"]
            version_string = versions["data"][0]["attributes"]["versionString"]
            platform = versions["data"][0]["attributes"]["platform"]
            print(f"\n📱 Uploading screenshots for {platform} version {version_string}...")

            if upload_screenshots(api, version_id):
                print("\n✅ Screenshots uploaded successfully!")

                # Check if build is attached
                print("\n🔍 Checking if build is attached...")
                version_details = api.get(f"appStoreVersions/{version_id}?include=build")
                included = version_details.get("included", [])

                if not included:
                    print("⚠️  No build attached to version")
                    print("🔍 Finding latest build...")
                    build_id = get_latest_build(api, app_id)
                    if build_id:
                        print("🔗 Attaching build to version...")
                        attach_build_to_version(api, version_id, build_id)
                else:
                    print("✅ Build already attached")

                print("\n📋 Next steps (manual in App Store Connect):")
                print("   1. Configure App Privacy (no data collection)")
                print("   2. Set Age Rating (4+)")
                print("   3. Add App Review Information (contact info + notes)")
                print("   4. Submit for review")
                print("\n   Visit: https://appstoreconnect.apple.com")

                return 0
            else:
                print("\n❌ Screenshot upload failed")
                return 1
        else:
            print("\n❌ No iOS version in PREPARE_FOR_SUBMISSION state found")
            return 1

    # Get version info
    if build_only and len(args) >= 3:
        version = args[args.index("--build") + 1]
        build_number = args[args.index("--build") + 2]
    else:
        print()
        version = input("Version number (e.g., 1.0.0): ").strip()
        build_number = input("Build number (e.g., 1): ").strip()

    # Step 4: Create Version
    version_id = create_version(api, app_id, version)
    if not version_id:
        print("\n❌ Failed to create version")
        return 1

    # Step 5: Build and Upload
    print("\n" + "=" * 70)
    print("  Building and Uploading")
    print("=" * 70)

    if not build_and_upload(version, build_number):
        print("\n❌ Build failed")
        return 1

    # Step 6: Wait for build to process, then attach to version
    print("\n⏳ Waiting for build to finish processing...")
    print("   This typically takes 5-15 minutes")
    print("   You can:")
    print("   - Monitor at: https://appstoreconnect.apple.com")
    print("   - Or run: ./deploy.py --attach-build")
    print()

    attach = input("Wait and attach build now? (y/n): ").strip().lower()

    if attach == 'y':
        import time
        # Poll for build
        build_id = None
        for i in range(30):  # Try for 15 minutes
            build_id = get_latest_build(api, app_id)
            if build_id:
                break
            print(f"   Checking again in 30s... ({i+1}/30)")
            time.sleep(30)

        if build_id:
            attach_build_to_version(api, version_id, build_id)

            # Step 7: Submit for review
            submit = input("\nSubmit for review? (y/n): ").strip().lower()
            if submit == 'y':
                submit_for_review(api, version_id)

    print("\n" + "=" * 70)
    print("  ✅ Deployment Complete!")
    print("=" * 70)
    print()
    print("Next steps:")
    print("  1. Check App Store Connect for build processing status")
    print("  2. Add screenshots (manual step)")
    print("  3. Submit for review when ready")
    print()

    return 0


if __name__ == "__main__":
    try:
        sys.exit(main())
    except KeyboardInterrupt:
        print("\n\n⚠️  Deployment cancelled by user")
        sys.exit(1)
    except Exception as e:
        print(f"\n❌ Unexpected error: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)
