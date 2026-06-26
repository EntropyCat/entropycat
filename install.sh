#!/bin/sh
set -e

REPO="EntropyCat/entropycat"
INSTALL_DIR="/usr/local/bin"

# ── detect OS and arch ────────────────────────────────────────────────────────

os=$(uname -s)
arch=$(uname -m)

case "$os" in
  Darwin) os="darwin" ;;
  Linux)  os="linux"  ;;
  *)
    echo "Unsupported OS: $os"
    echo "See https://github.com/$REPO for manual installation."
    exit 1
    ;;
esac

case "$arch" in
  x86_64)          arch="x86_64" ;;
  arm64 | aarch64) arch="arm64"  ;;
  *)
    echo "Unsupported architecture: $arch"
    echo "See https://github.com/$REPO for manual installation."
    exit 1
    ;;
esac

# ── resolve version ───────────────────────────────────────────────────────────

if [ -z "$VERSION" ]; then
  VERSION=$(curl -fsSL "https://api.github.com/repos/$REPO/releases/latest" \
    | grep '"tag_name"' | cut -d'"' -f4 | sed 's/^v//')
fi

if [ -z "$VERSION" ]; then
  echo "Could not determine latest version. Set VERSION= to install a specific version."
  exit 1
fi

# ── download and install ──────────────────────────────────────────────────────

asset="entropycat_${VERSION}_${os}_${arch}.zip"
url="https://github.com/$REPO/releases/download/v${VERSION}/${asset}"
tmp=$(mktemp -d)

echo "Installing entropycat v${VERSION} (${os}/${arch})..."
curl -fsSL "$url" -o "$tmp/$asset"

cd "$tmp"
unzip -q "$asset"
extracted=$(ls -d entropycat_*/)

# Standalone build: a folder of the launcher + its dylibs/data. Install the whole
# folder to LIB_DIR and symlink just the launcher onto PATH.
LIB_DIR="/usr/local/lib/entropycat"
if [ -w "$INSTALL_DIR" ] && [ -w "$(dirname "$LIB_DIR")" ]; then
  rm -rf "$LIB_DIR"
  mkdir -p "$LIB_DIR"
  cp -R "${extracted}." "$LIB_DIR/"
  ln -sf "$LIB_DIR/entropycat" "$INSTALL_DIR/entropycat"
else
  sudo rm -rf "$LIB_DIR"
  sudo mkdir -p "$LIB_DIR"
  sudo cp -R "${extracted}." "$LIB_DIR/"
  sudo ln -sf "$LIB_DIR/entropycat" "$INSTALL_DIR/entropycat"
fi

chmod +x "$LIB_DIR/entropycat"
rm -rf "$tmp"

echo ""
echo "entropycat v${VERSION} installed to $INSTALL_DIR"
echo "Get started:"
echo "  entropycat init    # one-time setup wizard"
echo "  entropycat start   # start the server"
