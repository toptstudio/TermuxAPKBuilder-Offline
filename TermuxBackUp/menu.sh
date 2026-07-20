#!/bin/bash
set -Eeuo pipefail
IFS=$'\n\t'

if [[ -d /data/data/com.termux/files/usr ]]; then
    IS_TERMUX=true
    echo "[INFO] Running under Termux"
else
    IS_TERMUX=false
    echo "[INFO] Running under standard Linux"
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
echo "[INFO] Script directory: $SCRIPT_DIR"

do_restore() {
    echo "========================================="
    echo "  RESTORE (install offline .deb packages)"
    echo "========================================="

    if ! command -v dpkg >/dev/null 2>&1; then
        echo "[ERROR] dpkg not found. This script needs a dpkg-based system."
        exit 1
    fi

    ARCH_RAW=$(uname -m)
    case "$ARCH_RAW" in
        aarch64|arm64)   ARCH_DIR="arm64" ;;
        armv7l|armv6l)   ARCH_DIR="arm32" ;;
        x86_64|amd64)    ARCH_DIR="x86_64" ;;
        i686|i386)       ARCH_DIR="i686"  ;;
        *)
            echo "[WARN] Unknown architecture: $ARCH_RAW"
            echo "Please choose your architecture manually:"
            echo "  1) arm64"
            echo "  2) arm32"
            echo "  3) x86_64"
            echo "  4) i686"
            read -p "Choice [1-4]: " choice
            case "$choice" in
                1) ARCH_DIR="arm64" ;;
                2) ARCH_DIR="arm32" ;;
                3) ARCH_DIR="x86_64" ;;
                4) ARCH_DIR="i686"  ;;
                *) echo "[ERROR] Invalid choice."; exit 1 ;;
            esac
            ;;
    esac

    TARGET_DIR="$SCRIPT_DIR/$ARCH_DIR"
    echo "[INFO] Looking for .deb files in: $TARGET_DIR"

    if [[ ! -d "$TARGET_DIR" ]]; then
        echo "[ERROR] Folder $TARGET_DIR not found."
        exit 1
    fi

    DEB_COUNT=$(find "$TARGET_DIR" -maxdepth 1 -name '*.deb' | wc -l)
    if [[ $DEB_COUNT -eq 0 ]]; then
        echo "[ERROR] No .deb files found in $TARGET_DIR"
        exit 1
    fi

    echo "[INFO] Found $DEB_COUNT packages. Installing..."
    cd "$TARGET_DIR"
    dpkg --force-depends -i *.deb
    if $IS_TERMUX; then
        apt-get install -f --no-download -y
    else
        apt-get install -f -y
    fi

    echo "[SUCCESS] Restore completed for $ARCH_DIR"
}

do_backup() {
    echo "========================================="
    echo "  BACKUP (compress a folder to .zip)"
    echo "========================================="

    if ! command -v zip >/dev/null 2>&1; then
        echo "[ERROR] 'zip' not found. Install it first:"
        if $IS_TERMUX; then
            echo "  pkg install zip"
        else
            echo "  sudo apt install zip"
        fi
        exit 1
    fi

    read -p "Enter folder path to compress: " folder
    folder="${folder%/}"
    if [[ ! -d "$folder" ]]; then
        echo "[ERROR] Folder '$folder' does not exist."
        exit 1
    fi

    read -p "Enter name for the .zip file (without .zip): " zipname
    case "$zipname" in
        *.zip) ;;
        *) zipname="${zipname}.zip" ;;
    esac

    echo "[INFO] Zipping '$folder' → '$zipname' ..."
    if zip -r "$zipname" "$folder"; then
        echo "[SUCCESS] Created: $(realpath "$zipname")"
    else
        echo "[ERROR] Zipping failed."
        exit 1
    fi
}

echo ""
echo "======================================="
echo "  Offline Restore & Backup"
echo "======================================="
echo "  1) Restore (install .deb packages)"
echo "  2) Backup  (zip a folder)"
echo "======================================="
read -p "Choose an option [1-2]: " option

case "$option" in
    1) do_restore ;;
    2) do_backup  ;;
    *) echo "[ERROR] Invalid option."; exit 1 ;;
esac
