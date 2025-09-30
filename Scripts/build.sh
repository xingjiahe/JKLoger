#!/bin/bash

# JKLoger Build Script
# This script builds the JKLoger framework for various configurations

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_DIR="$PROJECT_ROOT/build"
WORKSPACE="JKLoger.xcworkspace"
SCHEME="JKLoger"

echo -e "${BLUE}🔨 JKLoger Build Script${NC}"
echo "=================================================="
echo "Project Root: $PROJECT_ROOT"
echo "Build Directory: $BUILD_DIR"
echo ""

# Function to print status
print_status() {
    local status=$1
    local message=$2
    if [ "$status" = "OK" ]; then
        echo -e "${GREEN}✅ $message${NC}"
    elif [ "$status" = "WARNING" ]; then
        echo -e "${YELLOW}⚠️  $message${NC}"
    else
        echo -e "${RED}❌ $message${NC}"
    fi
}

# Clean build directory
echo -e "${BLUE}🧹 Cleaning Build Directory${NC}"
echo "--------------------------------------------------"
if [ -d "$BUILD_DIR" ]; then
    rm -rf "$BUILD_DIR"
    print_status "OK" "Removed existing build directory"
fi
mkdir -p "$BUILD_DIR"
print_status "OK" "Created clean build directory"

# Build for iOS Device
echo ""
echo -e "${BLUE}📱 Building for iOS Device${NC}"
echo "--------------------------------------------------"
xcodebuild \
    -workspace "$WORKSPACE" \
    -scheme "$SCHEME" \
    -configuration Release \
    -destination 'generic/platform=iOS' \
    -derivedDataPath "$BUILD_DIR/DerivedData" \
    clean build \
    CODE_SIGNING_REQUIRED=NO \
    CODE_SIGN_IDENTITY="" \
    PROVISIONING_PROFILE="" \
    | xcpretty

if [ $? -eq 0 ]; then
    print_status "OK" "iOS Device build completed successfully"
else
    print_status "ERROR" "iOS Device build failed"
    exit 1
fi

# Build for iOS Simulator
echo ""
echo -e "${BLUE}📱 Building for iOS Simulator${NC}"
echo "--------------------------------------------------"
xcodebuild \
    -workspace "$WORKSPACE" \
    -scheme "$SCHEME" \
    -configuration Release \
    -destination 'generic/platform=iOS Simulator' \
    -derivedDataPath "$BUILD_DIR/DerivedData" \
    clean build \
    CODE_SIGNING_REQUIRED=NO \
    CODE_SIGN_IDENTITY="" \
    PROVISIONING_PROFILE="" \
    | xcpretty

if [ $? -eq 0 ]; then
    print_status "OK" "iOS Simulator build completed successfully"
else
    print_status "ERROR" "iOS Simulator build failed"
    exit 1
fi

# Create XCFramework
echo ""
echo -e "${BLUE}📦 Creating XCFramework${NC}"
echo "--------------------------------------------------"

# Find the built frameworks
DEVICE_FRAMEWORK=$(find "$BUILD_DIR/DerivedData" -name "JKLoger.framework" -path "*Release-iphoneos*" | head -1)
SIMULATOR_FRAMEWORK=$(find "$BUILD_DIR/DerivedData" -name "JKLoger.framework" -path "*Release-iphonesimulator*" | head -1)

if [ -z "$DEVICE_FRAMEWORK" ] || [ -z "$SIMULATOR_FRAMEWORK" ]; then
    print_status "ERROR" "Could not find built frameworks"
    echo "Device framework: $DEVICE_FRAMEWORK"
    echo "Simulator framework: $SIMULATOR_FRAMEWORK"
    exit 1
fi

print_status "OK" "Found device framework: $(basename $(dirname $DEVICE_FRAMEWORK))"
print_status "OK" "Found simulator framework: $(basename $(dirname $SIMULATOR_FRAMEWORK))"

# Create XCFramework
xcodebuild -create-xcframework \
    -framework "$DEVICE_FRAMEWORK" \
    -framework "$SIMULATOR_FRAMEWORK" \
    -output "$BUILD_DIR/JKLoger.xcframework"

if [ $? -eq 0 ]; then
    print_status "OK" "XCFramework created successfully"
else
    print_status "ERROR" "XCFramework creation failed"
    exit 1
fi

# Archive XCFramework
echo ""
echo -e "${BLUE}📦 Archiving XCFramework${NC}"
echo "--------------------------------------------------"
cd "$BUILD_DIR"
zip -r JKLoger.xcframework.zip JKLoger.xcframework
print_status "OK" "XCFramework archived as JKLoger.xcframework.zip"

# Build Example Project
echo ""
echo -e "${BLUE}📱 Building Example Project${NC}"
echo "--------------------------------------------------"
cd "$PROJECT_ROOT/Example"
xcodebuild \
    -workspace JKLogerExample.xcworkspace \
    -scheme JKLogerExample \
    -configuration Release \
    -destination 'platform=iOS Simulator,OS=17.0,name=iPhone 15 Pro' \
    -derivedDataPath "$BUILD_DIR/ExampleDerivedData" \
    clean build \
    CODE_SIGNING_REQUIRED=NO \
    CODE_SIGN_IDENTITY="" \
    PROVISIONING_PROFILE="" \
    | xcpretty

if [ $? -eq 0 ]; then
    print_status "OK" "Example project build completed successfully"
else
    print_status "ERROR" "Example project build failed"
    exit 1
fi

# Generate build report
echo ""
echo -e "${BLUE}📊 Build Report${NC}"
echo "=================================================="
echo "Build completed successfully!"
echo ""
echo "Artifacts:"
echo "  📦 XCFramework: $BUILD_DIR/JKLoger.xcframework"
echo "  📦 Archive: $BUILD_DIR/JKLoger.xcframework.zip"
echo "  📱 Example App: Built successfully"
echo ""
echo "Framework Info:"
if [ -f "$BUILD_DIR/JKLoger.xcframework/Info.plist" ]; then
    echo "  📋 Supported Platforms:"
    plutil -p "$BUILD_DIR/JKLoger.xcframework/Info.plist" | grep -A 10 "SupportedPlatform" | grep "\"ios\"" && echo "    - iOS"
fi

# Calculate sizes
XCFRAMEWORK_SIZE=$(du -sh "$BUILD_DIR/JKLoger.xcframework" | cut -f1)
ARCHIVE_SIZE=$(du -sh "$BUILD_DIR/JKLoger.xcframework.zip" | cut -f1)
echo "  📏 XCFramework Size: $XCFRAMEWORK_SIZE"
echo "  📏 Archive Size: $ARCHIVE_SIZE"

echo ""
print_status "OK" "Build script completed successfully!"
echo ""
echo "Next steps:"
echo "  1. Test the XCFramework in a sample project"
echo "  2. Run the test suite: ./Scripts/test.sh"
echo "  3. Validate with CocoaPods: pod lib lint JKLoger.podspec"
echo "  4. Create a release: git tag v1.0.1 && git push --tags"