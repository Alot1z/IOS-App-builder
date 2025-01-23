# TrollStore Enhanced

An enhanced version of TrollStore with advanced iOS system integration and security bypass capabilities.

## Core Features & Capabilities

### 1. Enhanced Build System
- Custom build tools in `bins/` directory
- Optimized compilation process
- Improved dependency management
- Streamlined build workflow

### 2. Extended Functionality
- Additional extensions in `extensions/` directory
- Improved app management
- Enhanced persistence methods
- Advanced configuration options

### 3. Improved Documentation
- Separate installation guides for different scenarios
- Clear step-by-step instructions
- Device-specific documentation
- Troubleshooting guides

## New Features in TrollStore App

### App Management Interface
#### Location: Main Tab > Installed Apps
- **Enhanced App List**
  - Shows all installed apps with new detailed info
  - Display app version, bundle ID, and environment status
  - New quick action buttons for each app

#### App Environment Editor
**Location: App Details > Environment Variables**
1. Tap any app in the list
2. Select "Edit Environment"
3. Add/Edit variables:
   ```
   DYLD_INSERT_LIBRARIES=/path/to/tweak.dylib
   TROLLSTORE_ENTITLEMENTS=1
   ```
4. Tap "Save" to store changes
5. **NEW**: Tap "Reinstall" button that appears after saving
   - This reregisters the app with new environment
   - Preserves app data while applying changes

### New Control Center
**Location: Settings Tab > Advanced Controls**
- **Process Manager**
  - View running processes
  - Force stop apps
  - Clear app cache
  - Reset app environment

- **Security Controls**
  - Manage entitlements
  - Toggle security features
  - Certificate management

### Enhanced Installation
**Location: Main Tab > "+" Button**
- **Multi-Source Install**
  - Local IPA files
  - Direct URL install
  - **NEW**: Bulk installation support
  
- **Installation Options**
  - Custom app name
  - Bundle ID modification
  - Environment preset selection

### Advanced Features
**Location: Settings > Advanced**
- **Persistence Helper**
  - Enhanced persistence options
  - Auto-respring settings
  - Update survival configuration

- **Root Helper**
  - Root access management
  - System modification tools
  - FileSystem access controls

### URL Scheme Support
**Usage: From Any App**
```
trollstore://install?url=<IPA_URL>
trollstore://settings/environment?bundle=<BUNDLE_ID>
```

## Using TrollStore Enhanced

### Main App Interface
![Main Interface](images/main_interface.png)

#### 1. App List View (Home Screen)
- **Top Bar**:
  - "+" button for new installations
  - Search bar for filtering apps
  - Sort options (Name, Date, Size)

- **App Cards**:
  - Shows app icon and name
  - Bundle ID and version
  - Environment status indicator
  - Quick action buttons:
    - Edit Environment
    - Reinstall
    - Delete
    - Share

#### 2. Environment Editor
![Environment Editor](images/env_editor.png)

1. **Access**:
   - Tap any app in the list
   - Select "Edit Environment"
   
2. **Available Options**:
   ```
   # Common Environment Variables
   DYLD_INSERT_LIBRARIES=/path/to/tweak.dylib
   TROLLSTORE_ENTITLEMENTS=1
   TROLLSTORE_PERSIST=1
   ```

3. **Using the Editor**:
   - Add/Remove variables with +/- buttons
   - Use presets from dropdown menu
   - Import/Export configurations
   
4. **Saving Changes**:
   - Tap "Save" to store configuration
   - **Important**: Tap "Reinstall" in the popup
   - Wait for app reregistration

#### 3. Advanced Controls
![Advanced Menu](images/advanced_menu.png)

- **Process Manager**:
  - List of running processes
  - Memory usage indicators
  - Force stop option
  - Cache clearing
  
- **Security Settings**:
  - Entitlement toggles
  - Root access controls
  - System integration options

### Installation Methods

#### 1. Local IPA Install
1. Tap "+" on main screen
2. Choose "Select IPA File"
3. Browse to your IPA
4. Configure options:
   - Custom name
   - Environment variables
   - Persistence settings
