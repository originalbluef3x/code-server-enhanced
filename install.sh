#!/bin/sh
set -eu

REPO_OWNER="originalbluef3x"
REPO_NAME="code-server-enhanced"

os() {
  u="$(uname)"
  case "$u" in
    Linux) echo linux ;;
    Darwin) echo macos ;;
    FreeBSD) echo freebsd ;;
    *) echo "$u" ;;
  esac
}

arch() {
  m="$(uname -m)"
  case "$m" in
    aarch64) echo arm64 ;;
    x86_64) echo amd64 ;;
    *) echo "$m" ;;
  esac
}

latest_version() {
  x="$(curl -fsSLI -o /dev/null -w "%{url_effective}" https://github.com/$REPO_OWNER/$REPO_NAME/releases/latest)"
  x="${x##*/}"
  x="${x#v}"
  echo "$x"
}

download() {
  curl -#fL "$1" -o "$2.incomplete"
  mv "$2.incomplete" "$2"
}

PREFIX="${PREFIX:-$HOME/.local}"
OS="$(os)"
ARCH="$(arch)"
VERSION="${VERSION:-$(latest_version)}"

TAR="code-server-$VERSION-$OS-$ARCH.tar.gz"
URL="https://github.com/$REPO_OWNER/$REPO_NAME/releases/download/v$VERSION/$TAR"

mkdir -p "$PREFIX/lib" "$PREFIX/bin"
CACHE="$HOME/.cache/code-server-enhanced"
mkdir -p "$CACHE"

FILE="$CACHE/$TAR"
download "$URL" "$FILE"

tar -C "$PREFIX/lib" -xzf "$FILE"

mv -f "$PREFIX/lib/code-server-$VERSION-$OS-$ARCH" "$PREFIX/lib/code-server-$VERSION"

ln -fs "$PREFIX/lib/code-server-$VERSION/bin/code-server" "$PREFIX/bin/code-server"

echo "Installed code-server-$VERSION"
echo "Add $PREFIX/bin to PATH if needed"
