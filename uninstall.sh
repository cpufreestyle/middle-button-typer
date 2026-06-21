#!/bin/bash
set -e

APP_NAME="MiddleButtonTyper"
APP_BUNDLE="${APP_NAME}.app"
APP_DEST="${HOME}/Applications/${APP_BUNDLE}"
PLIST_LABEL="com.cpufreestyle.middle-button-typer"
PLIST_DEST="${HOME}/Library/LaunchAgents/${PLIST_LABEL}.plist"

echo "🛑 停止 launchd 服务..."
launchctl stop "$PLIST_LABEL" 2>/dev/null || true
launchctl unload "$PLIST_DEST" 2>/dev/null || true

if [ -f "$PLIST_DEST" ]; then
    echo "🗑️ 删除启动项 ${PLIST_DEST}"
    rm -f "$PLIST_DEST"
fi

if [ -d "$APP_DEST" ]; then
    echo "🗑️ 删除应用 ${APP_DEST}"
    rm -rf "$APP_DEST"
fi

echo ""
echo "✅ 已卸载"
echo ""
echo "📌 注意：Login Items 里手动添加的条目还需要手动移除："
echo "   系统设置 → 通用 → 登录项"
