// ─────────────────────────────────────────────────────────────────────────────
// IconUtils.js — Imperia Shell (Enhanced v2)
// Smart icon resolver with deep fallback chain + 150+ app overrides.
// ─────────────────────────────────────────────────────────────────────────────
.pragma library

// ── Theme-aware name map ──────────────────────────────────────────────────────
// Maps desktop Icon= values → the best icon name for common icon themes
// (Papirus, Tela, Fluent, Qogir, etc.).
var ICON_OVERRIDES = {
    // ── Terminals ──────────────────────────────────────────────────────────────
    "kitty":                    "kitty",
    "alacritty":                "Alacritty",
    "foot":                     "foot",
    "wezterm":                  "wezterm",
    "wezterm-gui":              "wezterm",
    "org.wezfurlong.wezterm":   "wezterm",
    "gnome-terminal":           "org.gnome.Terminal",
    "org.gnome.terminal":       "org.gnome.Terminal",
    "konsole":                  "org.kde.konsole",
    "org.kde.konsole":          "org.kde.konsole",
    "tilix":                    "com.gexperts.Tilix",
    "com.gexperts.tilix":       "com.gexperts.Tilix",
    "xterm":                    "xterm",
    "urxvt":                    "urxvt",
    "hyper":                    "hyper",
    "tabby":                    "tabby",
    "blackbox":                 "com.raggesilver.BlackBox",

    // ── Browsers ───────────────────────────────────────────────────────────────
    "firefox":                  "firefox",
    "firefox-esr":              "firefox-esr",
    "chromium":                 "chromium",
    "chromium-browser":         "chromium",
    "google-chrome":            "google-chrome",
    "google-chrome-stable":     "google-chrome",
    "google-chrome-beta":       "google-chrome-beta",
    "google-chrome-unstable":   "google-chrome-unstable",
    "brave-browser":            "brave-browser",
    "com.brave.browser":        "brave-browser",
    "microsoft-edge":           "microsoft-edge",
    "microsoft-edge-stable":    "microsoft-edge",
    "com.microsoft.edge":       "microsoft-edge",
    "opera":                    "opera",
    "opera-beta":               "opera-beta",
    "vivaldi":                  "vivaldi",
    "vivaldi-stable":           "vivaldi",
    "thorium-browser":          "thorium-browser",
    "floorp":                   "floorp",
    "librewolf":                "librewolf",
    "tor-browser":              "tor-browser",
    "epiphany":                 "org.gnome.Epiphany",
    "org.gnome.epiphany":       "org.gnome.Epiphany",
    "falkon":                   "org.kde.falkon",

    // ── Code / IDEs ────────────────────────────────────────────────────────────
    "code":                     "visual-studio-code",
    "vscode":                   "visual-studio-code",
    "code-oss":                 "code-oss",
    "com.visualstudio.code":    "visual-studio-code",
    "codium":                   "vscodium",
    "vscodium":                 "vscodium",
    "com.vscodium.codium":      "vscodium",
    "cursor":                   "cursor",
    "nvim":                     "nvim",
    "neovim":                   "nvim",
    "neovide":                  "neovide",
    "vim":                      "vim",
    "gvim":                     "gvim",
    "emacs":                    "emacs",
    "emacs28":                  "emacs",
    "idea":                     "intellij-idea-ce",
    "intellij-idea-ce":         "intellij-idea-ce",
    "intellij-idea-ue":         "intellij-idea",
    "com.jetbrains.intellij":   "intellij-idea",
    "com.jetbrains.intellij-ce":"intellij-idea-ce",
    "pycharm":                  "pycharm",
    "pycharm-ce":               "pycharm-ce",
    "com.jetbrains.pycharm":    "pycharm",
    "webstorm":                 "webstorm",
    "com.jetbrains.webstorm":   "webstorm",
    "clion":                    "clion",
    "com.jetbrains.clion":      "clion",
    "datagrip":                 "datagrip",
    "com.jetbrains.datagrip":   "datagrip",
    "rider":                    "rider",
    "com.jetbrains.rider":      "rider",
    "goland":                   "goland",
    "android-studio":           "androidstudio",
    "com.google.androidstudio": "androidstudio",
    "sublime-text":             "sublime-text",
    "subl":                     "sublime-text",
    "sublime_text":             "sublime-text",
    "kate":                     "org.kde.kate",
    "org.kde.kate":             "org.kde.kate",
    "gedit":                    "org.gnome.gedit",
    "mousepad":                 "org.xfce.mousepad",
    "geany":                    "geany",
    "lapce":                    "dev.lapce.lapce",
    "zed":                      "zed",
    "dev.zed.zed":              "zed",
    "helix":                    "helix",

    // ── File managers ──────────────────────────────────────────────────────────
    "dolphin":                  "system-file-manager",
    "org.kde.dolphin":          "system-file-manager",
    "nautilus":                 "org.gnome.Nautilus",
    "org.gnome.nautilus":       "org.gnome.Nautilus",
    "nemo":                     "nemo",
    "org.gnome.nemo":           "nemo",
    "thunar":                   "org.xfce.thunar",
    "org.xfce.thunar":          "org.xfce.thunar",
    "pcmanfm":                  "system-file-manager",
    "pcmanfm-qt":               "system-file-manager",
    "ranger":                   "ranger",
    "yazi":                     "yazi",
    "spacedrive":               "spacedrive",

    // ── Messaging / Social ─────────────────────────────────────────────────────
    "discord":                  "discord",
    "com.discordapp.discord":   "discord",
    "discord-canary":           "discord-canary",
    "vesktop":                  "vesktop",
    "legcord":                  "legcord",
    "telegram-desktop":         "telegram",
    "org.telegram.desktop":     "telegram",
    "telegram":                 "telegram",
    "slack":                    "slack",
    "com.slack.slack":          "slack",
    "teams":                    "teams",
    "teams-for-linux":          "teams-for-linux",
    "signal-desktop":           "signal-desktop",
    "org.signal.signal":        "signal-desktop",
    "thunderbird":              "thunderbird",
    "org.mozilla.thunderbird":  "thunderbird",
    "evolution":                "org.gnome.Evolution",
    "whatsapp-desktop":         "whatsapp",
    "element-desktop":          "element",
    "nheko":                    "io.github.nheko",
    "fractal":                  "org.gnome.Fractal",
    "hexchat":                  "hexchat",
    "irssi":                    "irssi",
    "weechat":                  "weechat",
    "mattermost":               "mattermost",

    // ── Media / Audio / Video ──────────────────────────────────────────────────
    "vlc":                      "vlc",
    "mpv":                      "mpv",
    "io.mpv.mpv":               "mpv",
    "celluloid":                "io.github.celluloid_player.Celluloid",
    "clapper":                  "com.github.rafostar.Clapper",
    "haruna":                   "org.kde.haruna",
    "rhythmbox":                "org.gnome.Rhythmbox3",
    "lollypop":                 "org.gnome.Lollypop",
    "spotify":                  "spotify",
    "com.spotify.client":       "spotify",
    "strawberry":               "org.strawberrymusicplayer.strawberry",
    "elisa":                    "org.kde.elisa",
    "deadbeef":                 "deadbeef",
    "audacity":                 "audacity",
    "org.audacityteam.audacity":"audacity",
    "easyeffects":              "com.github.wwmm.easyeffects",
    "com.github.wwmm.easyeffects": "com.github.wwmm.easyeffects",
    "helvum":                   "org.pipewire.Helvum",
    "pavucontrol":              "pavucontrol",
    "pavucontrol-qt":           "pavucontrol",
    "obs":                      "com.obsproject.Studio",
    "com.obsproject.studio":    "com.obsproject.Studio",
    "kdenlive":                 "kdenlive",
    "org.kde.kdenlive":         "kdenlive",
    "shotcut":                  "org.shotcut.Shotcut",
    "davinci-resolve":          "davinci-resolve",
    "gimp":                     "gimp",
    "org.gimp.gimp":            "gimp",
    "inkscape":                 "inkscape",
    "org.inkscape.inkscape":    "inkscape",
    "krita":                    "krita",
    "org.kde.krita":            "krita",
    "darktable":                "darktable",
    "org.darktable.darktable":  "darktable",
    "rawtherapee":              "rawtherapee",
    "digikam":                  "org.kde.digikam",
    "eog":                      "org.gnome.eog",
    "gwenview":                 "org.kde.gwenview",
    "shotwell":                 "org.gnome.Shotwell",

    // ── Gaming ─────────────────────────────────────────────────────────────────
    "steam":                    "steam",
    "com.valvesoftware.steam":  "steam",
    "lutris":                   "lutris",
    "net.lutris.lutris":        "lutris",
    "heroic":                   "com.heroicgameslauncher.hgl",
    "com.heroicgameslauncher.hgl": "com.heroicgameslauncher.hgl",
    "bottles":                  "com.usebottles.bottles",
    "com.usebottles.bottles":   "com.usebottles.bottles",
    "wine":                     "wine",
    "mangohud":                 "mangohud",
    "gamemode":                 "gamemode",
    "retroarch":                "retroarch",
    "org.libretro.retroarch":   "retroarch",
    "dosbox":                   "dosbox",
    "dosbox-staging":           "dosbox",
    "0ad":                      "0ad",
    "supertuxkart":             "supertuxkart",
    "ppsspp":                   "ppsspp",
    "rpcs3":                    "rpcs3",
    "cemu":                     "cemu",
    "yuzu":                     "yuzu",
    "ryujinx":                  "ryujinx",

    // ── Office / Productivity ──────────────────────────────────────────────────
    "libreoffice":              "libreoffice-startcenter",
    "libreoffice-startcenter":  "libreoffice-startcenter",
    "libreoffice-writer":       "libreoffice-writer",
    "libreoffice-calc":         "libreoffice-calc",
    "libreoffice-impress":      "libreoffice-impress",
    "libreoffice-draw":         "libreoffice-draw",
    "libreoffice-base":         "libreoffice-base",
    "libreoffice-math":         "libreoffice-math",
    "onlyoffice-desktopeditors":"onlyoffice-desktopeditors",
    "onlyoffice":               "onlyoffice-desktopeditors",
    "wps-office":               "wps-office",
    "wps-office-wps":           "wps-office-wps",
    "wps-office-et":            "wps-office-et",
    "wps-office-wpp":           "wps-office-wpp",
    "obsidian":                 "obsidian",
    "md.obsidian.obsidian":     "obsidian",
    "logseq":                   "logseq",
    "notion-app":               "notion-app",
    "notion-app-enhanced":      "notion-app",
    "anytype":                  "io.anytype.anytype",
    "joplin":                   "joplin",
    "net.cozic.joplin_desktop": "joplin",
    "xournalpp":                "com.github.xournalpp.xournalpp",
    "okular":                   "org.kde.okular",
    "evince":                   "org.gnome.Evince",
    "calibre":                  "calibre-gui",
    "foliate":                  "com.github.johnfactotum.Foliate",
    "zathura":                  "zathura",
    "sioyek":                   "sioyek",
    "masterpdfeditor5":         "masterpdfeditor5",

    // ── System / Utilities ─────────────────────────────────────────────────────
    "gnome-settings":           "org.gnome.Settings",
    "org.gnome.settings":       "org.gnome.Settings",
    "systemsettings":           "org.kde.systemsettings",
    "org.kde.systemsettings":   "org.kde.systemsettings",
    "gnome-control-center":     "org.gnome.Settings",
    "gnome-tweaks":             "org.gnome.tweaks",
    "gnome-disk-utility":       "org.gnome.DiskUtility",
    "gparted":                  "gparted",
    "kde-partition-manager":    "org.kde.partitionmanager",
    "bleachbit":                "bleachbit",
    "stacer":                   "io.github.oguzhaninan.stacer",
    "mission-center":           "io.missioncenter.MissionCenter",
    "resources":                "net.nokyan.Resources",
    "htop":                     "htop",
    "btop":                     "btop",
    "baobab":                   "org.gnome.baobab",
    "filelight":                "org.kde.filelight",
    "gnome-system-monitor":     "org.gnome.SystemMonitor",
    "ksysguard":                "org.kde.ksysguard",
    "ark":                      "org.kde.ark",
    "file-roller":              "org.gnome.FileRoller",
    "timeshift":                "timeshift",
    "back-in-time":             "backintime-qt",
    "blueman-manager":          "blueman",
    "blueberry":                "blueberry",
    "bluetooth-adapters":       "bluetooth",
    "blueman-adapters":         "bluetooth",
    "nm-connection-editor":     "network-manager",
    "gnome-network-displays":   "org.gnome.NetworkDisplays",
    "warpinator":               "org.x.warpinator",
    "localsend":                "org.localsend.localsend_app",

    // ── Development Tools ──────────────────────────────────────────────────────
    "azuredatastudio":          "azuredatastudio",
    "com.azuredatastudio.azuredatastudio": "azuredatastudio",
    "dbeaver":                  "dbeaver",
    "io.dbeaver.dbeaver":       "dbeaver",
    "beekeeper-studio":         "beekeeper-studio",
    "tableplus":                "tableplus",
    "insomnia":                 "insomnia",
    "rest.insomnia.insomnia":   "insomnia",
    "postman":                  "postman",
    "bruno":                    "io.usebruno.Bruno",
    "hoppscotch":               "hoppscotch",
    "wireshark":                "wireshark",
    "meld":                     "org.gnome.meld",
    "diffuse":                  "io.github.mightycreak.Diffuse",
    "gitg":                     "org.gnome.gitg",
    "gitkraken":                "gitkraken",
    "sourcetree":               "sourcetree",
    "docker-desktop":           "docker",
    "podman-desktop":           "io.podman_desktop.PodmanDesktop",
    "virt-manager":             "virt-manager",
    "gnome-boxes":              "org.gnome.Boxes",
    "virtualbox":               "virtualbox",

    // ── Python tools ───────────────────────────────────────────────────────────
    "idle":                     "idle",
    "idle3":                    "idle3",
    "jupyter-lab":              "jupyter",
    "jupyter-notebook":         "jupyter",

    // ── Notes / Writing ────────────────────────────────────────────────────────
    "ghostwriter":              "io.github.wereturtle.ghostwriter",
    "typora":                   "typora",
    "apostrophe":               "org.gnome.gitlab.somas.Apostrophe",
    "marktext":                 "marktext",
    "planify":                  "io.github.alainm23.planify",
    "gnome-todo":               "org.gnome.Todo",
    "endeavour":                "org.gnome.Todo",

    // ── Design / 3D ────────────────────────────────────────────────────────────
    "blender":                  "blender",
    "org.blender.blender":      "blender",
    "godot":                    "godot",
    "godot4":                   "godot4",
    "org.godotengine.godot":    "godot",
    "figma-linux":              "figma-linux",
    "penpot":                   "penpot",
    "freecad":                  "org.freecad.FreeCAD",

    // ── Downloads / Torrents ───────────────────────────────────────────────────
    "qbittorrent":              "qbittorrent",
    "org.qbittorrent.qbittorrent": "qbittorrent",
    "transmission":             "transmission",
    "org.transmissionbt.transmission": "transmission",
    "deluge":                   "deluge",
    "uget":                     "uget",
    "motrix":                   "motrix",

    // ── VPN / Privacy ──────────────────────────────────────────────────────────
    "protonvpn":                "protonvpn",
    "mullvad-vpn":              "mullvad-vpn",
    "nm-l2tp":                  "network-vpn",
    "org.mozilla.firefox.vpn":  "protonvpn",

    // ── Misc popular apps ─────────────────────────────────────────────────────
    "zoom":                     "zoom",
    "us.zoom.zoom":             "zoom",
    "skype":                    "skype",
    "com.skype.skype":          "skype",
    "com.dropbox.client":       "dropbox",
    "dropbox":                  "dropbox",
    "nextcloud":                "nextcloud",
    "com.nextcloud.desktopclient": "nextcloud",
    "bitwarden":                "bitwarden",
    "com.bitwarden.desktop":    "bitwarden",
    "1password":                "1password",
    "com.1password.onepassword":"1password",
    "keepassxc":                "keepassxc",
    "org.keepassxc.KeePassXC":  "keepassxc",
    "cryptomator":              "org.cryptomator.Cryptomator",
    "gnucash":                  "gnucash",
    "homebank":                 "homebank",
    "anki":                     "anki",
    "net.ankiweb.anki":         "anki",
    "xmind":                    "xmind",
    "minder":                   "com.github.phase1geo.minder",
    "freemind":                 "freemind",
    "scrcpy":                   "scrcpy",
    "gnome-font-viewer":        "org.gnome.font-viewer",
    "font-manager":             "org.gnome.FontManager",
    "flatseal":                 "com.github.tchx84.Flatseal",
    "warehouse":                "io.github.flattool.Warehouse",
};

