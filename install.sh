#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════════════════════
#
#  ██╗███╗   ███╗██████╗ ███████╗██████╗ ██╗ █████╗
#  ██║████╗ ████║██╔══██╗██╔════╝██╔══██╗██║██╔══██╗
#  ██║██╔████╔██║██████╔╝█████╗  ██████╔╝██║███████║
#  ██║██║╚██╔╝██║██╔═══╝ ██╔══╝  ██╔══██╗██║██╔══██║
#  ██║██║ ╚═╝ ██║██║     ███████╗██║  ██║██║██║  ██║
#  ╚═╝╚═╝     ╚═╝╚═╝     ╚══════╝╚═╝  ╚═╝╚═╝╚═╝  ╚═╝
#
#  Quickshell-based Wayland Desktop Shell
#
# ═══════════════════════════════════════════════════════════════════════════════
set -e

# ── Terminal colors & symbols ─────────────────────────────────────────────────
BLK='\033[0;30m'  RED='\033[0;31m'  GRN='\033[0;32m'  YLW='\033[0;33m'
BLU='\033[0;34m'  PRP='\033[0;35m'  CYN='\033[0;36m'  WHT='\033[0;37m'
BBLK='\033[1;30m' BRED='\033[1;31m' BGRN='\033[1;32m' BYLW='\033[1;33m'
BBLU='\033[1;34m' BPRP='\033[1;35m' BCYN='\033[1;36m' BWHT='\033[1;37m'
DIM='\033[2m'     UL='\033[4m'      BLINK='\033[5m'   REV='\033[7m'
RST='\033[0m'

SHELL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/quickshell"
HYPR_CFG="$HOME/.config/hypr/conf"
LOG_FILE="/tmp/imperia-install-$(date +%s).log"

TOTAL_STEPS=7
CURRENT_STEP=0

# ── Utility functions ─────────────────────────────────────────────────────────

header() {
    echo
    echo -e "${BPRP}╔══════════════════════════════════════════════════════════════════════════╗${RST}"
    echo -e "${BPRP}║${RST}  ${BCYN}$1${RST}"
    echo -e "${BPRP}╚══════════════════════════════════════════════════════════════════════════╝${RST}"
}

section() {
    CURRENT_STEP=$((CURRENT_STEP + 1))
    local pct=$(( CURRENT_STEP * 100 / TOTAL_STEPS ))
    local filled=$(( CURRENT_STEP * 40 / TOTAL_STEPS ))
    local empty=$(( 40 - filled ))
    local bar="${BGRN}"
    for i in $(seq 1 $filled); do bar+="█"; done
    bar+="${DIM}"
    for i in $(seq 1 $empty); do bar+="░"; done
    bar+="${RST}"
    echo
    echo -e "${BBLU}┌─ Step ${CURRENT_STEP}/${TOTAL_STEPS} ─────────────────────────────────────────────────────────────┐${RST}"
    echo -e "${BBLU}│${RST}  ${BWHT}$1${RST}"
    echo -e "${BBLU}│${RST}  [${bar}] ${BYLW}${pct}%${RST}"
    echo -e "${BBLU}└────────────────────────────────────────────────────────────────────────────┘${RST}"
}

ok()   { echo -e "  ${BGRN}✔${RST}  $1"; }
info() { echo -e "  ${BCYN}ℹ${RST}  $1"; }
warn() { echo -e "  ${BYLW}⚠${RST}  $1"; }
fail() { echo -e "  ${BRED}✖${RST}  $1"; }
sub()  { echo -e "  ${DIM}    $1${RST}"; }

