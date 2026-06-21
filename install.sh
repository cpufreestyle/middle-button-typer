#!/bin/bash
set -e

APP_NAME="MiddleButtonTyper"
APP_BUNDLE="${APP_NAME}.app"
SOURCE_DIR="$(cd "$(dirname "$0")"; pwd)"
APP_SOURCE="${SOURCE_DIR}/${APP_BUNDLE}"
APP_DEST="${HOME}/Applications/${APP_BUNDLE}"
PLIST_LABEL="com.cpufreestyle.middle-button-typer"
PLIST_DEST="${HOME}/Library/LaunchAgents/${PLIST_LABEL}.plist"

if [ ! -d "$APP_SOURCE" ]; then
    echo "❌ 未找到 ${APP_BUNDLE}，先运行 ./build.sh 编译"
    exit 1
fi

echo "🔧 安装 ${APP_NAME} 到 ~/Applications..."
mkdir -p "${HOME}/Applications"
rm -rf "$APP_DEST"
cp -R "$APP_SOURCE" "$APP_DEST"
chmod +x "${APP_DEST}/Contents/MacOS/${APP_NAME}"

echo "🔒 重新签名..."
codesign --force --deep --sign - "$APP_DEST" 2>/dev/null || true

echo "📝 创建 launchd 启动项..."
mkdir -p "$(dirname "$PLIST_DEST")"

cat > "$PLIST_DEST" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>${PLIST_LABEL}</string>
    <key>ProgramArguments</key>
    <array>
        <string>${APP_DEST}/Contents/MacOS/${APP_NAME}</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <dict>
        <key>SuccessfulExit</key>
        <false/>
        <key>Crashed</key>
        <true/>
    </dict>
    <key>ThrottleInterval</key>
    <integer>10</integer>
    <key>ProcessType</key>
    <string>Interactive</string>
    <key>EnvironmentVariables</key>
    <dict>
        <key>HOME</key>
        <string>${HOME}</string>
        <key>PATH</key>
        <string>/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:${HOME}/bin</string>
    </dict>
    <key>StandardOutPath</key>
    <string>/tmp/middle_button_typer.log</string>
    <key>StandardErrorPath</key>
    <string>/tmp/middle_button_typer.log</string>
</dict>
</plist>
EOF

chmod 644 "$PLIST_DEST"

echo "🚀 加载并启动服务..."
launchctl unload "$PLIST_DEST" 2>/dev/null || true
launchctl load "$PLIST_DEST"
launchctl start "$PLIST_LABEL"

echo ""
echo "✅ 安装完成"
echo ""
echo "📌 重要：请手动添加 Login Items 作为最稳方案："
echo "   系统设置 → 通用 → 登录项 → 点 + → 选择 ~/Applications/MiddleButtonTyper.app"
echo ""
echo "📌 首次运行需要授权："
echo "   系统设置 → 隐私与安全性 → 辅助功能 → 允许 MiddleButtonTyper"
echo ""
echo "📝 查看日志：tail -f /tmp/middle_button_typer.log"
echo "🗑️  卸载：./uninstall.sh"
