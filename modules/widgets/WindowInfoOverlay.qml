pragma ComponentBehavior: Bound
// ─────────────────────────────────────────────────────────────────────────────
// WindowInfoOverlay.qml — Imperia Shell
// Caelestia-style active window info chip in the bar.
// Shows: App icon + window title + class.
// ─────────────────────────────────────────────────────────────────────────────
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import qs.modules.theme
import qs.modules.components
import qs.config

Item {
    id: root

    property string windowTitle: ""
    property string windowClass: ""
    property string windowIcon: ""

    implicitWidth: visible ? chipRow.implicitWidth + 24 : 0
    implicitHeight: 34

    Behavior on implicitWidth { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }

    // Track active window
    Connections {
        target: HyprlandActiveWindow
        function onChanged() {
            var win = HyprlandActiveWindow;
            root.windowTitle = win?.title ?? "";
            root.windowClass = win?.class ?? "";
            root.windowIcon = (win?.class ?? "").toLowerCase();
        }
    }

    visible: windowTitle.length > 0

    StyledRect {
        anchors.fill: parent
        variant: "surface"
        radius: 12

        RowLayout {
            id: chipRow
            anchors.centerIn: parent
            spacing: 6
            anchors.leftMargin: 12
            anchors.rightMargin: 12

            // App icon
            Image {
                Layout.preferredWidth: 18
                Layout.preferredHeight: 18
                fillMode: Image.PreserveAspectFit
                mipmap: true
                source: root.windowIcon ? "image://icon/" + root.windowIcon : ""
                visible: status === Image.Ready
            }

            // Title (truncated)
            Text {
                text: root.windowTitle.length > 40
                    ? root.windowTitle.substring(0, 37) + "…"
                    : root.windowTitle
                font.family: Config.theme.font
                font.pixelSize: 12
                color: Colors.overBackground
                Layout.maximumWidth: 280
                elide: Text.ElideRight
            }
        }
    }
}
