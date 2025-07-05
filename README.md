# Zen Quote Wallpapers

A simple Bash script to automatically set grayscale desktop wallpapers with motivational quotes from ZenQuotes API.

![Wallpaper screenshot](https://raw.githubusercontent.com/shehjaddev/zen-quote-wallpapers/refs/heads/master/wallpaper.jpg)

## Features
- Downloads grayscale wallpapers from Picsum Photos
- Overlays random motivational quotes from ZenQuotes API
- Sets wallpaper for GNOME desktop
- Automatically installs required dependencies
- Logs activities to a file

## Requirements
- Linux system with GNOME desktop
- Bash
- Internet connection

## Installation
1. Save the script as `wallpaper.sh`
2. Make it executable: `chmod +x wallpaper.sh`
3. Run it: `./wallpaper.sh`

## Usage
- Run manually: `./wallpaper.sh`
- Add to cron for automatic rotation (e.g., hourly):
  ```bash
  0 * * * * /path/to/wallpaper.sh
  ```

## Files
- Wallpapers are saved in `~/wallpaper/`
- Logs are written to `~/wallpaper/wallpaper.log`