/**
 * Returns [primarySource, secondarySource, fallbackSource] for an app icon.
 * Enhanced 3-level fallback chain.
 *
 * @param {string} iconName  The Icon= field from the .desktop file
 * @returns {string[]}       [primary, secondary, fallback] sources
 */
function iconSources(iconName) {
    var fallback = "image://icon/application-x-executable";

    if (!iconName || iconName === "")
        return [fallback, fallback, fallback];

    // 1. Absolute path (/usr/share/pixmaps/app.png, etc.)
    if (iconName.charAt(0) === "/") {
        return ["file://" + iconName, fallback, fallback];
    }

    // 2. Strip image extensions first so lookups work correctly
    var stripped = iconName.replace(/\.(png|svg|xpm|jpg|jpeg|ico|bmp)$/i, "");

    // 3. Check known overrides (exact, lowercase, stripped)
    var lowerName = stripped.toLowerCase();
    var overrideName = ICON_OVERRIDES[stripped]
                    || ICON_OVERRIDES[iconName]
                    || ICON_OVERRIDES[lowerName];
    if (overrideName) {
        return [
            "image://icon/" + overrideName,
            "image://icon/" + lowerName,
            fallback
        ];
    }

    // 4. Strip vendor reverse-domain prefixes for better theme matching
    //    e.g. org.kde.dolphin → dolphin, com.example.App → app
    var shortName = stripped
        .replace(/^(org|com|io|net|app|dev)\.[a-z0-9_-]+\./i, "")
        .replace(/^(org|com|io|net|app|dev)\.[a-z0-9_-]+\.[a-z0-9_-]+\./i, "");

    var shortLower = shortName.toLowerCase();

    // Check overrides with short name too
    var shortOverride = ICON_OVERRIDES[shortName] || ICON_OVERRIDES[shortLower];
    if (shortOverride) {
        return [
            "image://icon/" + shortOverride,
            "image://icon/" + lowerName,
            fallback
        ];
    }

    // 5. Build best-effort fallback chain:
    //    exact stripped → short name → lowercase → fallback
    if (shortLower !== lowerName) {
        return [
            "image://icon/" + lowerName,
            "image://icon/" + shortLower,
            fallback
        ];
    }

    return ["image://icon/" + stripped, fallback, fallback];
}

