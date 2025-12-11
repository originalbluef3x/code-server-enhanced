#!/bin/sh
set -eu

GITHUB_REPO="originalbluef3x/code-server-enhanced"

usage() {
  arg0="$0"
  if [ "$0" = sh ]; then
    arg0="curl -fsSL https://raw.githubusercontent.com/$GITHUB_REPO/main/install.sh | sh -s --"
  fi

  cath << EOF
Installs code-server-enhanced.

Usage:
  $arg0 [--dry-run] [--version X.X.X] [--edge] [--method detect|standalone]
        [--prefix ~/.local] [user@host]

EOF
}

echo_latest_version() {
  if [ "${EDGE-}" ]; then
    tag="$(curl -fsSL https://api.github.com/repos/$GITHUB_REPO/releases \
      | awk '/"tag_name":/ {print $4; exit}')"
  else
    tag="$(curl -fsSLI -o /dev/null -w "%{url_effective}" \
      https://github.com/$GITHUB_REPO/releases/latest)"
    tag="${tag##*/}"
  fi
  echo "${tag#v}"
}

main() {
  METHOD=detect

  while [ "$#" -gt 0 ]; do
    case "$1" in
      --dry-run) DRY_RUN=1 ;;
      --edge) EDGE=1 ;;
      --version) shift; VERSION="$1" ;;
      --method) shift; METHOD="$1" ;;
      --prefix) shift; PREFIX="$1" ;;
      -h|--help) usage; exit 0 ;;
      *) break ;;
    esac
    shift
  done

  VERSION="${VERSION:-$(echo_latest_version)}"
  PREFIX="${PREFIX:-$HOME/.local}"
  CACHE="$HOME/.cache/code-server-enhanced"
  OS="$(uname | tr '[:upper:]' '[:lower:]')"
  ARCH="$(uname -m)"

  [ "$ARCH" = "x86_64" ] && ARCH=amd64
  [ "$ARCH" = "aarch64" ] && ARCH=arm64

  mkdir -p "$CACHE"

  if [ "$METHOD" = standalone ]; then
    install_standalone
    exit 0
  fi

  if command -v apt >/dev/null 2>&1; then
    install_deb && exit 0
  fi

  if command -v dnf >/dev/null 2>&1 || command -v yum >/dev/null 2>&1; then
    install_rpm && exit 0
  fi

  install_standalone
}

install_deb() {
  FILE="$CACHE/code-server_${VERSION}_$ARCH.deb"
  URL="https://github.com/$GITHUB_REPO/releases/download/v$VERSION/code-server_${VERSION}_$ARCH.deb"

  fetch "$URL" "$FILE"
  sudo dpkg -i "$FILE"
}

install_rpm() {
  FILE="$CACHE/code-server-$VERSION-$ARCH.rpm"
  URL="https://github.com/$GITHUB_REPO/releases/download/v$VERSION/code-server-$VERSION-$ARCH.rpm"

  fetch "$URL" "$FILE"
  sudo rpm -U "$FILE"
}

install_standalone() {
  FILE="$CACHE/code-server-$VERSION-$OS-$ARCH.tar.gz"
  URL="https://github.com/$GITHUB_REPO/releases/download/v$VERSION/code-server-$VERSION-$OS-$ARCH.tar.gz"

  fetch "$URL" "$FILE"

  mkdir -p "$PREFIX/lib" "$PREFIX/bin"
  tar -xzf "$FILE" -C "$PREFIX/lib"
  mv "$PREFIX/lib/code-server-$VERSION-$OS-$ARCH" "$PREFIX/lib/code-server-$VERSION"
  ln -sf "$PREFIX/lib/code-server-$VERSION/bin/code-server" "$PREFIX/bin/code-server"

  echo "Installed to $PREFIX/bin/code-server"
}

fetch() {
  [ -f "$2" ] && return
  echo "Downloading $1"
  curl -fL -o "$2" "$1"
}

main "$@"
