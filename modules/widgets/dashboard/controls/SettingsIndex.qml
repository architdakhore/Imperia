// Settings search index — updated to match new section numbering
// Removed: EasyEffects (3), Weather (11), Quick Tiles (12), Material You (13), FusionKeybinds (10)

import QtQuick
import qs.modules.theme

QtObject {
    // Main Sections (new numbering):
    // 0:Network, 1:Bluetooth, 2:Mixer, 3:Theme, 4:Binds, 5:System, 6:Compositor, 7:Imperia, 8:Performance, 9:Processes

    property var dynamicItems: []

    readonly property var staticItems: [
        // --- Network ---
        { label: "Network", keywords: "internet wifi connection ethernet ip", section: 0, subSection: "", subLabel: "", icon: Icons.wifiHigh, isIcon: true },

        // --- Bluetooth ---
        { label: "Bluetooth", keywords: "devices pairing connect", section: 1, subSection: "", subLabel: "", icon: Icons.bluetooth, isIcon: true },

        // --- Mixer ---
        { label: "Audio Mixer", keywords: "sound volume output input mic speaker", section: 2, subSection: "", subLabel: "", icon: Icons.faders, isIcon: true },

        // --- Theme ---
        { label: "Theme", keywords: "appearance look style customize", section: 3, subSection: "", subLabel: "Theme", icon: Icons.paintBrush, isIcon: true },
        { label: "Wallpapers", keywords: "background image picture desktop", section: 3, subSection: "general", subLabel: "Theme > General", icon: Icons.image, isIcon: true },
        { label: "Tint Icons", keywords: "color icons tint monochrome", section: 3, subSection: "general", subLabel: "Theme > General", icon: Icons.palette, isIcon: true },
        { label: "Enable Corners", keywords: "rounded corners radius screen", section: 3, subSection: "general", subLabel: "Theme > General", icon: Icons.cornersOut, isIcon: true },
        { label: "Animation Duration", keywords: "speed fast slow transition", section: 3, subSection: "general", subLabel: "Theme > General", icon: Icons.clock, isIcon: true },
        { label: "UI Font", keywords: "typography text family size", section: 3, subSection: "general", subLabel: "Theme > General", icon: Icons.textT, isIcon: true },
        { label: "Roundness", keywords: "radius border curve", section: 3, subSection: "general", subLabel: "Theme > General", icon: Icons.circle, isIcon: true },
        { label: "Color Scheme", keywords: "palette variant light dark", section: 3, subSection: "colors", subLabel: "Theme > Colors", icon: Icons.palette, isIcon: true },
        { label: "Color Variant", keywords: "background popup internal bar pane", section: 3, subSection: "colors", subLabel: "Theme > Colors", icon: Icons.palette, isIcon: true },
        { label: "Gradient Mode", keywords: "linear radial halftone", section: 3, subSection: "colors", subLabel: "Theme > Colors", icon: Icons.palette, isIcon: true },

        // --- Binds ---
        { label: "Key Bindings", keywords: "shortcuts keyboard hotkeys", section: 4, subSection: "", subLabel: "", icon: Icons.keyboard, isIcon: true },
        { label: "Launcher Keybind", keywords: "app launcher menu shortcut", section: 4, subSection: "", subLabel: "Binds > imperia", icon: Icons.rocket, isIcon: true },
        { label: "Dashboard Keybind", keywords: "widgets dashboard shortcut", section: 4, subSection: "", subLabel: "Binds > imperia", icon: Icons.squaresFour, isIcon: true },
        { label: "Screenshot Keybind", keywords: "capture screen shortcut print", section: 4, subSection: "", subLabel: "Binds > imperia", icon: Icons.camera, isIcon: true },
        { label: "Powermenu Keybind", keywords: "logout shutdown shortcut super escape", section: 4, subSection: "", subLabel: "Binds > imperia", icon: Icons.power, isIcon: true },

        // --- System ---
        { label: "System", keywords: "hardware info resources cpu ram", section: 5, subSection: "", subLabel: "System", icon: Icons.circuitry, isIcon: true },
        { label: "Prefixes", keywords: "shortcuts launcher quick actions", section: 5, subSection: "prefixes", subLabel: "System > Prefixes", icon: Icons.keyboard, isIcon: true },
        { label: "Idle Settings", keywords: "screen lock timeout sleep suspend", section: 5, subSection: "idle", subLabel: "System > Idle", icon: Icons.moon, isIcon: true },
        { label: "System Resources", keywords: "cpu ram memory usage monitor", section: 5, subSection: "resources", subLabel: "System > Resources", icon: Icons.circuitry, isIcon: true },

        // --- Compositor ---
        { label: "Compositor", keywords: "hyprland window manager wm", section: 6, subSection: "", subLabel: "Compositor", icon: Icons.compositor, isIcon: true },
        { label: "Window Gaps", keywords: "spacing margin padding", section: 6, subSection: "general", subLabel: "Compositor > General", icon: Icons.squaresFour, isIcon: true },
        { label: "Border Size", keywords: "width thickness stroke", section: 6, subSection: "general", subLabel: "Compositor > General", icon: Icons.frameCorners, isIcon: true },
        { label: "Blur Enabled", keywords: "toggle transparency", section: 6, subSection: "blur", subLabel: "Compositor > Blur", icon: Icons.drop, isIcon: true },

        // --- Imperia Shell ---
        { label: "Imperia Shell", keywords: "about info credits version shell", section: 7, subSection: "", subLabel: "", icon: Qt.resolvedUrl("../../../../assets/imperia/imperia-icon.svg"), isIcon: false },
        { label: "Bar Settings", keywords: "panel taskbar position", section: 7, subSection: "bar", subLabel: "Imperia > Bar", icon: Icons.layout, isIcon: true },
        { label: "Notch Settings", keywords: "island dynamic island center top", section: 7, subSection: "notch", subLabel: "Imperia > Notch", icon: Icons.layout, isIcon: true },
        { label: "Workspaces", keywords: "virtual desktop spaces", section: 7, subSection: "workspaces", subLabel: "Imperia > Workspaces", icon: Icons.squaresFour, isIcon: true },
        { label: "Dock", keywords: "taskbar launcher apps favorites", section: 7, subSection: "dock", subLabel: "Imperia > Dock", icon: Icons.layout, isIcon: true },
        { label: "Lockscreen", keywords: "lock screen password login", section: 7, subSection: "lockscreen", subLabel: "Imperia > Lockscreen", icon: Icons.lock, isIcon: true },

        // --- Performance ---
        { label: "Performance", keywords: "cpu power profile battery save", section: 8, subSection: "", subLabel: "", icon: Icons.cpu, isIcon: true },

        // --- Processes ---
        { label: "Processes", keywords: "tasks running apps kill htop monitor", section: 9, subSection: "", subLabel: "", icon: Icons.list, isIcon: true }
    ]

    property var items: staticItems.concat(dynamicItems)

    function addDynamicItems(newItems) {
        let currentLabels = new Set(items.map(i => i.section + ":" + i.label));
        let uniqueNew = [];
        for (let i = 0; i < newItems.length; i++) {
            let item = newItems[i];
            let key = item.section + ":" + item.label;
            if (!currentLabels.has(key)) {
                uniqueNew.push(item);
                currentLabels.add(key);
            }
        }
        if (uniqueNew.length > 0) {
            dynamicItems = dynamicItems.concat(uniqueNew);
        }
    }
}
