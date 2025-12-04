#!/usr/bin/env bash
set -e

VERSION=$(cat release-out/VERSION)
DIST_DIR="dist"
rm -rf "$DIST_DIR"
mkdir -p "$DIST_DIR"

# Define target platforms
PLATFORMS=("linux" "darwin" "win32")

for PLATFORM in "${PLATFORMS[@]}"; do
    echo "Packaging for $PLATFORM..."

    # Platform-specific build hook (if needed)
    # npm run build -- --platform="$PLATFORM"  # Uncomment if you can do cross-platform builds

    TMP_DIR="release-$PLATFORM"
    mkdir -p "$TMP_DIR"
    cp -r release-out/* "$TMP_DIR/"

    # Package
    if [ "$PLATFORM" = "win32" ]; then
        zip -r "$DIST_DIR/code-server-enhanced-$VERSION-windows.zip" "$TMP_DIR"
    else
        tar -czf "$DIST_DIR/code-server-enhanced-$VERSION-$PLATFORM.tar.gz" -C "$TMP_DIR" .
    fi

    rm -rf "$TMP_DIR"
done

echo "Packaging complete. Artifacts are in $DIST_DIR/"
