pragma ComponentBehavior: Bound

// ─────────────────────────────────────────────────────────────────────────────
// End4DotsIndicator.qml — Imperia
// End-4 / Imperia inspired 4-dot workspace indicator.
// Shows a 2×2 (or 1×4) grid of dots, each representing a workspace.
// Active workspace dot is larger and colored; occupied ones are small+filled.
// ─────────────────────────────────────────────────────────────────────────────
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import qs.modules.theme
import qs.modules.components
import qs.modules.services
import qs.config

Item {
    id: root

    required property var bar

    readonly property HyprlandMonitor monitor: Hyprland.monitorFor(bar.screen)
    readonly property int activeWsId: monitor?.activeWorkspace?.id ?? 1

    // 4-dot layout:
    // Dots 1-4 = workspaces 1-4 (or the current group of 4)
    readonly property int wsGroup: Math.floor((activeWsId - 1) / 4)
    readonly property int baseWs: wsGroup * 4 + 1   // first workspace in this group

    // Which workspaces have at least one window
    function isOccupied(wsId: int): bool {
        return !!HyprlandData.workspaceOccupationMap[wsId];
    }

    function isActive(wsId: int): bool {
        return wsId === activeWsId;
    }

    function switchTo(wsId: int) {
        Hyprland.dispatch(`workspace ${wsId}`);
    }

    implicitWidth:  layout.implicitWidth  + 8
    implicitHeight: layout.implicitHeight + 4

    // ── 2×2 dot grid ─────────────────────────────────────────────────────────
    GridLayout {
        id: layout
        anchors.centerIn: parent
        columns: 2
        rows: 2
        columnSpacing: 4
        rowSpacing: 4

        Repeater {
            model: 4

            delegate: Item {
                required property int index

                readonly property int wsId: root.baseWs + index
                readonly property bool active: root.isActive(wsId)
                readonly property bool occupied: root.isOccupied(wsId)

                implicitWidth:  active ? 14 : (occupied ? 8 : 6)
                implicitHeight: implicitWidth

                Behavior on implicitWidth {
                    NumberAnimation { duration: Config.animDuration / 2; easing.type: Easing.OutBack; easing.overshoot: 1.5 }
                }

                Rectangle {
                    anchors.centerIn: parent
                    width:  parent.implicitWidth
                    height: parent.implicitHeight
                    radius: width / 2
                    color: {
                        if (active)   return Colors.primary;
                        if (occupied) return Colors.overSurface;
                        return Colors.outline;
                    }
                    opacity: active ? 1.0 : (occupied ? 0.8 : 0.35)

                    Behavior on color {
                        ColorAnimation { duration: Config.animDuration / 2 }
                    }
                    Behavior on opacity {
                        NumberAnimation { duration: Config.animDuration / 2 }
                    }
                    Behavior on width {
                        NumberAnimation { duration: Config.animDuration / 2; easing.type: Easing.OutBack; easing.overshoot: 1.5 }
                    }
                    Behavior on height {
                        NumberAnimation { duration: Config.animDuration / 2; easing.type: Easing.OutBack; easing.overshoot: 1.5 }
                    }
                }

                // Click to switch workspace
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.switchTo(wsId)
                }

                // Hover expand
                HoverHandler { id: dotHover }
                scale: dotHover.hovered ? 1.25 : 1.0
                Behavior on scale {
                    NumberAnimation { duration: Config.animDuration / 3; easing.type: Easing.OutBack; easing.overshoot: 1.5 }
                }
            }
        }
    }
}
