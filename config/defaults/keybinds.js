// ─────────────────────────────────────────────────────────────────────────────
// keybinds.js — Imperia Shell default keybindings
// Synced from user's keybindings.conf (Hyprland)
// ─────────────────────────────────────────────────────────────────────────────
.pragma library

var data = {
    // ── Modifier ──────────────────────────────────────────────────────────────
    "mod": "SUPER",

    // ── Applications ─────────────────────────────────────────────────────────
    "terminal":          "$mod, T",          // kitty
    "fileManager":       "$mod, E",          // dolphin
    "editor":            "$mod, V",          // code
    "browser":           "$mod, C",          // google-chrome-stable
    "wallpaperRofi":     "$mod, Y",          // rofi wallpaper changer

    // ── Window Management ─────────────────────────────────────────────────────
    "closeWindow":       "$mod, Q",
    "toggleFloat":       "$mod, W",
    "toggleGroup":       "$mod, G",
    "toggleSplit":       "$mod, S",
    "fullscreen":        "$mod, F",
    "fullscreenMax":     "$mod SHIFT, F",
    "pin":               "$mod, P",

    // ── Focus ─────────────────────────────────────────────────────────────────
    "focusLeft":         "$mod, left",
    "focusRight":        "$mod, right",
    "focusUp":           "$mod, up",
    "focusDown":         "$mod, down",
    "focusCycle":        "ALT, Tab",
    "focusCyclePrev":    "ALT SHIFT, Tab",

    // ── Resize ────────────────────────────────────────────────────────────────
    "resizeRight":       "$mod CTRL SHIFT, right",
    "resizeLeft":        "$mod CTRL SHIFT, left",
    "resizeUp":          "$mod CTRL SHIFT, up",
    "resizeDown":        "$mod CTRL SHIFT, down",

    // ── Workspaces (1-5 user, 6-10 Imperia) ──────────────────────────────────
    "ws1":               "$mod, 1",
    "ws2":               "$mod, 2",
    "ws3":               "$mod, 3",
    "ws4":               "$mod, 4",
    "ws5":               "$mod, 5",
    "ws6":               "$mod, 6",
    "ws7":               "$mod, 7",
    "ws8":               "$mod, 8",
    "ws9":               "$mod, 9",
    "ws10":              "$mod, 0",
    "wsNext":            "$mod CTRL, right",
    "wsPrev":            "$mod CTRL, left",
    "moveToWs1":         "$mod SHIFT, 1",
    "moveToWs2":         "$mod SHIFT, 2",
    "moveToWs3":         "$mod SHIFT, 3",
    "moveToWs4":         "$mod SHIFT, 4",
    "moveToWs5":         "$mod SHIFT, 5",
    "moveToWs6":         "$mod SHIFT, 6",
    "moveToWs7":         "$mod SHIFT, 7",
    "moveToWs8":         "$mod SHIFT, 8",
    "moveToWs9":         "$mod SHIFT, 9",
    "moveToWs10":        "$mod SHIFT, 0",
    "specialWorkspace":  "$mod, grave",
    "moveToSpecial":     "$mod SHIFT, grave",

    // ── Shell UI Toggles ──────────────────────────────────────────────────────
    "toggleLauncher":    "$mod, Space",        // App search
    "toggleOverview":    "$mod, Tab",          // Workspace overview
    "toggleDashboard":   "$mod, D",            // Dashboard (unused in keybinds.conf but sensible default)
    "toggleSettings":    "$mod CTRL, S",       // Settings (avoid conflict with $mod,S = split)
    "togglePowermenu":   "CTRL ALT, Delete",   // Session menu
    "toggleSidebarLeft": "$mod, A",            // AI sidebar (Claude)
    "toggleSidebarRight":"$mod, N",            // Notifications
    "toggleClipboard":   "$mod, X",            // Clipboard history
    "toggleEmoji":       "$mod, Period",       // Emoji picker
    "toggleCheatsheet":  "$mod, Slash",        // Cheatsheet
    "toggleMedia":       "$mod, M",            // Media controls
    "toggleNotepad":     "$mod SHIFT, N",      // Imperia Notepad
    "toggleBar":         "$mod, J",            // Toggle bar
    "toggleWallpaper":   "$mod CTRL, T",       // Wallpaper selector
    "wallpaperRandom":   "$mod CTRL ALT, T",   // Random wallpaper

    // ── Screenshots ───────────────────────────────────────────────────────────
    "screenshotOutput":  ", Print",            // Full screen
    "screenshotWindow":  "CTRL, Print",        // Active window
    "screenshotRegion":  "SHIFT, Print",       // Region (hyprshot)
    "screenshotImperia": "$mod SHIFT, S",      // Imperia region screenshot
    "regionSearch":      "$mod SHIFT, A",      // Lens / region search
    "regionOCR":         "$mod SHIFT, X",      // OCR region

    // ── Audio (user F-keys) ───────────────────────────────────────────────────
    "volumeDownKey":     "$mod, F2",
    "volumeUpKey":       "$mod, F3",
    "volumeMuteKey":     "$mod, F4",
    "brightnessDownKey": "$mod, F5",
    "brightnessUpKey":   "$mod, F6",

    // ── Audio (system XF86 keys) ──────────────────────────────────────────────
    "volumeUp":          ", XF86AudioRaiseVolume",
    "volumeDown":        ", XF86AudioLowerVolume",
    "volumeMute":        ", XF86AudioMute",
    "micMute":           ", XF86AudioMicMute",
    "mediaPlay":         ", XF86AudioPlay",
    "mediaPause":        ", XF86AudioPause",
    "mediaPrev":         ", XF86AudioPrev",
    "mediaNext":         ", XF86AudioNext",

    // ── Brightness (system keys) ──────────────────────────────────────────────
    "brightnessUp":      ", XF86MonBrightnessUp",
    "brightnessDown":    ", XF86MonBrightnessDown",

    // ── Mouse ─────────────────────────────────────────────────────────────────
    "mouseMoveWindow":   "$mod, mouse:272",
    "mouseResizeWindow": "$mod, mouse:273",
    "wsScrollUp":        "$mod, mouse_down",
    "wsScrollDown":      "$mod, mouse_up"
}
