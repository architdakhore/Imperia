pragma ComponentBehavior: Bound
// ─────────────────────────────────────────────────────────────────────────────
// OSD.qml — Imperia Shell (Redesigned)
// Beautiful pill-shaped OSD with animated icon, smooth progress bar,
// glassmorphism-style background, and slide-in/fade-out transitions.
// ─────────────────────────────────────────────────────────────────────────────
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.modules.components
import qs.modules.theme
import qs.modules.services
import qs.modules.globals
import qs.config

PanelWindow {
    id: root

    property ShellScreen targetScreen
    screen: targetScreen

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "imperia:osd"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
    exclusionMode: ExclusionMode.Ignore

    anchors.bottom: true
    anchors.left: true
    anchors.right: true

    WlrLayershell.margins.bottom: 80

    color: "transparent"
    visible: true

    property real osdValue: 0
    property bool osdMuted: false
    property bool showing: GlobalStates.osdVisible

    // ── Centering wrapper ─────────────────────────────────────────────────────
    Item {
        anchors.fill: parent

        Item {
            id: osdCard
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            width: osdRow.implicitWidth + 48
            height: 64

            opacity: root.showing ? 1.0 : 0.0
            y: root.showing ? 0 : 18

            Behavior on opacity {
                NumberAnimation {
                    duration: root.showing ? (Config.animDuration ?? 200) : Math.round((Config.animDuration ?? 200) * 1.5)
                    easing.type: root.showing ? Easing.OutCubic : Easing.InCubic
                }
            }
            Behavior on y {
                NumberAnimation {
                    duration: root.showing ? (Config.animDuration ?? 200) : Math.round((Config.animDuration ?? 200) * 1.5)
                    easing.type: root.showing ? Easing.OutBack : Easing.InCubic
                    easing.overshoot: 1.1
                }
            }

            // Glassmorphism pill background
            Rectangle {
                anchors.fill: parent
                radius: height / 2
                color: Qt.rgba(
                    Colors.background.r,
                    Colors.background.g,
                    Colors.background.b,
                    0.88
                )
                border.color: Qt.rgba(Colors.overBackground.r, Colors.overBackground.g, Colors.overBackground.b, 0.08)
                border.width: 1
                layer.enabled: true
            }

            RowLayout {
                id: osdRow
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: 20
                spacing: 14

                // ── Icon pill ─────────────────────────────────────────────────
                Rectangle {
                    width: 36
                    height: 36
                    radius: 10
                    color: root.osdMuted
                        ? Qt.rgba(0.9, 0.3, 0.3, 0.18)
                        : Qt.rgba(Colors.primary.r, Colors.primary.g, Colors.primary.b, 0.18)
                    Behavior on color { ColorAnimation { duration: 200 } }

                    Text {
                        anchors.centerIn: parent
                        text: {
                            const ind = GlobalStates.osdIndicator;
                            if (ind === "volume") return Audio.volumeIcon(root.osdValue, root.osdMuted);
                            if (ind === "mic")    return root.osdMuted ? Icons.micSlash : Icons.mic;
                            return Icons.sun;
                        }
                        font.family: Icons.font
                        font.pixelSize: 18
                        color: root.osdMuted
                            ? Colors.outline
                            : (Styling.srItem("overprimary") ?? Colors.primary)
                        Behavior on color { ColorAnimation { duration: 200 } }

                        rotation: GlobalStates.osdIndicator === "brightness" ? (root.osdValue * 270) : 0
                        scale: {
                            if (GlobalStates.osdIndicator === "brightness")
                                return 0.75 + root.osdValue * 0.35;
                            return root.osdMuted ? 0.85 : 1.0;
                        }
                        Behavior on rotation {
                            NumberAnimation { duration: Config.animDuration ?? 200; easing.type: Easing.OutCubic }
                        }
                        Behavior on scale {
                            NumberAnimation { duration: 180; easing.type: Easing.OutBack; easing.overshoot: 2.5 }
                        }
                    }
                }

                // ── Label + bar ───────────────────────────────────────────────
                ColumnLayout {
                    spacing: 5
                    Layout.preferredWidth: 170

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 4

                        Text {
                            text: {
                                const ind = GlobalStates.osdIndicator;
                                if (ind === "volume")     return root.osdMuted ? "Muted" : "Volume";
                                if (ind === "mic")        return root.osdMuted ? "Mic Muted" : "Microphone";
                                if (ind === "brightness") return "Brightness";
                                return "";
                            }
                            font.family: Config.theme.font
                            font.pixelSize: 13
                            font.weight: Font.Medium
                            color: Colors.overBackground
                            opacity: 0.7
                            Layout.fillWidth: true
                        }

                        Text {
                            text: root.osdMuted && GlobalStates.osdIndicator !== "brightness"
                                ? "—"
                                : (Math.round(root.osdValue * 100) + "%")
                            font.family: Config.theme.font
                            font.pixelSize: 13
                            font.weight: Font.SemiBold
                            color: root.osdMuted
                                ? Colors.outline
                                : (Styling.srItem("overprimary") ?? Colors.primary)
                            Behavior on color { ColorAnimation { duration: 200 } }
                        }
                    }

                    // Progress track
                    Item {
                        Layout.fillWidth: true
                        height: 5

                        Rectangle {
                            anchors.fill: parent
                            radius: 3
                            color: Qt.rgba(Colors.overBackground.r, Colors.overBackground.g, Colors.overBackground.b, 0.12)
                        }

                        Rectangle {
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            width: Math.max(height, parent.width * Math.max(0, Math.min(1, root.osdValue)))
                            height: 5
                            radius: 3
                            color: root.osdMuted
                                ? Colors.outline
                                : (Styling.srItem("overprimary") ?? Colors.primary)
                            Behavior on width {
                                NumberAnimation {
                                    duration: Math.round((Config.animDuration ?? 200) * 0.6)
                                    easing.type: Easing.OutCubic
                                }
                            }
                            Behavior on color { ColorAnimation { duration: 200 } }
                        }

                        // Thumb dot
                        Rectangle {
                            anchors.verticalCenter: parent.verticalCenter
                            x: Math.max(0, Math.min(parent.width - width, parent.width * Math.max(0, Math.min(1, root.osdValue)) - width / 2))
                            width: 9; height: 9; radius: 5
                            color: root.osdMuted ? Colors.outline : "#ffffff"
                            opacity: 0.9
                            Behavior on x {
                                NumberAnimation {
                                    duration: Math.round((Config.animDuration ?? 200) * 0.6)
                                    easing.type: Easing.OutCubic
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onEntered: {
            hideTimer.stop();
            GlobalStates.osdVisible = false;
        }
    }

    Timer {
        id: hideTimer
        interval: 2200
        onTriggered: GlobalStates.osdVisible = false
    }

    Connections {
        target: GlobalStates
        function onOsdVisibleChanged() {
            if (GlobalStates.osdVisible) hideTimer.restart();
        }
    }

    Connections {
        target: Audio
        function onVolumeChanged(volume, muted, node) {
            root.osdValue = volume;
            root.osdMuted = muted;
            GlobalStates.osdIndicator = "volume";
            GlobalStates.osdVisible = true;
            hideTimer.restart();
        }
        function onMicVolumeChanged(volume, muted, node) {
            root.osdValue = volume;
            root.osdMuted = muted;
            GlobalStates.osdIndicator = "mic";
            GlobalStates.osdVisible = true;
            hideTimer.restart();
        }
    }

    Connections {
        target: Brightness
        function onBrightnessChanged(value, screen) {
            if (!screen || !root.targetScreen || screen.name === root.targetScreen.name || Brightness.syncBrightness) {
                root.osdValue = value;
                root.osdMuted = false;
                GlobalStates.osdIndicator = "brightness";
                GlobalStates.osdVisible = true;
                hideTimer.restart();
            }
        }
    }
}
