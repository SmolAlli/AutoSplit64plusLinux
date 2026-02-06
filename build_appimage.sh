#!/bin/bash
set -e

# ==========================================
# CONFIGURATION
# ==========================================
REPO_ROOT=$(pwd)
# Use /tmp to avoid issues with spaces in path
BUILD_ROOT="/tmp/as64_build_$(date +%s)"
APP_DIR="$BUILD_ROOT/AppDir"
BUILD_DIR="$BUILD_ROOT/build_artifacts"
# Path to host Python 3.11 installation to bundle
PYTHON_HOST_PATH="/home/poke/.pyenv/versions/3.11.9"

echo "Build started at $(date)"
echo "Build root: $BUILD_ROOT"

# ==========================================
# PREPARATION
# ==========================================
mkdir -p "$BUILD_ROOT"
mkdir -p "$APP_DIR/usr/src" "$BUILD_DIR"

# helper function to download if missing
download_if_missing() {
    local url="$1"
    local filename="$2"
    if [ ! -f "$REPO_ROOT/$filename" ]; then
        echo "Downloading $filename..."
        wget -q -nc "$url" -O "$REPO_ROOT/$filename"
        chmod +x "$REPO_ROOT/$filename"
    else
        echo "Using existing $filename"
    fi
}

# Download tools to REPO_ROOT (cached)
download_if_missing "https://github.com/linuxdeploy/linuxdeploy/releases/download/continuous/linuxdeploy-x86_64.AppImage" "linuxdeploy-x86_64.AppImage"
download_if_missing "https://github.com/AppImage/appimagetool/releases/download/continuous/appimagetool-x86_64.AppImage" "appimagetool-x86_64.AppImage"

# Copy requirements and entrypoint to build root
cp "$REPO_ROOT/requirements.txt" "$BUILD_ROOT/"
cp "$REPO_ROOT/entrypoint.sh" "$BUILD_ROOT/"

# Copy application files
echo "Copying application files..."
mkdir -p "$APP_DIR/usr/src"
# Copy all source directories
for dir in as64core as64gui as64processes logic obs-plugin resources routes templates; do
    if [ -d "$REPO_ROOT/$dir" ]; then
        cp -r "$REPO_ROOT/$dir" "$APP_DIR/usr/src/"
    fi
done
# Copy individual source files
cp "$REPO_ROOT/AutoSplit64.py" "$APP_DIR/usr/src/"
cp "$REPO_ROOT/config.ini" "$APP_DIR/usr/src/" 2>/dev/null || true
cp "$REPO_ROOT/defaults.ini" "$APP_DIR/usr/src/"

# Copy icon and desktop file
cp "$REPO_ROOT/AutoSplit64plus.desktop" "$APP_DIR/"
# Resize icon to 512x512 for AppImage compliance
convert "$REPO_ROOT/resources/gui/icons/icon.png" -resize 512x512! "$APP_DIR/autosplit64plus.png"

# ==========================================
# BUNDLING PYTHON & DEPENDENCIES
# ==========================================
# MANUALLY BUNDLE PYTHON 3.11 FROM HOST
echo "Bundling Python 3.11 from host ($PYTHON_HOST_PATH)..."
if [ ! -d "$PYTHON_HOST_PATH" ]; then
    echo "ERROR: Python path not found: $PYTHON_HOST_PATH"
    exit 1
fi
cp -r "$PYTHON_HOST_PATH/"* "$APP_DIR/usr/"

# Remove __pycache__
find "$APP_DIR/usr" -name "__pycache__" -type d -exec rm -rf {} +

export PIP_REQUIREMENTS="" 
export PYTHON_SOURCE=""
# Disable stripping to avoid failures with newer ELF features vs older strip tools
export NO_STRIP=true

# ==========================================
# LINUXDEPLOY (System Dependencies)
# ==========================================
# We run linuxdeploy BEFORE installing pip packages to avoid it trying to bundle their dependencies (which fails)
echo "Running linuxdeploy (phase 1)..."
"$REPO_ROOT/linuxdeploy-x86_64.AppImage" \
    --appdir "$APP_DIR" \
    --icon-file "$APP_DIR/autosplit64plus.png" \
    --desktop-file "$APP_DIR/AutoSplit64plus.desktop" \
    --custom-apprun "$BUILD_ROOT/entrypoint.sh" \
    --exclude-library "libssl*" \
    --exclude-library "libcrypto*"

# ==========================================
# PIP INSTALLATION
# ==========================================
echo "Installing pip dependencies..."
# Use headless opencv to avoid X11 library conflicts
sed -i 's/opencv-python==/opencv-python-headless==/' "$BUILD_ROOT/requirements.txt"
"$APP_DIR/usr/bin/pip3.11" install -r "$BUILD_ROOT/requirements.txt" --ignore-installed --prefix "$APP_DIR/usr"

# Remove __pycache__ again
find "$APP_DIR/usr" -name "__pycache__" -type d -exec rm -rf {} +

# ==========================================
# PACKAGING
# ==========================================
echo "Packaging AppImage with appimagetool..."
export ARCH=x86_64
"$REPO_ROOT/appimagetool-x86_64.AppImage" "$APP_DIR" "$REPO_ROOT/AutoSplit64plus-x86_64.AppImage"

echo "Done! AppImage created at $REPO_ROOT/AutoSplit64plus-x86_64.AppImage"

# Clean up build dir
rm -rf "$BUILD_ROOT"
echo "Cleaned up temporary build directory."
