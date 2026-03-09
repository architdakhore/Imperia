pragma ComponentBehavior: Bound

// ─────────────────────────────────────────────────────────────────────────────
// SettingsWindow.qml — Imperia Shell ★ Enhanced
// DankMaterial-inspired: frosted sidebar with COLORFUL icons, animated pill
// selection, the SettingsTab's built-in sidebar is hidden (showSidebar:false)
// so only our beautiful sidebar drives navigation.
// ─────────────────────────────────────────────────────────────────────────────
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import qs.modules.widgets.dashboard.controls
import qs.modules.components
import qs.modules.globals
import qs.modules.theme
import qs.config

PanelWindow {
    id: settingsWindow

    anchors.top:    true
    anchors.bottom: true
    anchors.left:   true
    anchors.right:  true

    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: GlobalStates.settingsWindowVisible
        ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
    WlrLayershell.namespace: "imperia:settings"
    visible: GlobalStates.settingsWindowVisible

    mask: Region { item: GlobalStates.settingsWindowVisible ? dialogBox : emptyMask }
    Item { id: emptyMask; width: 0; height: 0 }

    property int currentSection: 0

    // Colorful icon + label per section (matches SettingsTab section numbers)
    readonly property var sections: [
        { label: "Network",     icon: "\ue894", color: "#3b82f6" },  // blue  – wifi
        { label: "Bluetooth",   icon: "\ue1a7", color: "#8b5cf6" },  // violet
        { label: "Audio",       icon: "\ue050", color: "#10b981" },  // emerald
        { label: "Theme",       icon: "\ue40a", color: "#f97316" },  // orange – palette
        { label: "Keybinds",    icon: "\ue312", color: "#f59e0b" },  // amber  – keyboard
        { label: "System",      icon: "\ue610", color: "#06b6d4" },  // cyan   – settings
        { label: "Compositor",  icon: "\ue3ae", color: "#a78bfa" },  // purple – layers
        { label: "Imperia",     icon: "\ue88a", color: "#ec4899" },  // pink   – home
        { label: "Performance", icon: "\ue9f9", color: "#ef4444" },  // red    – speed
        { label: "Processes",   icon: "\ue8f3", color: "#64748b" },  // slate  – list
    ]

    // ── Dim backdrop ──────────────────────────────────────────────────────────
    Rectangle {
        anchors.fill: parent
        color: "#000000"
        opacity: GlobalStates.settingsWindowVisible ? 0.65 : 0
        Behavior on opacity {
            NumberAnimation { duration: Math.round(Config.animDuration * 0.65); easing.type: Easing.OutCubic }
        }
        MouseArea { anchors.fill: parent; onClicked: GlobalStates.settingsWindowVisible = false }
    }

    // ── Dialog ────────────────────────────────────────────────────────────────
    Item {
        id: dialogBox
        anchors.centerIn: parent
        width:  Math.min(parent.width  - 60, 1040)
        height: Math.min(parent.height - 60, 750)

        scale:   GlobalStates.settingsWindowVisible ? 1.0 : 0.86
        opacity: GlobalStates.settingsWindowVisible ? 1.0 : 0.0

        Behavior on scale   { NumberAnimation { duration: Math.round(Config.animDuration * 1.1); easing.type: Easing.OutBack; easing.overshoot: 1.2 } }
        Behavior on opacity { NumberAnimation { duration: Math.round(Config.animDuration * 0.65); easing.type: Easing.OutCubic } }

        // ── Card ─────────────────────────────────────────────────────────────
        StyledRect {
            id: card
            anchors.fill: parent
            variant: "bg"
            radius: Math.max(Config.roundness + 6, 18)

            layer.enabled: true
            layer.effect: MultiEffect {
                shadowEnabled: true; shadowBlur: 1.0
                shadowColor: "#BB000000"
                shadowVerticalOffset: 12; shadowHorizontalOffset: 0
            }

            // ════════════════════════════════════════════════
            // LEFT SIDEBAR
            // ════════════════════════════════════════════════
            Rectangle {
                id: sidebarBg
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.bottom: parent.bottom
                width: 240

                // Slightly darker frosted glass
                color: Qt.rgba(
                    Colors.background.r * 0.94,
                    Colors.background.g * 0.94,
                    Colors.background.b * 0.96,
                    0.72
                )
                radius: card.radius

                // Square-off right side
                Rectangle {
                    anchors.top: parent.top; anchors.right: parent.right; anchors.bottom: parent.bottom
                    width: parent.radius; color: parent.color
                }

                Column {
                    anchors.fill: parent
                    spacing: 0

                    // ── Brand header ──────────────────────────────────────────
                    Item {
                        width: parent.width; height: 72

                        // Gradient accent strip at top
                        Rectangle {
                            anchors.top: parent.top; anchors.left: parent.left; anchors.right: parent.right
                            height: 3; radius: 2
                            gradient: Gradient {
                                orientation: Gradient.Horizontal
                                GradientStop { position: 0.0; color: Colors.primary }
                                GradientStop { position: 0.5; color: Qt.rgba(Colors.tertiary?.r ?? 0.5, Colors.tertiary?.g ?? 0.3, Colors.tertiary?.b ?? 0.8, 1) }
                                GradientStop { position: 1.0; color: Colors.secondary }
                            }
                        }

                        Row {
                            anchors.left: parent.left; anchors.leftMargin: 18
                            anchors.verticalCenter: parent.verticalCenter; spacing: 12

                            // Colorful settings icon
                            Rectangle {
                                width: 36; height: 36; radius: 10
                                anchors.verticalCenter: parent.verticalCenter
                                gradient: Gradient {
                                    orientation: Gradient.Horizontal
                                    GradientStop { position: 0.0; color: Colors.primary }
                                    GradientStop { position: 1.0; color: Qt.rgba(Colors.primary.r * 0.7, Colors.primary.g * 0.7, Colors.primary.b * 1.2, 1) }
                                }
                                Text {
                                    anchors.centerIn: parent; text: "\ue8b8"
                                    font.family: Icons.font; font.pixelSize: 18
                                    color: "#ffffff"
                                }
                            }

                            Column {
                                anchors.verticalCenter: parent.verticalCenter; spacing: 1
                                Text {
                                    text: "Settings"
                                    font.family: Config.theme.font; font.pixelSize: Config.theme.fontSize + 6
                                    font.weight: Font.Bold; color: Colors.overBackground
                                }
                                Text {
                                    text: "Imperia Shell"
                                    font.family: Config.theme.font; font.pixelSize: Config.theme.fontSize - 2
                                    color: Colors.primary; opacity: 0.85
                                }
                            }
                        }
                    }

                    // Divider
                    Rectangle { width: parent.width - 24; height: 1; anchors.horizontalCenter: parent.horizontalCenter; color: Colors.surfaceBright; opacity: 0.3 }

                    // ── Search bar ────────────────────────────────────────────
                    Item {
                        width: parent.width; height: 54

                        Rectangle {
                            anchors.fill: parent; anchors.margins: 10; anchors.bottomMargin: 6
                            radius: Config.roundness > 0 ? Config.roundness : 12
                            color: Qt.rgba(Colors.surfaceVariant.r, Colors.surfaceVariant.g, Colors.surfaceVariant.b, 0.6)
                            border.color: searchInput.activeFocus
                                ? Colors.primary : Qt.rgba(Colors.outline.r, Colors.outline.g, Colors.outline.b, 0.2)
                            border.width: 1
                            Behavior on border.color { ColorAnimation { duration: 160 } }

                            Row {
                                anchors.left: parent.left; anchors.leftMargin: 12
                                anchors.verticalCenter: parent.verticalCenter; spacing: 8

                                Text {
                                    text: "\ue8b6"; font.family: Icons.font; font.pixelSize: 15
                                    color: searchInput.activeFocus ? Colors.primary : Colors.outline
                                    anchors.verticalCenter: parent.verticalCenter
                                    Behavior on color { ColorAnimation { duration: 160 } }
                                }
                                TextInput {
                                    id: searchInput
                                    width: sidebarBg.width - 72
                                    anchors.verticalCenter: parent.verticalCenter
                                    color: Colors.overBackground
                                    font.family: Config.theme.font; font.pixelSize: Config.theme.fontSize
                                    clip: true

                                    Text {
                                        anchors.fill: parent
                                        text: "Search settings…"
                                        color: Colors.outline; opacity: 0.7
                                        font.family: Config.theme.font; font.pixelSize: Config.theme.fontSize
                                        visible: !searchInput.activeFocus && searchInput.text.length === 0
                                    }

                                    onTextChanged: {
                                        // Push search query into SettingsTab
                                        settingsContent.searchQuery = text.toLowerCase()
                                    }
                                }
                            }
                        }
                    }

                    // Divider
                    Rectangle { width: parent.width - 24; height: 1; anchors.horizontalCenter: parent.horizontalCenter; color: Colors.surfaceBright; opacity: 0.2 }

                    // ── Navigation list ───────────────────────────────────────
                    Flickable {
                        width: parent.width
                        height: parent.height - 72 - 54 - 2
                        contentWidth: width; contentHeight: navCol.implicitHeight
                        clip: true; boundsBehavior: Flickable.StopAtBounds

                        Column {
                            id: navCol
                            width: parent.width
                            topPadding: 6; bottomPadding: 6
                            spacing: 2

                            Repeater {
                                model: settingsWindow.sections

                                delegate: Item {
                                    id: navItem
                                    required property var modelData
                                    required property int index
                                    width: navCol.width; height: 46

                                    readonly property bool isActive: settingsWindow.currentSection === index
                                    readonly property color itemColor: Qt.color(modelData.color)

                                    // Animated active pill
                                    Rectangle {
                                        id: activePill
                                        anchors.left: parent.left; anchors.leftMargin: 8
                                        anchors.right: parent.right; anchors.rightMargin: 8
                                        anchors.verticalCenter: parent.verticalCenter
                                        height: 38; radius: Config.roundness > 0 ? Math.max(Config.roundness, 10) : 12

                                        color: navItem.isActive
                                            ? Qt.rgba(navItem.itemColor.r, navItem.itemColor.g, navItem.itemColor.b, 0.18)
                                            : (itemHover.hovered
                                                ? Qt.rgba(navItem.itemColor.r, navItem.itemColor.g, navItem.itemColor.b, 0.08)
                                                : "transparent")

                                        Behavior on color { ColorAnimation { duration: 200 } }

                                        // Left accent bar
                                        Rectangle {
                                            anchors.left: parent.left; anchors.verticalCenter: parent.verticalCenter
                                            anchors.leftMargin: 0
                                            width: navItem.isActive ? 3 : 0; height: 26; radius: 2
                                            color: navItem.itemColor
                                            Behavior on width { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
                                        }

                                        Row {
                                            anchors.left: parent.left; anchors.leftMargin: 14
                                            anchors.verticalCenter: parent.verticalCenter; spacing: 12

                                            // COLORFUL icon circle
                                            Rectangle {
                                                width: 26; height: 26; radius: 8
                                                anchors.verticalCenter: parent.verticalCenter
                                                color: Qt.rgba(navItem.itemColor.r, navItem.itemColor.g, navItem.itemColor.b,
                                                    navItem.isActive ? 0.25 : 0.12)
                                                Behavior on color { ColorAnimation { duration: 200 } }

                                                Text {
                                                    anchors.centerIn: parent
                                                    text: navItem.modelData.icon
                                                    font.family: Icons.font; font.pixelSize: 14
                                                    color: navItem.itemColor
                                                    opacity: navItem.isActive ? 1.0 : 0.75
                                                    Behavior on opacity { NumberAnimation { duration: 200 } }
                                                }
                                            }

                                            // Label
                                            Text {
                                                text: navItem.modelData.label
                                                anchors.verticalCenter: parent.verticalCenter
                                                font.family: Config.theme.font
                                                font.pixelSize: Config.theme.fontSize
                                                font.weight: navItem.isActive ? Font.SemiBold : Font.Normal
                                                color: navItem.isActive ? navItem.itemColor : Colors.overBackground
                                                opacity: navItem.isActive ? 1.0 : 0.8
                                                Behavior on color { ColorAnimation { duration: 200 } }
                                                Behavior on opacity { NumberAnimation { duration: 200 } }
                                            }
                                        }

                                        // Active dot indicator on right
                                        Rectangle {
                                            anchors.right: parent.right; anchors.rightMargin: 10
                                            anchors.verticalCenter: parent.verticalCenter
                                            width: 6; height: 6; radius: 3
                                            color: navItem.itemColor
                                            visible: navItem.isActive
                                            opacity: navItem.isActive ? 1 : 0
                                            Behavior on opacity { NumberAnimation { duration: 200 } }
                                        }
                                    }

                                    // Bounce scale on click
                                    scale: itemPress.pressed ? 0.95 : 1.0
                                    Behavior on scale { NumberAnimation { duration: 100; easing.type: Easing.OutCubic } }

                                    HoverHandler { id: itemHover }
                                    MouseArea {
                                        id: itemPress
                                        anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            searchInput.text = ""
                                            settingsContent.searchQuery = ""
                                            settingsWindow.currentSection = index
                                            // Sync SettingsTab's selection
                                            settingsContent.currentSection = index
                                            // Find the matching index in filteredSections
                                            for (let i = 0; i < settingsContent.filteredSections.length; i++) {
                                                if (settingsContent.filteredSections[i].section === index) {
                                                    settingsContent.selectedIndex = i
                                                    break
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // Sidebar divider line
            Rectangle {
                anchors.top: parent.top; anchors.bottom: parent.bottom
                anchors.left: sidebarBg.right
                width: 1
                color: Colors.surfaceBright; opacity: 0.25
            }

            // ════════════════════════════════════════════════
            // RIGHT CONTENT AREA
            // ════════════════════════════════════════════════
            Item {
                id: contentArea
                anchors.top: parent.top; anchors.bottom: parent.bottom
                anchors.left: sidebarBg.right; anchors.right: parent.right
                anchors.leftMargin: 1

                // Content header bar
                Item {
                    id: contentHeader
                    anchors.top: parent.top; anchors.left: parent.left; anchors.right: parent.right
                    height: 72

                    Row {
                        anchors.left: parent.left; anchors.leftMargin: 22
                        anchors.verticalCenter: parent.verticalCenter; spacing: 14

                        // Big colorful icon circle
                        Rectangle {
                            property color sectionColor: settingsWindow.currentSection < settingsWindow.sections.length
                                ? Qt.color(settingsWindow.sections[settingsWindow.currentSection].color) : Colors.primary
                            width: 42; height: 42; radius: 13
                            color: Qt.rgba(sectionColor.r, sectionColor.g, sectionColor.b, 0.18)
                            anchors.verticalCenter: parent.verticalCenter
                            Behavior on color { ColorAnimation { duration: 250 } }

                            Text {
                                anchors.centerIn: parent
                                text: settingsWindow.currentSection < settingsWindow.sections.length
                                    ? settingsWindow.sections[settingsWindow.currentSection].icon : "\ue8b8"
                                font.family: Icons.font; font.pixelSize: 22
                                color: parent.sectionColor
                                Behavior on color { ColorAnimation { duration: 250 } }
                            }
                        }

                        Column {
                            anchors.verticalCenter: parent.verticalCenter; spacing: 2
                            Text {
                                text: settingsWindow.currentSection < settingsWindow.sections.length
                                    ? settingsWindow.sections[settingsWindow.currentSection].label : "Settings"
                                font.family: Config.theme.font; font.pixelSize: Config.theme.fontSize + 6
                                font.weight: Font.DemiBold; color: Colors.overBackground
                                Behavior on text {} // no animation needed
                            }
                            Text {
                                text: "Imperia Shell Configuration"
                                font.family: Config.theme.font; font.pixelSize: Config.theme.fontSize - 2
                                color: Colors.outline; opacity: 0.7
                            }
                        }
                    }

                    // Close button (top right)
                    Item {
                        anchors.right: parent.right; anchors.rightMargin: 14
                        anchors.verticalCenter: parent.verticalCenter
                        width: 36; height: 36

                        Rectangle {
                            anchors.fill: parent; radius: 18
                            color: closeHov.hovered
                                ? Qt.rgba(Colors.error.r, Colors.error.g, Colors.error.b, 0.85)
                                : Qt.rgba(Colors.surfaceVariant.r, Colors.surfaceVariant.g, Colors.surfaceVariant.b, 0.6)
                            Behavior on color { ColorAnimation { duration: 150 } }
                        }
                        Text {
                            anchors.centerIn: parent; text: "\ue5cd"
                            font.family: Icons.font; font.pixelSize: 17
                            color: closeHov.hovered ? "#ffffff" : Colors.outline
                            Behavior on color { ColorAnimation { duration: 150 } }
                        }
                        HoverHandler { id: closeHov }
                        MouseArea {
                            anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                            onClicked: GlobalStates.settingsWindowVisible = false
                        }
                    }

                    // Bottom divider
                    Rectangle {
                        anchors.bottom: parent.bottom; anchors.left: parent.left; anchors.right: parent.right
                        height: 1; color: Colors.surfaceBright; opacity: 0.28
                    }
                }

                // Settings content — sidebar hidden, driven by our sidebar
                SettingsTab {
                    id: settingsContent
                    anchors.top: contentHeader.bottom
                    anchors.left: parent.left; anchors.right: parent.right; anchors.bottom: parent.bottom
                    showSidebar: false            // ← hides SettingsTab's own sidebar
                    currentSection: settingsWindow.currentSection
                }
            }
        }
    }

    Keys.onEscapePressed: GlobalStates.settingsWindowVisible = false

    Connections {
        target: GlobalStates
        function onSettingsWindowVisibleChanged() {
            if (GlobalStates.settingsWindowVisible) {
                Qt.callLater(() => searchInput.forceActiveFocus())
            }
        }
    }
}
