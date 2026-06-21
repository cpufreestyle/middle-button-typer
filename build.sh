#!/bin/bash
set -e

cd "$(dirname "$0")"

APP_NAME="MiddleButtonTyper"
APP_BUNDLE="${APP_NAME}.app"

echo "🔨 Compiling ${APP_NAME}..."
swiftc -framework Cocoa -framework CoreGraphics main.swift -o "${APP_NAME}"

echo "📦 Building .app bundle..."
mkdir -p "${APP_BUNDLE}/Contents/MacOS"
mkdir -p "${APP_BUNDLE}/Contents/Resources"
cp "${APP_NAME}" "${APP_BUNDLE}/Contents/MacOS/${APP_NAME}"

cat > "${APP_BUNDLE}/Contents/Info.plist" <<'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>zh_CN</string>
    <key>CFBundleExecutable</key>
    <string>MiddleButtonTyper</string>
    <key>CFBundleIdentifier</key>
    <string>com.cpufreestyle.middle-button-typer</string>
    <key>CFBundleName</key>
    <string>MiddleButtonTyper</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0.5</string>
    <key>CFBundleVersion</key>
    <string>5</string>
    <key>LSMinimumSystemVersion</key>
    <string>12.0</string>
    <key>LSUIElement</key>
    <true/>
    <key>NSHumanReadableCopyright</key>
    <string>Copyright © 2026 cpufreestyle. MIT License.</string>
</dict>
</plist>
EOF

echo "🔒 Codesigning..."
codesign --force --deep --sign - "${APP_BUNDLE}" 2>/dev/null || true

echo ""
echo "✅ Build complete: $(pwd)/${APP_BUNDLE}"

# 打包 release zip，包含 .app + 安装脚本
ZIP_NAME="${APP_NAME}-1.0.5.zip"
rm -f "${ZIP_NAME}"
zip -r "${ZIP_NAME}" "${APP_BUNDLE}" install.sh uninstall.sh README.md .gitignore -x "*.DS_Store"
echo ""
echo "📦 Release zip: $(pwd)/${ZIP_NAME}"
