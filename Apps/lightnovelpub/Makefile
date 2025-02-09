APP_NAME = LightNovelPub
BUNDLE_ID = com.alot1z.lightnovelpub
VERSION = 1.0.0

SWIFT_FILES = $(wildcard src/*.swift)
RESOURCES = $(wildcard resources/*)

DEPLOYMENT_TARGET = 16.0
SDK = iphoneos
ARCH = arm64

SWIFT_FLAGS = -O -whole-module-optimization
FRAMEWORK_SEARCH_PATHS = -F$(SDK_PATH)/System/Library/Frameworks

SDK_PATH = $(shell xcrun --sdk $(SDK) --show-sdk-path)
SWIFT_PATH = $(shell xcrun -f swiftc)

.PHONY: all clean

all: build/$(APP_NAME).ipa

build/$(APP_NAME).app: $(SWIFT_FILES)
	@mkdir -p build
	$(SWIFT_PATH) $(SWIFT_FLAGS) \
		-sdk $(SDK_PATH) \
		-target $(ARCH)-apple-ios$(DEPLOYMENT_TARGET) \
		$(FRAMEWORK_SEARCH_PATHS) \
		-emit-executable \
		-o build/$(APP_NAME) \
		$(SWIFT_FILES)
	
	@mkdir -p build/$(APP_NAME).app
	@cp build/$(APP_NAME) build/$(APP_NAME).app/
	@cp Info.plist build/$(APP_NAME).app/
	@cp -R resources/* build/$(APP_NAME).app/ 2>/dev/null || :
	
	@./scripts/generate_icons.sh --input resources/icon.png --output build/$(APP_NAME).app
	@./scripts/sign_app.sh --app build/$(APP_NAME).app --entitlements entitlements.plist

build/$(APP_NAME).ipa: build/$(APP_NAME).app
	@mkdir -p build/Payload
	@cp -R build/$(APP_NAME).app build/Payload/
	@cd build && zip -r $(APP_NAME).ipa Payload
	@rm -rf build/Payload

clean:
	@rm -rf build/*
