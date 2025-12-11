#!/bin/sh
set -eu

GITHUB_REPO="originalbluef3x/code-server-enhanced"
CACHE_DIR="$HOME/.cache/code-server-enhanced"
PREFIX="${PREFIX:-$HOME/.local}"

echoerr() { echo "$@" >&2; }

usage() {
  cat << EOF
Installs code-server-enhanced.

Usage:
  $0 [--dry-run] [--version X.X.X] [--method detect|standalone] [--prefix DIR]

Options:
  --dry-run      Show commands without running
  --version      Install specific version (default: latest stable release)
  --method       detect or standalone (default: detect)
  --prefix       Installation prefix for standalone (default: $HOME/.local)
EOF
}

latest_version() {
  tag=$(curl -fsSL "https://api.github.com/repos/$GITHUB_REPO/releases" \
    | awk '/"tag_name":/ {gsub(/[",]/,"",$2); print $2}' \
    | head -n 1)

  if [ -z "$tag" ]; then
    echoerr "No valid stable releases found for $GITHUB_REPO"
    exit 1
  fi

  echo "${tag#v}"
}

os() {
  uname | tr '[:upper:]' '[:lower:]'
}

arch() {
  case "$(uname -m)" in
    x86_64) echo amd64 ;;
    aarch64) echo arm64 ;;
    *) echo "$(uname -m)" ;;
  esac
}

fetch() {
  url="$1"
  out="$2"
  [ -f "$out" ] && return
  mkdir -p "$CACHE_DIR"
  echo "Downloading $url"
  curl -fL -o "$out" "$url"
}

install_deb() {
  file="$CACHE_DIR/code-server_${VERSION}_$ARCH.deb"
  url="https://github.com/$GITHUB_REPO/releases/download/v$VERSION/code-server_${VERSION}_$ARCH.deb"
  fetch "$url" "$file"
  sudo dpkg -i "$file"
}

install_rpm() {
  file="$CACHE_DIR/code-server-$VERSION-$ARCH.rpm"
  url="https://github.com/$GITHUB_REPO/releases/download/v$VERSION/code-server-$VERSION-$ARCH.rpm"
  fetch "$url" "$file"
  sudo rpm -U "$file"
}

install_standalone() {
  file="$CACHE_DIR/code-server-$VERSION-$(os)-$(arch).tar.gz"
  url="https://github.com/$GITHUB_REPO/releases/download/v$VERSION/code-server-$VERSION-$(os)-$(arch).tar.gz"
  fetch "$url" "$file"

  mkdir -p "$PREFIX/lib" "$PREFIX/bin"
  tar -xzf "$file" -C "$PREFIX/lib"
  mv "$PREFIX/lib/code-server-$VERSION-$(os)-$(arch)" "$PREFIX/lib/code-server-$VERSION"
  ln -sf "$PREFIX/lib/code-server-$VERSION/bin/code-server" "$PREFIX/bin/code-server"

  echo "Installed to $PREFIX/bin/code-server"
}

main() {
  METHOD="detect"
  DRY_RUN=0

  while [ "$#" -gt 0 ]; do
    case "$1" in
      --dry-run) DRY_RUN=1 ;;
      --version) shift; VERSION="$1" ;;
      --method) shift; METHOD="$1" ;;
      --prefix) shift; PREFIX="$1" ;;
      -h|--help) usage; exit 0 ;;
      *) break ;;
    esac
    shift
  done

  VERSION="${VERSION:-$(latest_version)}"
  OS="$(os)"
  ARCH="$(arch)"

  mkdir -p "$CACHE_DIR"

  if [ "$METHOD" = "standalone" ]; then
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

main "$@"
