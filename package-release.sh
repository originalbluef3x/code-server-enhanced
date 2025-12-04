#!/usr/bin/env bash
set -e

rm -rf dist
mkdir dist

tar -czf dist/code-server-enhanced.tar.gz -C release-out .
