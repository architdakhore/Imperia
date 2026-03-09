#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# material-colors.sh — Imperia Shell
# Inspired by Imperia's Material You dynamic theming.
# Extracts dominant colors from a wallpaper and writes accent colors
# to Imperia's theme config as Material You-style palette.
#
# Requirements: python3, colorthief (pip install colorthief)
#   OR: imagemagick (fallback)
# Usage: material-colors.sh /path/to/wallpaper.jpg
# Output: JSON { primary, secondary, tertiary, background, surface }
# ─────────────────────────────────────────────────────────────────────────────

WALLPAPER="${1:-}"
IMPERIA_CFG="${XDG_CONFIG_HOME:-$HOME/.config}/imperia"
COLORS_FILE="$IMPERIA_CFG/material-colors.json"

if [ -z "$WALLPAPER" ] || [ ! -f "$WALLPAPER" ]; then
    echo '{"error": "No wallpaper provided"}'
    exit 1
fi

# ── Method 1: Python colorthief ───────────────────────────────────────────────
if command -v python3 &>/dev/null && python3 -c "import colorthief" 2>/dev/null; then
    JSON=$(python3 << PYEOF
from colorthief import ColorThief
import json, sys

ct = ColorThief("$WALLPAPER")
dominant = ct.get_color(quality=1)
palette  = ct.get_palette(color_count=6, quality=1)

def to_hex(rgb):
    return "#{:02x}{:02x}{:02x}".format(*rgb)

def darken(rgb, factor=0.3):
    return tuple(max(0, int(c * (1 - factor))) for c in rgb)

def lighten(rgb, factor=0.4):
    return tuple(min(255, int(c + (255 - c) * factor)) for c in rgb)

primary   = palette[0] if len(palette) > 0 else dominant
secondary = palette[1] if len(palette) > 1 else dominant
tertiary  = palette[2] if len(palette) > 2 else dominant

result = {
    "primary":     to_hex(primary),
    "secondary":   to_hex(secondary),
    "tertiary":    to_hex(tertiary),
    "background":  to_hex(darken(primary, 0.75)),
    "surface":     to_hex(darken(primary, 0.55)),
    "onPrimary":   "#ffffff" if sum(primary) < 382 else "#000000",
    "error":       "#cf6679",
    "allColors":   [to_hex(c) for c in palette]
}
print(json.dumps(result))
PYEOF
)
    echo "$JSON"
    echo "$JSON" > "$COLORS_FILE"
    exit 0
fi

# ── Method 2: imagemagick fallback ────────────────────────────────────────────
if command -v convert &>/dev/null; then
    # Get 5 most dominant colors
    COLORS=$(convert "$WALLPAPER" \
        -resize 100x100 \
        +dither -colors 5 \
        -format "%c" histogram:info:- 2>/dev/null \
        | sort -rn \
        | head -5 \
        | grep -oP '#[0-9a-fA-F]{6}' \
        | head -5)

    PRIMARY=$(echo "$COLORS" | sed -n '1p')
    SECONDARY=$(echo "$COLORS" | sed -n '2p')
    TERTIARY=$(echo "$COLORS" | sed -n '3p')

    if [ -z "$PRIMARY" ]; then
        PRIMARY="#6750A4"
        SECONDARY="#958DA5"
        TERTIARY="#B58392"
    fi

    JSON="{\"primary\":\"$PRIMARY\",\"secondary\":\"${SECONDARY:-$PRIMARY}\",\"tertiary\":\"${TERTIARY:-$PRIMARY}\",\"background\":\"#1c1b1f\",\"surface\":\"#2b2930\",\"onPrimary\":\"#ffffff\",\"error\":\"#cf6679\"}"
    echo "$JSON"
    echo "$JSON" > "$COLORS_FILE"
    exit 0
fi

# ── Fallback: Material You purple ─────────────────────────────────────────────
JSON='{"primary":"#6750A4","secondary":"#958DA5","tertiary":"#B58392","background":"#1c1b1f","surface":"#2b2930","onPrimary":"#ffffff","error":"#cf6679"}'
echo "$JSON"
echo "$JSON" > "$COLORS_FILE"
