// ─────────────────────────────────────────────────────────────────────────────
// RightEdgeOSD.qml  —  Imperia Shell
// Pixel-perfect port of the OSD from the user's WidgetPanel.qml
// Two vertical sliders: Brightness (left) + Volume (right)
// Night-light toggle on brightness icon, mute toggle on volume icon
// Uses Imperia's Brightness service + Pipewire + NightLightService
// ─────────────────────────────────────────────────────────────────────────────
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Pipewire
import Qt5Compat.GraphicalEffects
import qs.modules.services
import qs.modules.globals
import qs.config

PanelWindow {
    id: root

    // ── Required ─────────────────────────────────────────────────────────────
    required property ShellScreen targetScreen
    screen: targetScreen

    // ── State ─────────────────────────────────────────────────────────────────
    property bool shouldShowOsd: false
    property bool isDragging: false
    property bool isBooting: true

    // Pipewire sink (same as WidgetPanel)
    property var sink: Pipewire.defaultAudioSink

    // Brightness monitor for this screen
    property var brightnessMon: Brightness.monitors?.find(m => m.screen?.name === targetScreen?.name) ?? Brightness.monitors?.[0]

    // Convenience: brightness as 0–1 fraction
    property real brightnessValue: brightnessMon?.brightness ?? 0
    property int  rawMax:          brightnessMon?.rawMaxBrightness ?? 100

    // ── Boot guard (2 s) — same as WidgetPanel ────────────────────────────────
    Timer {
        interval: 2000; running: true
        onTriggered: root.isBooting = false
    }

    // ── OSD trigger / hide — exact WidgetPanel logic ──────────────────────────
    function triggerOsd() {
        if (!root.isBooting) {
            root.shouldShowOsd = true;
            osdHideTimer.restart();
        }
    }

    Timer {
        id: osdHideTimer
        interval: 750
        onTriggered: {
            if (!osdMainMouseArea.containsMouse && !root.isDragging) {
                root.shouldShowOsd = false;
            } else {
                osdHideTimer.restart();
            }
        }
    }

    // ── Brightness change → trigger OSD ──────────────────────────────────────
    Connections {
        target: Brightness
        function onBrightnessChanged(value, screen) {
            if (!screen || !root.targetScreen || screen.name === root.targetScreen.name || Brightness.syncBrightness) {
                root.triggerOsd();
            }
        }
    }

    // ── Volume/mute change → trigger OSD ─────────────────────────────────────
    PwObjectTracker { objects: [Pipewire.defaultAudioSink] }

    Connections {
        target: Pipewire.defaultAudioSink?.audio
        ignoreUnknownSignals: true
        function onVolumeChanged() { root.triggerOsd(); }
        function onMutedChanged()  { root.triggerOsd(); }
    }

    // ── PanelWindow settings — exact from WidgetPanel ────────────────────────
    visible: true
    color: "transparent"
    mask: Region { item: osdContainer }

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "osd-overlay"
    WlrLayershell.exclusiveZone: 0

    anchors.right: true
    // slide in from right: -1.5 = visible (tiny gap), -178.5 = hidden off-screen
    margins.right: (root.shouldShowOsd || osdMainMouseArea.containsMouse) ? 0 : -185
    Behavior on margins.right {
        NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
    }

    implicitWidth:  185
    implicitHeight: 270

    // ── OSD Container — exact copy ────────────────────────────────────────────
    Rectangle {
        id: osdContainer
        anchors.fill: parent
        color: "#000000"

        layer.enabled: true
        layer.effect: OpacityMask {
            maskSource: Rectangle {
                width: osdContainer.width
                height: osdContainer.height
                radius: 15
                // Flatten the right side so it butts against the screen edge
                Rectangle {
                    anchors.right: parent.right
                    anchors.top:   parent.top
                    anchors.bottom: parent.bottom
                    width: 20
                    color: "black"
                }
            }
        }

        // ── Two-column layout ─────────────────────────────────────────────────
        RowLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 15

            // ── LEFT column: Brightness ───────────────────────────────────────
            ColumnLayout {
                Layout.fillHeight: true
                Layout.preferredWidth: 60
                spacing: 12

                // Percentage label
                Item {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 20
                    Text {
                        id: osdBrightText
                        text: Math.round(root.brightnessValue * 100)
                        font.pixelSize: 12
                        font.weight: Font.Bold
                        anchors.centerIn: parent
                        visible: false
                    }
                    LinearGradient {
                        anchors.fill: osdBrightText
                        source: ShaderEffectSource { sourceItem: osdBrightText; hideSource: true }
                        gradient: Gradient {
                            GradientStop { position: 0.0; color: "white" }
                            GradientStop { position: 1.0; color: "white" }
                        }
                    }
                }

                // Slider track
                Rectangle {
                    Layout.fillHeight: true
                    Layout.preferredWidth: 60
                    Layout.alignment: Qt.AlignHCenter
                    radius: 15
                    color: Qt.rgba(1, 1, 1, 0.08)

                    // Fill
                    Rectangle {
                        anchors.bottom: parent.bottom
                        width: parent.width
                        radius: 15
                        height: parent.height * Math.min(1.0, root.brightnessValue)
                        gradient: Gradient {
                            GradientStop { position: 0.0; color: "white" }
                            GradientStop { position: 1.0; color: "white" }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onPressed: mouse => {
                            root.isDragging = true;
                            let v = 1 - (mouse.y / height);
                            root.brightnessMon?.setBrightness(Math.max(0.01, Math.min(1.0, v)));
                        }
                        onPositionChanged: mouse => {
                            if (pressed) {
                                let v = 1 - (mouse.y / height);
                                root.brightnessMon?.setBrightness(Math.max(0.01, Math.min(1.0, v)));
                            }
                        }
                        onReleased: root.isDragging = false
                        onWheel: wheel => {
                            let step = 0.01;
                            let cur  = root.brightnessValue;
                            root.brightnessMon?.setBrightness(Math.max(0.01, Math.min(1.0, cur + (wheel.angleDelta.y > 0 ? step : -step))));
                        }
                    }
                }

                // Icon — sun / night-light, click to toggle
                Item {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 35
                    Text {
                        id: osdBIcon
                        anchors.centerIn: parent
                        font.pixelSize: 22
                        visible: false
                        text: NightLightService.active ? "󰽥" : "󰖨"
                    }
                    LinearGradient {
                        anchors.fill: osdBIcon
                        source: ShaderEffectSource { sourceItem: osdBIcon; hideSource: true }
                        gradient: Gradient {
                            GradientStop { position: 0.0; color: "white" }
                            GradientStop { position: 1.0; color: "white" }
                        }
                    }
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: NightLightService.toggle()
                    }
                }
            }

            // ── RIGHT column: Volume ──────────────────────────────────────────
            ColumnLayout {
                Layout.fillHeight: true
                Layout.preferredWidth: 60
                spacing: 12

                // Percentage label
                Item {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 20
                    Text {
                        id: osdVolText
                        text: Math.round((root.sink?.audio?.volume ?? 0) * 100)
                        font.pixelSize: 12
                        font.weight: Font.Bold
                        anchors.centerIn: parent
                        visible: false
                    }
                    LinearGradient {
                        anchors.fill: osdVolText
                        source: ShaderEffectSource { sourceItem: osdVolText; hideSource: true }
                        gradient: Gradient {
                            GradientStop { position: 0.0; color: "white" }
                            GradientStop { position: 1.0; color: "white" }
                        }
                    }
                }

                // Slider track
                Rectangle {
                    Layout.fillHeight: true
                    Layout.preferredWidth: 60
                    Layout.alignment: Qt.AlignHCenter
                    radius: 15
                    color: Qt.rgba(1, 1, 1, 0.08)

                    // Fill
                    Rectangle {
                        anchors.bottom: parent.bottom
                        width: parent.width
                        radius: 15
                        height: parent.height * Math.min(1.0, root.sink?.audio?.volume ?? 0)
                        gradient: Gradient {
                            GradientStop { position: 0.0; color: "white" }
                            GradientStop { position: 1.0; color: "white" }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onPressed: mouse => {
                            if (root.sink?.audio) {
                                root.isDragging = true;
                                root.sink.audio.volume = Math.max(0, Math.min(1.0, 1 - (mouse.y / height)));
                            }
                        }
                        onPositionChanged: mouse => {
                            if (pressed && root.sink?.audio) {
                                root.sink.audio.volume = Math.max(0, Math.min(1.0, 1 - (mouse.y / height)));
                            }
                        }
                        onReleased: root.isDragging = false
                        onWheel: wheel => {
                            if (root.sink?.audio) {
                                let step = 0.01;
                                root.sink.audio.volume = Math.max(0, Math.min(1.0, root.sink.audio.volume + (wheel.angleDelta.y > 0 ? step : -step)));
                            }
                        }
                    }
                }

                // Icon — speaker / muted, click to toggle mute
                Item {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 35
                    Text {
                        id: osdVIcon
                        anchors.centerIn: parent
                        font.pixelSize: 22
                        visible: false
                        text: root.sink?.audio?.muted ? "󰖁" : "󰕾"
                    }
                    LinearGradient {
                        anchors.fill: osdVIcon
                        source: ShaderEffectSource { sourceItem: osdVIcon; hideSource: true }
                        gradient: Gradient {
                            GradientStop { position: 0.0; color: "white" }
                            GradientStop { position: 1.0; color: "white" }
                        }
                    }
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: if (root.sink?.audio) root.sink.audio.muted = !root.sink.audio.muted
                    }
                }
            }
        }

        // ── Hover keep-alive (exact WidgetPanel logic) ────────────────────────
        MouseArea {
            id: osdMainMouseArea
            anchors.fill: parent
            hoverEnabled: true
            propagateComposedEvents: true
            onEntered: {
                osdHideTimer.stop();
                root.shouldShowOsd = true;
            }
            onExited: {
                if (!root.isDragging) osdHideTimer.restart();
            }
            onPressed: mouse => mouse.accepted = false
        }
    }
}

