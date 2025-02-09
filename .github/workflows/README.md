# GitHub Actions Workflows Guide

This document provides essential information about the GitHub Actions workflows in this repository and how to maintain them.

## Important Version Requirements

All workflows MUST use v4 or later versions of actions to ensure security and functionality:

| Action | Required Version | Notes |
|--------|-----------------|-------|
| `actions/checkout` | `v4` | For repository checkout |
| `actions/upload-artifact` | `v4` | For uploading build artifacts |
| `actions/download-artifact` | `v4` | For downloading artifacts |
| `actions/setup-node` | `v4` | For Node.js setup |
| `actions/setup-java` | `v4` | For Java setup |
| `actions/cache` | `v4` | For dependency caching |
| `maxim-lobanov/setup-xcode` | `v1` | For Xcode setup (iOS builds) |

## Current Workflows

### 1. Android Emulator Build (iOS)
- **File**: `android-emulator.yml`
- **Purpose**: Builds the Android Emulator as an iOS application
- **Output**: IPA file for iOS deployment
- **Requirements**:
  - macOS runner
  - Xcode 15.2
  - iOS signing certificate
  - Provisioning profile
- **Environment**:
  - CCACHE_DIR: ~/.ccache
- **Key Steps**:
  - Xcode setup and validation
  - Code signing setup
  - IPA creation and signing
  - Artifact upload (v4)

### 2. LightNovelPub Build
- **File**: `lightnovelpub.yml`
- **Purpose**: Builds the LightNovelPub iOS application
- **Output**: IPA file for iOS deployment
- **Requirements**:
  - macOS runner
  - Xcode 15.2
  - iOS signing certificate
  - Provisioning profile
- **Environment**:
  - DEVELOPER_DIR: /Applications/Xcode.app/Contents/Developer
  - BUNDLE_ID: "com.alot1z.lightnovelpub"
  - APP_NAME: "LightNovel Pub"
  - MIN_IOS: "16.0"
  - MAX_IOS: "17.0"
- **Key Steps**:
  - Xcode setup and validation
  - Code signing setup
  - IPA creation and signing
  - Artifact upload (v4)

## Common Build Errors and Solutions

### 1. Xcode Setup Issues
```yaml
# Error: Xcode version '15.2' not found
Solution: Verify available Xcode versions on runner:
- uses: maxim-lobanov/setup-xcode@v1
  with:
    xcode-version: '15.2'
```

### 2. Code Signing Issues
```yaml
# Error: No signing certificate "iOS Distribution" found
Solution:
- Check BUILD_CERTIFICATE_BASE64 secret is set
- Verify certificate is not expired
- Ensure certificate is iOS Distribution type

# Error: No provisioning profile matching
Solution:
- Verify BUILD_PROVISION_PROFILE_BASE64 secret
- Check profile is not expired
- Confirm bundle ID matches profile (com.alot1z.lightnovelpub)
```

### 3. Artifact Upload
```yaml
# Required: Use v4 for all artifact operations
- uses: actions/upload-artifact@v4
  with:
    name: MyApp.ipa
    path: build/Export/MyApp.ipa
    retention-days: 5
```

## Required Environment Variables

Essential environment variables for iOS builds:

```yaml
# Common Variables
env:
  DEVELOPER_DIR: /Applications/Xcode.app/Contents/Developer
  XCODE_VERSION: '15.2'

# LightNovelPub Specific
  BUNDLE_ID: "com.alot1z.lightnovelpub"
  APP_NAME: "LightNovel Pub"
  MIN_IOS: "16.0"
  MAX_IOS: "17.0"

# Android Emulator Specific
  CCACHE_DIR: ~/.ccache
```

## Required Secrets

Configure these secrets in repository settings:

1. `BUILD_CERTIFICATE_BASE64`: iOS distribution certificate (Required)
   - Must be base64 encoded
   - Must be valid iOS Distribution certificate
   - Check expiration date
   - Must match bundle ID (com.alot1z.lightnovelpub)

2. `BUILD_PROVISION_PROFILE_BASE64`: iOS provisioning profile (Required)
   - Must be base64 encoded
   - Must match bundle identifier
   - Check expiration date
   - Support iOS 16.0-17.0 for LightNovelPub

3. `P12_PASSWORD`: Certificate password (Required)
   - Used to unlock certificate
   - Must match certificate password

4. `KEYCHAIN_PASSWORD`: Temporary keychain password (Required)
   - Used for temporary keychain during build
   - Can be any secure string

## Security Best Practices

1. Pin action versions to SHA for security:
```yaml
- uses: actions/checkout@8ade135a41bc03ea155e62e844d188df1ea18608 # v4.1.0
```

2. Minimum required permissions:
```yaml
permissions:
  contents: read
  id-token: write # Required for signing
```

3. Secure secrets handling:
```yaml
steps:
  - name: Import Certificate
    env:
      CERTIFICATE: ${{ secrets.BUILD_CERTIFICATE_BASE64 }}
    run: |
      echo "$CERTIFICATE" | base64 --decode > certificate.p12
```

## Build Validation

Add validation steps to catch issues early:

```yaml
- name: Validate Xcode
  run: |
    xcodebuild -version
    xcrun simctl list devices

- name: Validate Certificate
  run: |
    security find-identity -v -p codesigning

- name: Validate Profile
  run: |
    security cms -D -i "profile.mobileprovision"
```

## Maintenance Schedule

- Daily: Monitor workflow runs and failures
- Weekly: Check certificate/profile expiration
- Monthly: Update action versions to latest v4
- Quarterly: Full security audit

## Troubleshooting Guide

1. Build Failures:
   - Check runner logs for errors
   - Verify all secrets are set
   - Validate Xcode version (15.2)
   - Check certificate/profile validity
   - Verify bundle ID matches (com.alot1z.lightnovelpub)

2. Signing Issues:
   - Regenerate certificates if expired
   - Update provisioning profiles
   - Verify bundle ID matches
   - Check iOS version compatibility (16.0-17.0)

3. Upload Issues:
   - Confirm artifact path exists
   - Check file permissions
   - Verify runner has disk space

## Additional Resources

- [GitHub Actions for iOS](https://docs.github.com/en/actions/guides/building-and-testing-swift)
- [Code Signing Guide](https://developer.apple.com/support/code-signing/)
- [Xcode Cloud Documentation](https://developer.apple.com/documentation/xcode/xcode-cloud)
