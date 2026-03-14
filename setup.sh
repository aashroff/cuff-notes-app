#!/bin/bash
# CuffNotes - Quick Setup Script
# Run this after cloning the repo

set -e

echo "============================================"
echo "  CuffNotes - Setup"
echo "============================================"
echo ""

# Check Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "ERROR: Flutter is not installed."
    echo "Install it from: https://flutter.dev/docs/get-started/install"
    exit 1
fi

echo "[1/4] Checking Flutter environment..."
flutter doctor --android-licenses 2>/dev/null || true
flutter doctor

echo ""
echo "[2/4] Installing dependencies..."
flutter pub get

echo ""
echo "[3/4] Verifying project builds..."
flutter analyze || echo "Warning: Some analysis issues found (non-blocking)"

echo ""
echo "[4/4] Done! Run the app with:"
echo ""
echo "  flutter run"
echo ""
echo "To build for release:"
echo "  flutter build appbundle --release   # Android"
echo "  flutter build ipa --release         # iOS (macOS only)"
echo ""
echo "============================================"
echo "  Next steps:"
echo "  1. Update lib/services/content_service.dart"
echo "     with your GitHub username"
echo "  2. Create the cuffnotes-content repo on GitHub"
echo "  3. Run 'flutter run' to test on a device"
echo "============================================"
