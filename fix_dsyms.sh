#!/bin/bash

# Script to fix missing dSYM files for Firebase and gRPC frameworks
# Run this script after archiving your app for TestFlight

echo "🔧 Fixing missing dSYM files for Firebase and gRPC frameworks..."

# Get the archive path from command line argument or use default
ARCHIVE_PATH="${1:-~/Library/Developer/Xcode/Archives}"
if [ ! -d "$ARCHIVE_PATH" ]; then
    echo "❌ Archive path not found: $ARCHIVE_PATH"
    echo "Usage: $0 [archive_path]"
    exit 1
fi

# Find the most recent archive
LATEST_ARCHIVE=$(find "$ARCHIVE_PATH" -name "*.xcarchive" -type d | sort | tail -1)
if [ -z "$LATEST_ARCHIVE" ]; then
    echo "❌ No .xcarchive found in $ARCHIVE_PATH"
    exit 1
fi

echo "📦 Found archive: $LATEST_ARCHIVE"

# Paths within the archive
DSYMS_PATH="$LATEST_ARCHIVE/dSYMs"
PRODUCTS_PATH="$LATEST_ARCHIVE/Products/Applications"

# Create dSYMs directory if it doesn't exist
mkdir -p "$DSYMS_PATH"

# Function to copy dSYM if it exists
copy_dsym() {
    local framework_name=$1
    local dsym_path="$BUILD_DIR/Debug-iphoneos/$framework_name.framework.dSYM"
    
    if [ -d "$dsym_path" ]; then
        echo "✅ Copying dSYM for $framework_name"
        cp -R "$dsym_path" "$DSYMS_PATH/"
    else
        echo "⚠️  dSYM not found for $framework_name at $dsym_path"
    fi
}

# List of frameworks that commonly have missing dSYMs
FRAMEWORKS=(
    "FirebaseFirestoreInternal"
    "absl"
    "grpc"
    "grpcpp"
    "openssl_grpc"
    "FirebaseAuth"
    "FirebaseCore"
    "FirebaseFirestore"
    "GoogleSignIn"
    "GoogleSignInSwift"
)

echo "🔍 Looking for dSYM files..."

# Try to find dSYMs in common locations
BUILD_DIRS=(
    "$(xcodebuild -showBuildSettings -project Reframe.xcodeproj -target Reframe -configuration Release | grep BUILD_DIR | awk '{print $3}')"
    "$(find ~/Library/Developer/Xcode/DerivedData -name '*Reframe*' -type d | head -1)"
    "$(find . -name 'DerivedData' -type d | head -1)"
)

for BUILD_DIR in "${BUILD_DIRS[@]}"; do
    if [ -d "$BUILD_DIR" ]; then
        echo "🔍 Searching in: $BUILD_DIR"
        
        # Copy dSYMs for specific frameworks
        for framework in "${FRAMEWORKS[@]}"; do
            copy_dsym "$framework"
        done
        
        # Also copy any other dSYMs found
        find "$BUILD_DIR" -name "*.dSYM" -type d | while read dsym; do
            framework_name=$(basename "$dsym" .dSYM)
            echo "✅ Copying dSYM for: $framework_name"
            cp -R "$dsym" "$DSYMS_PATH/"
        done
        
        break
    fi
done

echo "📋 Current dSYMs in archive:"
ls -la "$DSYMS_PATH" 2>/dev/null || echo "No dSYMs found"

echo "✅ dSYM fix completed!"
echo "💡 You can now re-upload your archive to TestFlight" 