spinner() {
    local pid=$1
    local msg="$2"
    local frames=('⣾' '⣽' '⣻' '⢿' '⡿' '⣟' '⣯' '⣷')
    local i=0
    while kill -0 "$pid" 2>/dev/null; do
        echo -ne "\r  ${BCYN}${frames[$i]}${RST}  ${msg}…"
        i=$(( (i + 1) % ${#frames[@]} ))
        sleep 0.1
    done
    echo -ne "\r"
}

die() {
    echo
    echo -e "${BRED}╔══════════════════════════════════════════════╗${RST}"
    echo -e "${BRED}║  INSTALLATION FAILED                         ║${RST}"
    echo -e "${BRED}╚══════════════════════════════════════════════╝${RST}"
    echo -e "  ${DIM}See log: ${LOG_FILE}${RST}"
    echo -e "  ${BRED}Error: $1${RST}"
    exit 1
}

# ── Welcome banner ────────────────────────────────────────────────────────────
clear
echo
echo -e "${BPRP}    ╔══════════════════════════════════════════════════════════════════╗${RST}"
echo -e "${BPRP}    ║${RST}                                                                  ${BPRP}║${RST}"
echo -e "${BPRP}    ║${RST}   ${BWHT} ██╗███╗   ███╗██████╗ ███████╗██████╗ ██╗ █████╗     ${RST}         ${BPRP}║${RST}"
echo -e "${BPRP}    ║${RST}   ${BWHT} ██║████╗ ████║██╔══██╗██╔════╝██╔══██╗██║██╔══██╗     ${RST}        ${BPRP}║${RST}"
echo -e "${BPRP}    ║${RST}   ${BCYN} ██║██╔████╔██║██████╔╝█████╗  ██████╔╝██║███████║     ${RST}        ${BPRP}║${RST}"
echo -e "${BPRP}    ║${RST}   ${BCYN} ██║██║╚██╔╝██║██╔═══╝ ██╔══╝  ██╔══██╗██║██╔══██║     ${RST}        ${BPRP}║${RST}"
echo -e "${BPRP}    ║${RST}   ${BWHT} ██║██║ ╚═╝ ██║██║     ███████╗██║  ██║██║██║  ██║     ${RST}        ${BPRP}║${RST}"
echo -e "${BPRP}    ║${RST}   ${BWHT} ╚═╝╚═╝     ╚═╝╚═╝     ╚══════╝╚═╝  ╚═╝╚═╝╚═╝  ╚═╝     ${RST}        ${BPRP}║${RST}"
echo -e "${BPRP}    ╚══════════════════════════════════════════════════════════════════╝${RST}"
echo
echo -e "  ${DIM}Install path:  ${BWHT}${CONFIG_DIR}/imperia${RST}"
echo -e "  ${DIM}Log file:      ${BWHT}${LOG_FILE}${RST}"
echo

# ── Confirm ───────────────────────────────────────────────────────────────────
echo -e "  ${BYLW}Press ${BWHT}Enter${BYLW} to begin installation, or ${BRED}Ctrl+C${BYLW} to cancel.${RST}"
read -r

# ── Step 1: Detect package manager ───────────────────────────────────────────
section "Detecting package manager"
PM=""
if   command -v pacman &>/dev/null; then PM="sudo pacman"; ok "Found pacman"
elif command -v yay   &>/dev/null; then PM="yay";   ok "Found yay (AUR helper)"
else warn "No supported package manager found — skipping system packages"; fi

# ── Step 2: Install system packages ──────────────────────────────────────────
section "Installing system packages"
if [ -n "$PM" ]; then
    PACKAGES=(
        quickshell-git
        ttf-fira-sans
        ttf-jetbrains-mono-nerd
        ttf-font-awesome
        ttf-material-symbols-variable-git
        noto-fonts-emoji
        swww hyprpaper
        networkmanager
        pipewire wireplumber
        hyprpicker
        wl-clipboard
        grim slurp
        jq
        python-psutil
        hyprshot
        playerctl
        brightnessctl
        imagemagick
        qt6ct
        tela-circle-icon-theme
        kvantum
    )

    info "Installing ${#PACKAGES[@]} packages…"
    (
        $PM -S --needed --noconfirm "${PACKAGES[@]}" >> "$LOG_FILE" 2>&1
    ) &
    spinner $! "Installing packages"
    wait $!
    ok "Packages installed"

    info "Installing Python dependencies…"
    pip install colorthief --break-system-packages >> "$LOG_FILE" 2>&1 || warn "colorthief unavailable (optional)"
    ok "Python dependencies ready"
else
    warn "Skipped — install dependencies manually:"
    sub "quickshell-git, ttf-fira-sans, ttf-jetbrains-mono-nerd"
    sub "ttf-font-awesome, ttf-material-symbols-variable-git"
    sub "swww, networkmanager, pipewire, wireplumber, playerctl"
fi

# ── Step 3: Configure icon & cursor themes ────────────────────────────────────
section "Configuring icon & GTK themes"

info "Setting Tela Circle (colorful) icon theme…"
# Remove monochrome nord variant if previously installed
command -v paru &>/dev/null && paru -R --noconfirm tela-circle-icon-theme-nord 2>/dev/null || true
command -v gsettings &>/dev/null && \
    gsettings set org.gnome.desktop.interface icon-theme 'tela-circle' 2>/dev/null && ok "GTK icon theme set" || warn "gsettings not available"

mkdir -p "$HOME/.config/gtk-3.0" "$HOME/.config/gtk-4.0"

cat > "$HOME/.config/gtk-3.0/settings.ini" << GTK
[Settings]
gtk-theme-name=adw-gtk3-dark
gtk-icon-theme-name=Tela-circle
gtk-font-name=Fira Sans 10
gtk-cursor-theme-name=Bibata-Modern-Classic
gtk-cursor-theme-size=22
gtk-toolbar-style=GTK_TOOLBAR_ICONS
gtk-button-images=0
gtk-menu-images=0
gtk-enable-event-sounds=1
gtk-enable-input-feedback-sounds=1
gtk-xft-antialias=1
gtk-xft-hinting=1
gtk-xft-hintstyle=hintfull
gtk-xft-rgba=rgb
gtk-application-prefer-dark-theme=1
GTK
ok "GTK3 config written"

mkdir -p "$HOME/.config/qt6ct"
cat > "$HOME/.config/qt6ct/qt6ct.conf" << QT6
[Appearance]
icon_theme=Tela-circle
style=kvantum-dark
standard_dialogs=gtk3
[Fonts]
fixed="Fira Sans,9,-1,5,400,0,0,0,0,0,0,0,0,0,0,1"
general="Fira Sans,9,-1,5,400,0,0,0,0,0,0,0,0,0,0,1"
[Interface]
activate_item_on_single_click=1
menus_have_icons=true
show_shortcuts_in_context_menus=true
QT6
ok "Qt6 config written"

# ── Step 4: Install Hyprland config files ────────────────────────────────────
section "Installing Hyprland configs"
mkdir -p "$HYPR_CFG"
for f in animation layerrule monitor-input user-preference windowrule keybindings; do
    SRC="$SHELL_DIR/config/hyprland/${f}.conf"
    if [ -f "$SRC" ]; then
        cp "$SRC" "$HYPR_CFG/"
        ok "${f}.conf"
    else
        warn "${f}.conf not found — skipped"
    fi
done

# ── Step 5: Install PAM config ───────────────────────────────────────────────
section "Installing PAM authentication"
PAM_SRC="$SHELL_DIR/config/pam/password.conf"
if [ -f "$PAM_SRC" ]; then
    sudo cp "$PAM_SRC" /etc/pam.d/imperia-lock 2>/dev/null && ok "PAM config installed" || warn "Could not write PAM config (needs sudo)"
else
    warn "PAM config not found — lockscreen auth may not work"
fi

# ── Step 6: Copy shell files ──────────────────────────────────────────────────
section "Installing shell files"
INSTALL_PATH="$CONFIG_DIR/imperia"
mkdir -p "$CONFIG_DIR"

if [ "$INSTALL_PATH" = "$SHELL_DIR" ]; then
    info "Already in install location — no copy needed"
else
    info "Copying to ${INSTALL_PATH}…"
    rm -rf "$INSTALL_PATH"
    (
        cp -r "$SHELL_DIR" "$INSTALL_PATH" >> "$LOG_FILE" 2>&1
    ) &
    spinner $! "Copying files"
    wait $!
    ok "Shell installed to ${INSTALL_PATH}"
fi

# Set permissions
chmod +x "$INSTALL_PATH/install.sh" "$INSTALL_PATH/cli.sh" 2>/dev/null || true
find "$INSTALL_PATH/scripts" -name "*.sh" -o -name "*.py" | xargs chmod +x 2>/dev/null || true
ok "Permissions set"

# ── Step 7: Post-install ──────────────────────────────────────────────────────
section "Finalizing installation"

info "Rebuilding font cache…"
fc-cache -f >> "$LOG_FILE" 2>&1 &
spinner $! "Rebuilding font cache"
wait $!
ok "Font cache updated"

info "Matugen color config…"
MATUGEN_CFG="$HOME/.config/matugen/config.toml"
if [ ! -f "$MATUGEN_CFG" ] && [ -f "$SHELL_DIR/assets/matugen/config.toml" ]; then
    mkdir -p "$HOME/.config/matugen"
    cp "$SHELL_DIR/assets/matugen/config.toml" "$MATUGEN_CFG"
    ok "Matugen config installed"
fi

# ── Done! ─────────────────────────────────────────────────────────────────────
echo
echo -e "${BGRN}╔══════════════════════════════════════════════════════════════════════╗${RST}"
echo -e "${BGRN}║${RST}                                                                    ${BGRN}║${RST}"
echo -e "${BGRN}║${RST}   ${BWHT} ✨  Imperia Shell ★ Enhanced Edition — Installed!${RST}          ${BGRN}║${RST}"
echo -e "${BGRN}║${RST}                                                                    ${BGRN}║${RST}"
echo -e "${BGRN}╠══════════════════════════════════════════════════════════════════════╣${RST}"
echo -e "${BGRN}║${RST}                                                                    ${BGRN}║${RST}"
echo -e "${BGRN}║${RST}   ${BCYN}To launch:${RST}                                                      ${BGRN}║${RST}"
echo -e "${BGRN}║${RST}   ${DIM}  Add to your Hyprland config:${RST}                               ${BGRN}║${RST}"
echo -e "${BGRN}║${RST}   ${BWHT}  exec-once = quickshell -c imperia${RST}                          ${BGRN}║${RST}"
echo -e "${BGRN}║${RST}                                                                    ${BGRN}║${RST}"
echo -e "${BGRN}║${RST}   ${BCYN}New features in Enhanced Edition:${RST}                              ${BGRN}║${RST}"
echo -e "${BGRN}║${RST}   ${BWHT}  ★${RST} ${DIM}DankMaterial-style Settings (sidebar navigation)${RST}       ${BGRN}║${RST}"
echo -e "${BGRN}║${RST}   ${BWHT}  ★${RST} ${DIM}Control Center (toggles + sliders + media + notifs)${RST}    ${BGRN}║${RST}"
echo -e "${BGRN}║${RST}   ${BWHT}  ★${RST} ${DIM}Roman numeral workspaces (I, II, III, IV, V…)${RST}          ${BGRN}║${RST}"
echo -e "${BGRN}║${RST}   ${BWHT}  ★${RST} ${DIM}Active window title in bar${RST}                             ${BGRN}║${RST}"
echo -e "${BGRN}║${RST}   ${BWHT}  ★${RST} ${DIM}Notification badge button in bar${RST}                       ${BGRN}║${RST}"
echo -e "${BGRN}║${RST}   ${BWHT}  ★${RST} ${DIM}Spring-physics animations (OutBack easing)${RST}             ${BGRN}║${RST}"
echo -e "${BGRN}║${RST}   ${BWHT}  ★${RST} ${DIM}Enhanced Hyprland animations (velvet, spring, silk)${RST}    ${BGRN}║${RST}"
echo -e "${BGRN}║${RST}                                                                    ${BGRN}║${RST}"
echo -e "${BGRN}╚══════════════════════════════════════════════════════════════════════╝${RST}"
echo
echo
