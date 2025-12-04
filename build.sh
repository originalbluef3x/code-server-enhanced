#!/usr/bin/env bash
set -e

if git describe --tags >/dev/null 2>&1; then
  VERSION=$(git describe --tags)
else
  VERSION="0.0.0-$(git rev-parse --short HEAD)"
fi

export VERSION

npm ci
npm run build
npm run release

mkdir -p release-out
cp -r release-*/* release-out/

echo "$VERSION" > release-out/VERSION
