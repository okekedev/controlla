fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

## iOS

### ios release

```sh
[bundle exec] fastlane ios release
```

Build and upload to App Store

### ios setup

```sh
[bundle exec] fastlane ios setup
```

First-time setup

### ios build

```sh
[bundle exec] fastlane ios build
```

Build the app

### ios upload_metadata

```sh
[bundle exec] fastlane ios upload_metadata
```

Upload metadata

### ios upload_to_app_store

```sh
[bundle exec] fastlane ios upload_to_app_store
```

Upload to App Store Connect

### ios beta

```sh
[bundle exec] fastlane ios beta
```

Upload to TestFlight

### ios print_subscription_instructions

```sh
[bundle exec] fastlane ios print_subscription_instructions
```

Print subscription setup instructions

### ios bump

```sh
[bundle exec] fastlane ios bump
```

Bump version

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