5. Tap "Install"

#### 2. URL Installation
1. Tap "+" on main screen
2. Choose "Install from URL"
3. Enter or paste IPA URL
4. Configure same options
5. Tap "Install"

#### 3. Bulk Installation
1. Tap "+" on main screen
2. Choose "Bulk Install"
3. Select multiple IPAs or URLs
4. Apply batch settings
5. Start installation

### Quick Tips
- **Save Button**: Always visible after changes
- **Reinstall Button**: Appears after saving
- **Persistence**: Enable in advanced settings
- **Backup**: Export configurations regularly

### Troubleshooting
1. **App Won't Launch After Environment Change**:
   - Go back to Environment Editor
   - Verify variables are correct
   - Try removing one variable at a time
   - Always use "Reinstall" after changes

2. **Environment Not Applying**:
   - Check if "Save" was tapped
   - Ensure "Reinstall" was done
   - Verify app is properly registered

3. **Installation Fails**:
   - Check URL/file validity
   - Verify enough storage
   - Try clearing TrollStore cache
   - Use "Advanced Install" option

## Technical Implementation

### 1. Core System Integration
#### Kernel-Level Operations
- **AMFI Bypass System**
  - Custom signature validation hooking
  - Dynamic code signing verification bypass
  - Runtime entitlement injection
  - Kernel memory patch persistence

#### Process Management
- **Enhanced Process Control**
  - Custom process spawning mechanism
  - Elevated privilege management
  - System service integration
  - Background task handling

#### File System Integration
- **Protected Storage Access**
  - Custom container creation
  - System path manipulation
  - Secure file operations
  - Persistent data storage

### 2. Security Implementation

#### Certificate Management
- **Dynamic Certificate Handling**
  - Runtime certificate generation
  - Trust chain modification
  - Certificate validation bypass
  - Signature requirement nullification

#### Entitlement System
- **Advanced Entitlement Control**
  - Dynamic entitlement injection
  - System capability expansion
  - Permission elevation
  - Security policy modification

#### Sandbox Manipulation
- **Container Isolation Control**
  - Sandbox boundary modification
  - Inter-process communication enhancement
  - File system access expansion
  - Network restriction bypass

### 3. Enhanced Functionality

#### App Installation System
- **Advanced Installation Engine**
  - Custom IPA processing
  - Binary modification engine
  - Resource repackaging
  - Installation validation

#### Persistence Mechanism
- **System Integration Layer**
  - Boot persistence handling
  - System service integration
  - Update survival system
  - Recovery mechanism

#### Process Injection
- **Dynamic Code Execution**
  - Runtime library injection
  - Method swizzling engine
  - Hook management system
  - Dynamic patching

## Technical Architecture

### System Components

```plaintext
TrollStore Enhanced
├── Core System
│   ├── AMFI Bypass Engine
│   ├── Process Manager
│   └── FileSystem Controller
├── Security Layer
│   ├── Certificate Handler
│   ├── Entitlement Manager
│   └── Sandbox Controller
└── Enhancement Modules
    ├── Installation Engine
    ├── Persistence Manager
    └── Injection System
```

### Data Flow Architecture

```plaintext
User Input → Installation Request
↓
Installation Engine
├── IPA Processing
├── Binary Modification
└── Resource Repackaging
↓
Security Layer
├── Certificate Generation
├── Entitlement Injection
└── Sandbox Modification
↓
Core System
├── AMFI Bypass
├── Process Spawning
└── FileSystem Integration
↓
iOS System Integration
```

## Technical Specifications

### System Requirements
- **Device Architecture**: arm64/arm64e
- **iOS Version Support**: iOS 14.0-16.x
- **Minimum Storage**: 50MB
- **RAM Usage**: ~100MB during operation

### Security Features
- **Certificate Handling**:
  - Custom CA certificate generation
  - Trust chain manipulation
  - Signature validation bypass

