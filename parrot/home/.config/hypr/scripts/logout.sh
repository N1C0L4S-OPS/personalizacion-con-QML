#!/bin/bash
# Clean Hyprland Session Teardown Script

# Ask background daemons to exit gracefully (SIGTERM), then give them a moment
pkill -TERM -u "$USER" -x 'waybar|swaync|hyprpaper|hypridle|hyprpolkitagent|wlogout' 2>/dev/null
sleep 0.5

# Dispatch Hyprland exit
hyprctl dispatch exit 0
