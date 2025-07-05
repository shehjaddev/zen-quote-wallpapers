#!/bin/bash

# Config paths
DIR="$HOME/wallpaper-rotator"
LOG="$DIR/wallpaper.log"
WALLPAPER="$DIR/wallpaper.jpg"

# Ensure environment for cron
export DISPLAY=:0
export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u)/bus"

# Required commands and their packages
declare -A CMD_PKG_MAP=(
  ["curl"]="curl"
  ["jq"]="jq"
  ["feh"]="feh"
  ["xdpyinfo"]="xdpyinfo"
  ["convert"]="imagemagick"
)

mkdir -p "$DIR"

# Logging
log() {
    echo "[$(date +"%Y-%m-%d %H:%M:%S")] $1" >> "$LOG"
}

# Auto install missing dependencies
install_if_missing() {
    local pkg="$1"
    local cmd="$2"
    if ! command -v "$cmd" >/dev/null 2>&1; then
        log "Installing missing package: $pkg"
        echo "Installing package: $pkg"
        sudo apt-get update && sudo apt-get install -y "$pkg"
        if ! command -v "$cmd" >/dev/null 2>&1; then
            log "Failed to install $pkg. Exiting."
            echo "Error: Could not install $pkg" >&2
            exit 1
        fi
    fi
}

check_and_install_dependencies() {
    for cmd in "${!CMD_PKG_MAP[@]}"; do
        install_if_missing "${CMD_PKG_MAP[$cmd]}" "$cmd"
    done
}

check_internet() {
    curl -m 5 -s -I --fail https://www.google.com >/dev/null 2>&1
}

get_wallpaper_from_picsum() {
    echo "https://picsum.photos/1920/1080.jpg?grayscale"
}

get_motivational_quote() {
    local quote
    quote=$(curl -s https://zenquotes.io/api/random | jq -r '.[0].q')

    if [[ -z "$quote" || "$quote" == *"Too many requests"* ]]; then
        echo "Keep pushing forward — Unknown"
    else
        echo "$quote"
    fi
}

# Overlay quote on image
overlay_quote() {
    local original_image="$1"

    local quote
    quote=$(get_motivational_quote)

    local width height
    width=$(identify -format "%w" "$original_image")
    height=$(identify -format "%h" "$original_image")
    local max_text_width=$((width * 3 / 10))

    convert -background none -fill white -font DejaVu-Sans -pointsize 32 \
        -size ${max_text_width}x -gravity center caption:"$quote" miff:- > "$DIR/quote_caption.miff"

    convert "$DIR/quote_caption.miff" \
        -bordercolor 'rgba(0,0,0,0.8)' -border 32x32 "$DIR/quote_padded.miff"

    composite -gravity center "$DIR/quote_padded.miff" "$original_image" "$original_image"

    rm -f "$DIR/quote_caption.miff" "$DIR/quote_padded.miff"
}

# Set wallpaper for gnome
set_wallpaper() {
    local img="$1"
    gsettings set org.gnome.desktop.background picture-uri "file://$img"
    gsettings set org.gnome.desktop.background picture-options 'scaled'
}

download_and_set_wallpaper() {
    local url
    url=$(get_wallpaper_from_picsum)

    curl -s -L "$url" -o "$WALLPAPER" || {
        echo "Failed to download wallpaper."
        return 1
    }

    overlay_quote "$WALLPAPER"
    set_wallpaper "$WALLPAPER"
    log "Wallpaper set from: $url"
}

run() {
    check_and_install_dependencies

    if check_internet; then
        download_and_set_wallpaper
    fi
}

run
