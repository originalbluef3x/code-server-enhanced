#!/usr/bin/env bash
set -e
export CC=gcc-13
export CXX=g++-13

# Determine version
if git describe --tags >/dev/null 2>&1; then
  VERSION=$(git describe --tags)
else
  VERSION="0.0.0-$(git rev-parse --short HEAD)"
fi
export VERSION

# Install dependencies and build
npm ci
npm run build

# Optional: run release process if you have one
npm run release || true

# Copy build output to release-out
mkdir -p release-out
cp -r release-*/* release-out/

echo "$VERSION" > release-out/VERSION

echo "Build complete: version $VERSION"
