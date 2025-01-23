# TrollStore Essential Build Tools

This directory contains the minimal set of tools required to build and sign TrollStore applications.

## Core Tools

### ldid
- Primary code signing tool
- Used for:
  - Signing applications and binaries
  - Managing and applying entitlements
  - Extracting and inspecting code signatures

### choma
- Binary patching tool
- Used for:
  - Patching sandbox restrictions
  - Enabling JIT capabilities
  - Enabling debug features
  - Enabling root access

### unzip
- Archive management tool
- Used for:
  - Extracting SDKs and packages
  - Managing IPA files
  - Handling package contents

## Build Process

The build process has been optimized to use these three essential tools:

1. First, `choma` is used to patch binaries for required capabilities
2. Then, `ldid` handles all code signing and entitlements
3. Finally, `unzip` manages package contents and extraction

## Notes

- Other tools like `insert_dylib`, `dpkg-deb`, `otool`, and `zip` are not required as their functionality can be achieved through our core toolset
- `ldid` can handle most binary inspection tasks that would normally use `otool`
- Archive operations can be handled with `unzip`

## Directory Structure:
```
bins/
├── README.md
├── ldid          # Code signing tool
├── choma         # Binary patching tool
└── unzip        # Archive management tool
```

## Usage:
All tools should be executable. If not, run:
```bash
chmod +x bins/*
```

## Version Information:
- All tools are compiled for arm64 architecture
- Compatible with iOS 14.0-16.x
- Updated for TrollStore 2.0