- **Entitlement Management**:
  - Dynamic entitlement injection
  - System capability expansion
  - Permission elevation

- **Sandbox Control**:
  - Container isolation modification
  - IPC enhancement
  - FileSystem access control

### Performance Optimizations
- **Memory Management**:
  - Dynamic memory allocation
  - Resource usage optimization
  - Cache management system

- **Process Handling**:
  - Efficient process spawning
  - Background task optimization
  - System service integration

## Advanced Build Configuration

### Environment Variables
```bash
# Core Build Settings
THEOS=/opt/theos                  # Theos installation path
THEOS_DEVICE_IP=127.0.0.1        # Device IP for remote installation
THEOS_DEVICE_PORT=22             # SSH port for device connection
THEOS_PACKAGE_SCHEME=rootless    # Package scheme (rootless/rooted)

# Build Type Options
FINALPACKAGE=1                   # Enable release mode optimizations
DEBUG=0                          # Disable debug symbols (set 1 for debugging)
STRIP=1                          # Strip binary (reduces size)

# Custom Paths
TROLLSTORE_APP_PATH=/var/containers/Bundle/Application/AppUUID
TROLLSTORE_APP_GROUP=group.com.example.app
```

### Build Types

#### Debug Build
```bash
make package DEBUG=1 FINALPACKAGE=0
```
- Includes debug symbols
- Enables verbose logging
- Disables optimizations
- Useful for development

#### Release Build
```bash
make package FINALPACKAGE=1 STRIP=1
```
- Optimized for size and performance
- Strips debug symbols
- Enables all optimizations
- Ready for distribution

### Automated Build System

Our GitHub Actions workflow provides:

#### 1. Continuous Integration
- Automatic builds on push/PR
- Code analysis and testing
- Build artifact generation
- Automated releases

#### 2. Build Artifacts
- Compiled .deb packages
- SHA256 checksums
- Version information
- Build date stamps

#### 3. Quality Control
- Xcode analysis
- Code signing verification
- Dependency validation
- Build environment checks

## Installation Guides

For better organization and clarity, installation instructions are split into separate files based on your device and iOS version:

- [SSH Ramdisk Installation](install_sshrd.md) - For checkm8/arm64 devices
- [TrollHelper Installation](install_trollhelper.md) - For jailbroken devices
- [TrollHelperOTA arm64e Installation](install_trollhelperota_arm64e.md) - For A12-A15 devices
- [TrollHelperOTA iOS 15 Installation](install_trollhelperota_ios15.md) - For iOS 15 devices

## Installation Methods

### 1. TrollHelper Method
- **Technical Process**:
  1. Binary injection into helper app
  2. System service registration
  3. Persistence setup
  4. Certificate installation

### 2. SSH Ramdisk Method
- **Technical Implementation**:
  1. Custom ramdisk creation
  2. System mount modification
  3. Binary deployment
  4. Boot process integration

### 3. OTA Installation
- **System Integration**:
  1. URL scheme registration
  2. Installation validation
  3. System service setup
  4. Persistence mechanism

## Advanced Usage

### Custom Binary Installation
```objc
// Example of custom binary installation
TSInstallationManager *manager = [TSInstallationManager sharedInstance];
[manager installBinaryWithPath:@"/path/to/binary"
                  permissions:0755
                  persistent:YES
                  completion:^(BOOL success, NSError *error) {
    if (success) {
        // Binary installed successfully
    }
}];
```

### Entitlement Injection
```objc
// Example of entitlement injection
TSEntitlementManager *entManager = [TSEntitlementManager sharedInstance];
[entManager injectEntitlements:@{
    @"com.apple.private.security.no-sandbox": @YES,
    @"platform-application": @YES
} forBinaryAtPath:@"/path/to/binary"];
```

## Project Structure

This enhanced version of TrollStore includes:

- `TrollStore/` - Original TrollStore
- `bins/` - Enhanced build tools and utilities
- `extensions/` - Additional features and improvements
- Separate installation guides for different scenarios

## Build Configuration