/**
 * Single source resolution for simple bindings.
 */
function resolveIcon(iconName) {
    return iconSources(iconName)[0];
}

/**
 * Extended resolution with more fallback variants.
 * Tries: exact, lowercase, without dots, camelCase split, etc.
 * Returns the best image://icon/ URL for any app window class.
 */
function resolveIconExtended(windowClass) {
    if (!windowClass) return "image://icon/application-x-executable";

    // Normalize
    var cls = windowClass.trim();

    // 1. Try our smart chain first
    var primary = resolveIcon(cls);
    if (primary && !primary.includes("application-x-executable")) return primary;

    // 2. Lowercase
    var lower = cls.toLowerCase();
    if (lower !== cls) {
        var lowerResult = resolveIcon(lower);
        if (lowerResult && !lowerResult.includes("application-x-executable")) return lowerResult;
    }

    // 3. Strip common suffixes (.desktop, -bin, d (daemon))
    var stripped = lower.replace(/[-_](bin|app|gtk|qt|qt5|qt6|wayland|x11|wrapper|stable|nightly|beta|dev)$/, "");
    if (stripped !== lower) {
        var strippedResult = resolveIcon(stripped);
        if (strippedResult && !strippedResult.includes("application-x-executable")) return strippedResult;
    }

    // 4. Split on dots (com.valvesoftware.Steam → Steam)
    var parts = lower.split(".");
    if (parts.length > 1) {
        var last = parts[parts.length - 1];
        var lastResult = resolveIcon(last);
        if (lastResult && !lastResult.includes("application-x-executable")) return lastResult;
    }

    // 5. Try image://icon/ directly with lowercase (GTK icon theme)
    return "image://icon/" + lower;
}
