# GitHub Actions Workflows Guide

This document provides essential information about the GitHub Actions workflows in this repository and how to maintain them.

## Important Version Requirements

All workflows must use the latest stable versions of actions to ensure security and functionality:

| Action | Required Version | Notes |
|--------|-----------------|-------|
| `actions/checkout` | `v4` | For repository checkout |
| `actions/upload-artifact` | `v4` | For uploading build artifacts |
| `actions/download-artifact` | `v4` | For downloading artifacts |
| `actions/setup-node` | `v4` | For Node.js setup |
| `actions/setup-java` | `v4` | For Java/Android SDK setup |
| `actions/cache` | `v4` | For dependency caching |

## Common Build Errors and Solutions

### 1. Xcode Setup Issues
```yaml
# ❌ Don't use deprecated action
- uses: maxim/setup-xcode@v1

# ✅ Use official Apple action instead
- uses: apple-actions/setup-xcode@v3
  with:
    xcode-version: '15.4'
```

### 2. Android SDK Setup
```yaml
# ❌ Don't use brew for Android SDK
brew install android-sdk

# ✅ Use official setup-android action
- uses: android-actions/setup-android@v3
  with:
    api-level: 33
    build-tools-version: 33.0.0
```

### 3. Artifact Upload
```yaml
# ❌ Don't use v3
- uses: actions/upload-artifact@v3

# ✅ Use v4 with proper retention
- uses: actions/upload-artifact@v4
  with:
    name: my-artifact
    path: path/to/artifact
    retention-days: 5  # Specify retention period
```

## Required Environment Variables

Each workflow needs these environment variables:

```yaml
env:
  DEVELOPER_DIR: /Applications/Xcode_15.4.app/Contents/Developer
  SDKROOT: /Applications/Xcode_15.4.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS17.5.sdk
  ANDROID_SDK_ROOT: ${{ runner.temp }}/android-sdk
  JAVA_HOME: ${{ runner.temp }}/java-home
```

## Build Matrix Best Practices

Use build matrices to test across multiple configurations:

```yaml
strategy:
  matrix:
    os: [macos-latest, ubuntu-latest]
    xcode: ['15.4', '15.3']
    exclude:
      - os: ubuntu-latest
        xcode: '15.4'
```

## Security Best Practices

1. Always pin actions to specific SHA commits for security:
```yaml
- uses: actions/checkout@8ade135a41bc03ea155e62e844d188df1ea18608 # v4.1.0
```

2. Use GITHUB_TOKEN with minimum required permissions:
```yaml
permissions:
  contents: read
  packages: write
```

3. Enable security hardening features:
```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    permissions: write-all
    security:
      matrix-filters: true
      unsafe-downloads: deny
```

## Caching Dependencies

Implement proper caching to speed up builds:

```yaml
- uses: actions/cache@v4
  with:
    path: |
      ~/.gradle/caches
      ~/.gradle/wrapper
      ~/Library/Caches/CocoaPods
    key: ${{ runner.os }}-deps-${{ hashFiles('**/*.gradle*', '**/Podfile.lock') }}
    restore-keys: |
      ${{ runner.os }}-deps-
```

## Error Handling

Add proper error handling in workflows:

```yaml
steps:
  - name: Build App
    id: build
    continue-on-error: true
    run: ./scripts/build.sh

  - name: Check Build Status
    if: steps.build.outcome != 'success'
    run: |
      echo "Build failed, collecting logs..."
      ./scripts/collect_logs.sh
      exit 1
```

## Workflow Triggers

Configure specific paths for workflow triggers:

```yaml
on:
  push:
    paths:
      - 'Apps/**'
      - '.github/workflows/**'
      - '!**.md'
  pull_request:
    paths:
      - 'Apps/**'
      - '.github/workflows/**'
      - '!**.md'
```

## Testing Workflows Locally

Use `act` to test workflows locally:

```bash
# Install act
brew install act

# Run workflow locally
act -P ubuntu-latest=ghcr.io/catthehacker/ubuntu:act-latest
```

## Maintenance Schedule

- Review and update action versions monthly
- Test workflows with new Xcode/Android SDK versions when released
- Update dependencies and build tools quarterly
- Full security audit every 6 months

## Additional Resources

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [GitHub Actions Security Guide](https://docs.github.com/en/actions/security-guides)
- [GitHub Actions Best Practices](https://docs.github.com/en/actions/learn-github-actions/best-practices-for-github-actions)
