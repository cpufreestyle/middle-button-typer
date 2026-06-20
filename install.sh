#!/bin/bash
set -e

cd "$(dirname "$0")"

echo "Building MiddleButtonTyper..."
./build.sh

echo "Installing launchd plist..."
PLIST_SRC="$(pwd)/com.a1-6.middle-button-typer.plist"
PLIST_DEST="$HOME/Library/LaunchAgents/com.a1-6.middle-button-typer.plist"

cp "$PLIST_SRC" "$PLIST_DEST"
chmod 644 "$PLIST_DEST"

echo "Loading launchd service..."
launchctl load "$PLIST_DEST" || true
launchctl start com.a1-6.middle-button-typer

echo "Installation complete. Middle button typer is now running as a service."
echo "Check logs: tail -f /tmp/middle_button_typer.log"
