# TrollStore Enhanced Extensions

This directory contains extensions that enhance TrollStore's functionality without modifying its core files.

## Extensions

### TSAppModifier
Enhanced app modification capabilities:
- Advanced binary patching
- Improved code signing
- Enhanced entitlements management

### TSRootHelper
Extended root capabilities:
- Advanced root access management
- Improved app installation
- System-level operations

## How It Works

These extensions are designed to work alongside TrollStore's original code without modifying it:

1. Extensions are kept in their own directory
2. They use TrollStore's public APIs
3. They add functionality through composition, not modification
4. Original TrollStore files remain untouched

## Integration

The `scripts/integrate_extensions.sh` script will:
1. Copy extensions to TrollStore's Extensions directory
2. Add them to the Xcode project
3. Maintain clean separation from TrollStore's core code

## Development

When adding new extensions:
1. Create a new directory under `extensions/`
2. Keep all code separate from TrollStore's files
3. Use TrollStore's public APIs
4. Update `integrate_extensions.sh` if needed
