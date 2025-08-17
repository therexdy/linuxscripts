#!/bin/bash

set -e

if [ $# -lt 2 ]; then
  read -rp "Enter Wine prefix (e.g. /home/username/wine/app): " WINEPREFIX
  read -rp "Enter app path inside drive_c (e.g. drive_c/Program Files/App/app.exe): " APP_PATH
else
  WINEPREFIX="$1"
  APP_PATH="$2"
fi

APP_EXE=$(basename "$APP_PATH")
APP_NAME="${APP_EXE%.*}"

SCRIPT_DIR="$HOME/.local/shapps"
DESKTOP_DIR="$HOME/.local/share/applications"

mkdir -p "$SCRIPT_DIR"
mkdir -p "$DESKTOP_DIR"

SCRIPT_PATH="$SCRIPT_DIR/$APP_NAME"
DESKTOP_PATH="$DESKTOP_DIR/$APP_NAME.desktop"

cat > "$SCRIPT_PATH" <<EOF
#!/bin/bash
WINEPREFIX="$WINEPREFIX" wine "\$WINEPREFIX/$APP_PATH"
EOF

chmod +x "$SCRIPT_PATH"

cat > "$DESKTOP_PATH" <<EOF
[Desktop Entry]
Name=$APP_NAME
Comment=Run $APP_NAME via Wine
Exec=$SCRIPT_PATH
Icon=wine
Terminal=false
Type=Application
Categories=Wine;Application;
EOF

echo "Launcher created:"
echo "  Script: $SCRIPT_PATH"
echo "  Desktop entry: $DESKTOP_PATH"

