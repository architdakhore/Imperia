pragma ComponentBehavior: Bound

// ─────────────────────────────────────────────────────────────────────────────
// ControlCenterWindow.qml — Imperia Shell ★ Enhanced
// Combined control center from DankMaterial + Caelestia + Illogical Impulse:
//   • Quick toggles grid (WiFi, Bluetooth, DND, Night Light, Caffeine, etc.)
//   • Volume + Brightness sliders
//   • Media player widget
//   • Notifications panel with history
//   • System resource mini-gauges
//   • Profile header with user info + date/time
// ─────────────────────────────────────────────────────────────────────────────
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Services.Mpris
import qs.modules.theme
import qs.modules.services
import qs.modules.globals
import qs.modules.components
import qs.config

PanelWindow {
    id: ccWindow

    // Anchor to top-right corner
    anchors.top:   true
    anchors.right: true

    width: visible ? panelWidth : 0
    height: screen ? screen.height : 800

    color: "transparent"
    exclusionMode: ExclusionMode.Ignore

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "imperia:controlcenter"
    WlrLayershell.keyboardFocus: GlobalStates.controlCenterVisible
        ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

    visible: GlobalStates.controlCenterVisible

    readonly property int panelWidth: 380
    readonly property int panelMargin: 12

    // Click outside to close
    MouseArea {
        anchors.fill: parent
        z: -1
        onClicked: GlobalStates.controlCenterVisible = false
    }

    // ── Slide-in panel ─────────────────────────────────────────────────────────
    Item {
        id: panel
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.topMargin: panelMargin
        anchors.rightMargin: panelMargin
        width: panelWidth - panelMargin * 2
        height: parent.height - panelMargin * 2

        // Slide from right
        transform: Translate {
            x: panel.visible ? 0 : panelWidth + 40
            Behavior on x { NumberAnimation { duration: Math.round(Config.animDuration * 1.1); easing.type: Easing.OutBack; easing.overshoot: 0.5 } }
        }
        opacity: GlobalStates.controlCenterVisible ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: Math.round(Config.animDuration * 0.7); easing.type: Easing.OutCubic } }

        Column {
            anchors.fill: parent
            spacing: 8

            // ── Profile header ──────────────────────────────────────────────────
            StyledRect {
                variant: "bg"
                width: parent.width
                height: 80
                radius: Config.roundness + 4

                layer.enabled: true
                layer.effect: MultiEffect {
                    shadowEnabled: true; shadowBlur: 0.8
                    shadowColor: "#66000000"; shadowVerticalOffset: 4
                }

                Row {
                    anchors.left: parent.left; anchors.leftMargin: 16
                    anchors.verticalCenter: parent.verticalCenter; spacing: 14

                    // Avatar
                    Rectangle {
                        width: 48; height: 48; radius: 24
                        color: Colors.primaryContainer
                        anchors.verticalCenter: parent.verticalCenter
                        Text {
                            anchors.centerIn: parent; text: "\ue7fd"
                            font.family: Icons.font; font.pixelSize: 26
                            color: Colors.onPrimaryContainer
                        }
                    }

                    Column {
                        anchors.verticalCenter: parent.verticalCenter; spacing: 3
                        Text {
                            text: Quickshell.env("USER") || "User"
                            font.family: Config.theme.font; font.pixelSize: Config.theme.fontSize + 2
                            font.weight: Font.SemiBold; color: Colors.overBackground
                        }
                        Text {
                            text: Qt.formatDateTime(new Date(), "dddd, MMMM d")
                            font.family: Config.theme.font; font.pixelSize: Config.theme.fontSize - 1
                            color: Colors.outline
                        }
                    }

                    Item { Layout.fillWidth: true }
                }

                // Big time in top right
                Text {
                    anchors.right: parent.right; anchors.rightMargin: 16
                    anchors.verticalCenter: parent.verticalCenter
                    text: Qt.formatDateTime(new Date(), Config.bar.use12hFormat ? "h:mm ap" : "HH:mm")
                    font.family: Config.theme.font; font.pixelSize: Config.theme.fontSize + 10
                    font.weight: Font.Light; color: Colors.overBackground; opacity: 0.85

                    Timer { interval: 10000; running: true; repeat: true; onTriggered: parent.text = Qt.formatDateTime(new Date(), Config.bar.use12hFormat ? "h:mm ap" : "HH:mm") }
                }
            }

            // ── Quick toggles grid ──────────────────────────────────────────────
            StyledRect {
                variant: "bg"
                width: parent.width
                height: 126
                radius: Config.roundness + 4
                layer.enabled: true
                layer.effect: MultiEffect { shadowEnabled: true; shadowBlur: 0.8; shadowColor: "#55000000"; shadowVerticalOffset: 3 }

                Grid {
                    anchors.centerIn: parent
                    columns: 5
                    spacing: 8

                    // Toggle button component
                    component ToggleBtn: Item {
                        property string icon: "\ue894"
                        property string label: "Toggle"
                        property bool active: false
                        property color activeColor: Colors.primary
                        signal clicked()

                        width: 56; height: 56

                        Rectangle {
                            anchors.fill: parent; radius: Config.roundness > 0 ? Config.roundness : 14
                            color: parent.active
                                ? Qt.rgba(parent.activeColor.r, parent.activeColor.g, parent.activeColor.b, 0.22)
                                : Qt.rgba(Colors.surfaceVariant.r, Colors.surfaceVariant.g, Colors.surfaceVariant.b, 0.5)
                            Behavior on color { ColorAnimation { duration: 220 } }

                            // Glow ring when active
                            Rectangle {
                                anchors.fill: parent; radius: parent.radius
                                color: "transparent"
                                border.color: parent.parent.active ? parent.parent.activeColor : "transparent"
                                border.width: parent.parent.active ? 1.5 : 0
                                opacity: 0.7
                                Behavior on border.width { NumberAnimation { duration: 200 } }
                            }

                            Column {
                                anchors.centerIn: parent; spacing: 4
                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: parent.parent.parent.icon
                                    font.family: Icons.font; font.pixelSize: 18
                                    color: parent.parent.parent.active ? parent.parent.parent.activeColor : Colors.outline
                                    Behavior on color { ColorAnimation { duration: 200 } }
                                }
                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: parent.parent.parent.label
                                    font.family: Config.theme.font; font.pixelSize: 9
                                    color: parent.parent.parent.active ? parent.parent.parent.activeColor : Colors.outline
                                    Behavior on color { ColorAnimation { duration: 200 } }
                                }
                            }
                        }

                        // Press effect
                        scale: toggleBtnArea.pressed ? 0.88 : 1.0
                        Behavior on scale { NumberAnimation { duration: 80; easing.type: Easing.OutCubic } }

                        HoverHandler { id: toggleHover }
                        MouseArea {
                            id: toggleBtnArea; anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                            onClicked: parent.clicked()
                        }
                    }

                    // WiFi
                    ToggleBtn {
                        icon: NetworkService.wifiEnabled ? "\ue894" : "\ue1da"
                        label: "WiFi"; active: NetworkService.wifiEnabled
                        onClicked: NetworkService.wifiEnabled = !NetworkService.wifiEnabled
                    }

                    // Bluetooth
                    ToggleBtn {
                        icon: BluetoothService.enabled ? "\ue1a7" : "\ue1a8"
                        label: "BT"; active: BluetoothService.enabled
                        onClicked: BluetoothService.enabled = !BluetoothService.enabled
                    }

                    // Do Not Disturb
                    ToggleBtn {
                        icon: Notifications.dontDisturb ? "\ue7f8" : "\ue7f4"
                        label: "DND"; active: Notifications.dontDisturb
                        activeColor: "#f97316"
                        onClicked: Notifications.dontDisturb = !Notifications.dontDisturb
                    }

                    // Night Light
                    ToggleBtn {
                        icon: "\uea24"; label: "Night"
                        active: NightLightService.active
                        activeColor: "#f59e0b"
                        onClicked: NightLightService.active = !NightLightService.active
                    }

                    // Caffeine (keep screen on)
                    ToggleBtn {
                        icon: "\uef6f"; label: "Awake"
                        active: CaffeineService.inhibit
                        activeColor: "#10b981"
                        onClicked: CaffeineService.inhibit = !CaffeineService.inhibit
                    }
                }
            }

            // ── Sliders (volume + brightness) ───────────────────────────────────
            StyledRect {
                variant: "bg"
                width: parent.width
                height: 102
                radius: Config.roundness + 4
                layer.enabled: true
                layer.effect: MultiEffect { shadowEnabled: true; shadowBlur: 0.8; shadowColor: "#55000000"; shadowVerticalOffset: 3 }

                Column {
                    anchors.fill: parent; anchors.margins: 14; spacing: 8

                    // Volume slider
                    Row {
                        width: parent.width; spacing: 10
                        Text {
                            text: AudioService.muted ? "\ue04f" : (AudioService.volume > 0.66 ? "\ue050" : (AudioService.volume > 0.33 ? "\ue04d" : "\ue04e"))
                            font.family: Icons.font; font.pixelSize: 18; color: Colors.primary
                            anchors.verticalCenter: parent.verticalCenter
                            MouseArea { anchors.fill: parent; onClicked: AudioService.muted = !AudioService.muted }
                        }
                        Slider {
                            id: volSlider; width: parent.width - 30
                            from: 0; to: 1; value: AudioService.volume; stepSize: 0.01
                            anchors.verticalCenter: parent.verticalCenter
                            onMoved: AudioService.volume = value
                            background: Rectangle {
                                x: volSlider.leftPadding; y: volSlider.topPadding + (volSlider.availableHeight - height) / 2
                                implicitWidth: 200; implicitHeight: 5
                                width: volSlider.availableWidth; height: implicitHeight
                                radius: height / 2
                                color: Qt.rgba(Colors.surfaceVariant.r, Colors.surfaceVariant.g, Colors.surfaceVariant.b, 0.8)
                                Rectangle {
                                    width: volSlider.visualPosition * parent.width
                                    height: parent.height; radius: parent.radius
                                    color: Colors.primary
                                    Behavior on width { NumberAnimation { duration: 80 } }
                                }
                            }
                            handle: Rectangle {
                                x: volSlider.leftPadding + volSlider.visualPosition * (volSlider.availableWidth - width)
                                y: volSlider.topPadding + (volSlider.availableHeight - height) / 2
                                implicitWidth: 18; implicitHeight: 18; radius: 9
                                color: Colors.primary
                                scale: volSlider.pressed ? 1.25 : 1.0
                                Behavior on scale { NumberAnimation { duration: 100; easing.type: Easing.OutBack } }
                            }
                        }
                    }

                    // Brightness slider
                    Row {
                        width: parent.width; spacing: 10
                        Text {
                            text: "\ue3a6"; font.family: Icons.font; font.pixelSize: 18
                            color: "#f59e0b"; anchors.verticalCenter: parent.verticalCenter
                        }
                        Slider {
                            id: brightSlider; width: parent.width - 30
                            from: 0; to: 1; value: BrightnessService.brightness; stepSize: 0.01
                            anchors.verticalCenter: parent.verticalCenter
                            onMoved: BrightnessService.brightness = value
                            background: Rectangle {
                                x: brightSlider.leftPadding; y: brightSlider.topPadding + (brightSlider.availableHeight - height) / 2
                                implicitWidth: 200; implicitHeight: 5
                                width: brightSlider.availableWidth; height: implicitHeight
                                radius: height / 2
                                color: Qt.rgba(Colors.surfaceVariant.r, Colors.surfaceVariant.g, Colors.surfaceVariant.b, 0.8)
                                Rectangle {
                                    width: brightSlider.visualPosition * parent.width
                                    height: parent.height; radius: parent.radius
                                    color: "#f59e0b"
                                    Behavior on width { NumberAnimation { duration: 80 } }
                                }
                            }
                            handle: Rectangle {
                                x: brightSlider.leftPadding + brightSlider.visualPosition * (brightSlider.availableWidth - width)
                                y: brightSlider.topPadding + (brightSlider.availableHeight - height) / 2
                                implicitWidth: 18; implicitHeight: 18; radius: 9
                                color: "#f59e0b"
                                scale: brightSlider.pressed ? 1.25 : 1.0
                                Behavior on scale { NumberAnimation { duration: 100; easing.type: Easing.OutBack } }
                            }
                        }
                    }
                }
            }

            // ── Media player ────────────────────────────────────────────────────
            Loader {
                active: MprisController.activePlayer !== null
                width: parent.width

                sourceComponent: StyledRect {
                    variant: "bg"
                    width: parent.width; height: 88
                    radius: Config.roundness + 4
                    layer.enabled: true
                    layer.effect: MultiEffect { shadowEnabled: true; shadowBlur: 0.8; shadowColor: "#55000000"; shadowVerticalOffset: 3 }

                    readonly property var player: MprisController.activePlayer

                    Row {
                        anchors.fill: parent; anchors.margins: 14; spacing: 12

                        // Album art placeholder
                        Rectangle {
                            width: 60; height: 60; radius: 8
                            color: Colors.primaryContainer
                            anchors.verticalCenter: parent.verticalCenter
                            Text {
                                anchors.centerIn: parent; text: "\ue3f4"
                                font.family: Icons.font; font.pixelSize: 28
                                color: Colors.onPrimaryContainer
                            }
                        }

                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            width: parent.width - 60 - 12 - 14
                            spacing: 4

                            Text {
                                width: parent.width
                                text: player?.trackTitle || "Unknown Track"
                                font.family: Config.theme.font; font.pixelSize: Config.theme.fontSize + 1
                                font.weight: Font.SemiBold; color: Colors.overBackground
                                elide: Text.ElideRight
                            }
                            Text {
                                width: parent.width
                                text: player?.trackArtist || "Unknown Artist"
                                font.family: Config.theme.font; font.pixelSize: Config.theme.fontSize - 1
                                color: Colors.outline; elide: Text.ElideRight
                            }

                            // Controls
                            Row {
                                spacing: 8
                                Repeater {
                                    model: [
                                        { icon: "\ue045", action: "prev" },
                                        { icon: player?.playbackState === MprisPlaybackState.Playing ? "\ue034" : "\ue037", action: "play" },
                                        { icon: "\ue044", action: "next" },
                                    ]
                                    delegate: Item {
                                        required property var modelData
                                        width: 28; height: 28
                                        Rectangle {
                                            anchors.fill: parent; radius: 14
                                            color: mCtrlHover.hovered ? Qt.rgba(Colors.primary.r, Colors.primary.g, Colors.primary.b, 0.2) : "transparent"
                                            Behavior on color { ColorAnimation { duration: 150 } }
                                        }
                                        Text {
                                            anchors.centerIn: parent
                                            text: modelData.icon; font.family: Icons.font; font.pixelSize: 16
                                            color: Colors.primary
                                        }
                                        HoverHandler { id: mCtrlHover }
                                        MouseArea {
                                            anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                if (modelData.action === "play") player?.togglePlaying()
                                                else if (modelData.action === "prev") player?.previous()
                                                else player?.next()
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // ── System stats mini-row ────────────────────────────────────────────
            StyledRect {
                variant: "bg"
                width: parent.width; height: 58
                radius: Config.roundness + 4
                layer.enabled: true
                layer.effect: MultiEffect { shadowEnabled: true; shadowBlur: 0.8; shadowColor: "#55000000"; shadowVerticalOffset: 3 }

                Row {
                    anchors.centerIn: parent; spacing: 20

                    component MiniStat: Column {
                        property string icon: "\ue9f9"
                        property string value: "0%"
                        property color accentColor: Colors.primary

                        spacing: 3; width: 52

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: parent.icon; font.family: Icons.font; font.pixelSize: 15
                            color: parent.accentColor; opacity: 0.85
                        }
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: parent.value
                            font.family: Config.theme.font; font.pixelSize: Config.theme.fontSize - 1
                            font.weight: Font.SemiBold; color: Colors.overBackground
                        }
                    }

                    // Divider
                    component StatDiv: Rectangle {
                        width: 1; height: 28; anchors.verticalCenter: parent?.verticalCenter ?? undefined
                        color: Colors.outline; opacity: 0.25
                    }

                    MiniStat { icon: "\ueb8e"; value: Math.round(SystemResources.cpuUsage) + "%"; accentColor: Colors.primary }
                    StatDiv {}
                    MiniStat { icon: "\ue322"; value: Math.round(SystemResources.ramUsage) + "%"; accentColor: "#a78bfa" }
                    StatDiv {}
                    MiniStat {
                        icon: "\ue3af"
                        value: SystemResources.cpuTemp > 0 ? SystemResources.cpuTemp + "°" : "–"
                        accentColor: SystemResources.cpuTemp > 80 ? "#ef4444" : "#f97316"
                    }
                    StatDiv {}
                    MiniStat { icon: "\ue1a1"; value: BatteryService.percentage + "%"; accentColor: BatteryService.percentage < 20 ? "#ef4444" : "#10b981" }
                }
            }

            // ── Notifications panel ──────────────────────────────────────────────
            StyledRect {
                variant: "bg"
                width: parent.width
                height: Math.min(notifColumn.implicitHeight + 24, 340)
                radius: Config.roundness + 4
                clip: true
                layer.enabled: true
                layer.effect: MultiEffect { shadowEnabled: true; shadowBlur: 0.8; shadowColor: "#55000000"; shadowVerticalOffset: 3 }

                Column {
                    id: notifColumn
                    anchors.top: parent.top; anchors.left: parent.left; anchors.right: parent.right
                    anchors.margins: 14; spacing: 8

                    // Header
                    Row {
                        width: parent.width; height: 28

                        Text {
                            text: "\ue7f4"; font.family: Icons.font; font.pixelSize: 16
                            color: Colors.primary; anchors.verticalCenter: parent.verticalCenter
                        }
                        Item { width: 8 }
                        Text {
                            text: "Notifications"
                            font.family: Config.theme.font; font.pixelSize: Config.theme.fontSize + 1
                            font.weight: Font.SemiBold; color: Colors.overBackground
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        Item { Layout.fillWidth: true; width: parent.width - 200 }

                        // Clear all
                        Item {
                            width: 22; height: 22; anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                            Rectangle {
                                anchors.fill: parent; radius: 11
                                color: clearHover.hovered ? Qt.rgba(Colors.error.r, Colors.error.g, Colors.error.b, 0.2) : "transparent"
                                Behavior on color { ColorAnimation { duration: 150 } }
                            }
                            Text {
                                anchors.centerIn: parent; text: "\ue5cd"
                                font.family: Icons.font; font.pixelSize: 12; color: Colors.outline
                            }
                            HoverHandler { id: clearHover }
                            MouseArea {
                                anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                onClicked: Notifications.dismissAll()
                            }
                        }
                    }

                    // Notification items
                    Repeater {
                        model: Notifications.list.slice(0, 6)

                        delegate: Item {
                            required property var modelData
                            width: notifColumn.width; height: notifCard.height + 4

                            Rectangle {
                                id: notifCard
                                width: parent.width; radius: Config.roundness > 0 ? Config.roundness : 10
                                height: notifContent.implicitHeight + 16
                                color: Qt.rgba(Colors.surfaceVariant.r, Colors.surfaceVariant.g, Colors.surfaceVariant.b, 0.45)

                                // Left accent
                                Rectangle {
                                    anchors.left: parent.left; anchors.top: parent.top; anchors.bottom: parent.bottom
                                    width: 3; radius: 2
                                    color: Colors.primary; opacity: 0.8
                                }

                                Column {
                                    id: notifContent
                                    anchors.left: parent.left; anchors.right: parent.right
                                    anchors.verticalCenter: parent.verticalCenter
                                    anchors.leftMargin: 14; anchors.rightMargin: 30
                                    spacing: 3

                                    Text {
                                        width: parent.width
                                        text: modelData.appName || "Notification"
                                        font.family: Config.theme.font; font.pixelSize: Config.theme.fontSize - 1
                                        font.weight: Font.SemiBold; color: Colors.primary; elide: Text.ElideRight
                                    }
                                    Text {
                                        width: parent.width
                                        text: modelData.summary || ""
                                        font.family: Config.theme.font; font.pixelSize: Config.theme.fontSize
                                        color: Colors.overBackground; elide: Text.ElideRight
                                        visible: text.length > 0
                                    }
                                    Text {
                                        width: parent.width
                                        text: modelData.body || ""
                                        font.family: Config.theme.font; font.pixelSize: Config.theme.fontSize - 1
                                        color: Colors.outline; elide: Text.ElideRight; maximumLineCount: 2; wrapMode: Text.Wrap
                                        visible: text.length > 0
                                    }
                                }

                                // Dismiss button
                                Item {
                                    anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                                    anchors.rightMargin: 8; width: 20; height: 20
                                    Text {
                                        anchors.centerIn: parent; text: "\ue5cd"
                                        font.family: Icons.font; font.pixelSize: 12; color: Colors.outline
                                    }
                                    MouseArea {
                                        anchors.fill: parent
                                        onClicked: modelData.dismiss()
                                    }
                                }
                            }
                        }
                    }

                    // Empty state
                    Item {
                        width: parent.width; height: 48
                        visible: Notifications.list.length === 0
                        Column {
                            anchors.centerIn: parent; spacing: 4
                            Text { anchors.horizontalCenter: parent.horizontalCenter; text: "\ue7f3"; font.family: Icons.font; font.pixelSize: 20; color: Colors.outline; opacity: 0.5 }
                            Text { anchors.horizontalCenter: parent.horizontalCenter; text: "No notifications"; font.family: Config.theme.font; font.pixelSize: Config.theme.fontSize - 1; color: Colors.outline; opacity: 0.5 }
                        }
                    }
                }
            }
        }
    }

    Keys.onEscapePressed: GlobalStates.controlCenterVisible = false
}
