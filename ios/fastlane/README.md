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

### ios auto_versioning

```sh
[bundle exec] fastlane ios auto_versioning
```

Automatically increment the version name and version code. Also prepare the changelogs and release note from git commits.

### ios firebase_dev

```sh
[bundle exec] fastlane ios firebase_dev
```

Deploy the DEV application to Firebase App Distribution (iOS)

### ios firebase_prod

```sh
[bundle exec] fastlane ios firebase_prod
```

Deploy the PROD application to Firebase App Distribution (iOS)

### ios beta_release

```sh
[bundle exec] fastlane ios beta_release
```

Deploy the PROD application to TestFlight

### ios upload_dsym

```sh
[bundle exec] fastlane ios upload_dsym
```

Uploads the dSYM files to Crashlytics

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