### Requirements
- macOS/Linux build system
- Theos installed
- iOS SDK 16.2+
- ldid utility
- libarchive

### Build Process
```bash
# Set environment
export THEOS=/opt/theos
export SDKVERSION=16.2
export SYSROOT=/opt/theos/sdks/iPhoneOS16.2.sdk

# Build package
make package FINALPACKAGE=1
```

## Development Guide

### 1. Setting Up Development Environment
```bash
# Install dependencies
brew install ldid make theos dpkg xz

# Clone repository with submodules
git clone --recursive https://github.com/Alot1z/TrollStore_Enhanced.git
cd TrollStore_Enhanced

# Initialize build environment
./bins/build.sh init
```

### 2. Making Changes
1. Create a new branch
2. Make your changes
3. Test locally
4. Create pull request

### 3. Testing
- Run local tests: `make test`
- Check code style: `make lint`
- Verify build: `make package DEBUG=1`

## How New Features Are Integrated

### 1. Build Integration
When you build TrollStore Enhanced, the following components are added:

```plaintext
TrollStore.app/
├── Interface
│   ├── MainViewController      # Enhanced app list
│   ├── EnvironmentVC          # Environment editor
│   └── AdvancedVC             # New controls
├── Core
│   ├── TSEnhancedManager      # Core functionality
│   ├── TSEnvironmentManager   # Environment handling
│   └── TSProcessManager       # Process control
└── Resources
    └── Presets/              # Default configurations
```

### 2. Feature Integration
- **Main App Interface**
  - Enhanced features are automatically integrated into UI
  - New buttons and controls appear in relevant sections
  - All new features accessible through standard navigation

- **Background Services**
  - New daemons run for advanced features
  - Automatic integration with iOS
  - Enhanced persistence handling

### 3. Using New Features

#### Environment Modification
1. Open TrollStore
2. Tap any installed app
3. Select "Edit Environment"
4. Make changes
5. Tap "Save"
6. **Important**: Tap "Reinstall" when prompted
   - This step is crucial for applying changes
   - App will reregister with new settings

#### Advanced Installation
1. Tap "+" on main screen
2. Choose installation source
3. Select advanced options:
   - Set environment variables
   - Configure entitlements
   - Choose persistence options
4. Tap "Install"

#### Process Management
1. Go to Settings > Advanced
2. Select "Process Manager"
3. View and control running apps
4. Use quick actions for common tasks

## Environment Variables Guide

### Public Environment Variables
These variables are safe to modify and commonly used:

| Variable | Description | Default | Toggle |
|----------|-------------|---------|--------|
| `TROLLSTORE_PERSIST` | Keep app installed after reboot | 0 | ✓ |
| `TROLLSTORE_ENTITLEMENTS` | Enable all entitlements | 0 | ✓ |
| `TROLLSTORE_LOG_LEVEL` | Logging detail (0-4) | 1 | - |
| `TROLLSTORE_CONTAINER` | Custom container path | Default | - |
| `TROLLSTORE_BACKUP` | Enable automatic backups | 0 | ✓ |
| `TROLLSTORE_UPDATE_CHECK` | Auto-check for updates | 1 | ✓ |
| `TROLLSTORE_CACHE_DIR` | Custom cache directory | Default | - |
| `TROLLSTORE_TEMP_DIR` | Temporary file location | Default | - |
| `TROLLSTORE_NO_SANDBOX` | Disable app sandboxing | 0 | ✓ |
| `TROLLSTORE_DEBUG` | Enable debug logging | 0 | ✓ |

### Private/System Environment Variables 
These variables affect core functionality - modify with caution:

| Variable | Description | Default | Toggle |
|----------|-------------|---------|--------|
| `DYLD_INSERT_LIBRARIES` | Load custom dylibs | Empty | ✓ |
| `TROLLSTORE_ROOT_PATH` | TrollStore installation path | System | - |
| `TROLLSTORE_APP_DATA` | App data storage location | System | - |
| `TROLLSTORE_ORIG_PATH` | Original binary path | System | - |
| `TROLLSTORE_HOOKS` | Custom hook libraries | Empty | ✓ |
| `TROLLSTORE_DAEMON` | Daemon configuration | Default | - |
| `TROLLSTORE_SIGNATURES` | Signature verification | 1 | ✓ |
| `TROLLSTORE_ENTITLEMENTS_ALL` | Grant all entitlements | 0 | ✓ |
| `TROLLSTORE_SYSTEM_VERSION` | Target iOS version | Auto | - |
| `TROLLSTORE_DEVICE_TYPE` | Target device type | Auto | - |

### Using Environment Variables

#### In TrollStore UI
1. Select an app from the list
2. Tap "Edit Environment"
3. You'll see two sections:
   - Public Variables (Safe to modify)
   - Private Variables (Use with caution)
4. Each variable has:
   - Toggle switch (if applicable)
   - Information button (ⓘ) showing:
     * Full description
     * Default value
     * Usage examples
     * Warning if dangerous
   - Value field (for non-toggle variables)

#### Variable States
- 🟢 Active & Working
- 🟡 Active but Needs Restart
- 🔴 Inactive
- ⚠️ Warning/Caution Needed

#### Common Configurations

1. **Maximum Freedom**
```
TROLLSTORE_PERSIST=1
TROLLSTORE_ENTITLEMENTS=1
TROLLSTORE_NO_SANDBOX=1
```

2. **Maximum Security**
```
TROLLSTORE_SIGNATURES=1
TROLLSTORE_NO_SANDBOX=0
TROLLSTORE_ENTITLEMENTS=0
```

3. **Developer Mode**
```
TROLLSTORE_DEBUG=1
TROLLSTORE_LOG_LEVEL=4
TROLLSTORE_PERSIST=1
```

#### Saving Changes
1. After modifying variables, tap "Save"
2. A popup will show affected components
3. Tap "Reinstall" to apply changes
4. Wait for app reregistration

#### Backup & Restore
- Export: Tap "Export Config" to save current environment
- Import: Tap "Import Config" to load saved environment
- Presets: Choose from common configurations

### Variable Details

Each variable can be clicked to show a detailed card:

```
VARIABLE_NAME
├── Description: Detailed explanation
├── Type: Toggle/Text/Number
├── Default: Default value
├── Effects:
│   ├── Components affected
│   └── Required restarts
├── Examples:
│   ├── Common usage
│   └── Use cases
└── Warnings:
    └── Potential risks
```

### Advanced Usage

#### Combining Variables
Some variables work together for enhanced functionality:

1. **Enhanced Persistence**
```
TROLLSTORE_PERSIST=1
TROLLSTORE_BACKUP=1
```

2. **Full Development**
```
TROLLSTORE_DEBUG=1
TROLLSTORE_NO_SANDBOX=1
TROLLSTORE_ENTITLEMENTS=1
```

#### Troubleshooting

If an app won't launch after environment changes:

1. Check Logs:
```
TROLLSTORE_DEBUG=1
TROLLSTORE_LOG_LEVEL=4
```

2. Reset to Default:
- Tap "Reset All" in Environment Editor
- Reinstall app

3. Common Issues:
- 🔴 App crashes: Check TROLLSTORE_ENTITLEMENTS
- 🔴 No persistence: Verify TROLLSTORE_PERSIST
- 🔴 Permission denied: Check TROLLSTORE_NO_SANDBOX

## Build Output Integration
When building TrollStore Enhanced, new features are compiled and integrated:

1. **Core Integration**
```bash
make package FINALPACKAGE=1
```
- Compiles new UI components
- Builds enhanced features
- Integrates with main TrollStore app

2. **Extension Building**
```bash
cd extensions
make package
```
- Creates feature modules
- Builds new functionality
- Prepares for integration

3. **Final Integration**
- All components are packaged into main .deb
- Features automatically integrate on installation
- No manual setup required

## Credits & Version History
- Original TrollStore by @opa334
- Enhanced functionality by Alot1z
- Version 1.0.3: Advanced system integration
