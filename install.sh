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

# install both binaries
if [ -w "$INSTALL_DIR" ]; then
  cp "${extracted}entropycat"  "$INSTALL_DIR/entropycat"
  cp "${extracted}entropycatd" "$INSTALL_DIR/entropycatd"
else
  sudo cp "${extracted}entropycat"  "$INSTALL_DIR/entropycat"
  sudo cp "${extracted}entropycatd" "$INSTALL_DIR/entropycatd"
fi

chmod +x "$INSTALL_DIR/entropycat" "$INSTALL_DIR/entropycatd"
rm -rf "$tmp"

echo ""
echo "entropycat v${VERSION} installed to $INSTALL_DIR"
echo "Run: entropycat"
