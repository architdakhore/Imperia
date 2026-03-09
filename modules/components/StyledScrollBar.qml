// ─────────────────────────────────────────────────────────────────────────────
// StyledScrollBar.qml — Imperia Shell
// Auto-hiding pill scrollbar — fades in on scroll/hover, fades out when idle.
// Styled to match the user's own scrollbar from their WidgetPanel.
// ─────────────────────────────────────────────────────────────────────────────
import QtQuick
import QtQuick.Controls
import qs.modules.theme
import qs.config

ScrollBar {
    id: root

    // The Flickable this scrollbar controls (required)
    required property Flickable flickable

    property bool _active: false

    // Bind position and size to flickable's visible area
    position: flickable.visibleArea.yPosition
    size: flickable.visibleArea.heightRatio

    orientation: Qt.Vertical
    interactive: true
    visible: flickable.contentHeight > flickable.height

    // ── Auto show/hide ────────────────────────────────────────────────────────
    opacity: (_active || hovered || flickable.moving) ? 1.0 : 0.0

    Behavior on opacity {
        NumberAnimation {
            duration: (Config.animDuration ?? 250) * (root.opacity > 0 ? 0.4 : 1.5)
        }
    }

    Timer {
        id: idleTimer
        interval: 900
        onTriggered: root._active = false
    }

    onPositionChanged: {
        root._active = true;
        idleTimer.restart();
    }

    // ── Visual ────────────────────────────────────────────────────────────────
    contentItem: Rectangle {
        implicitWidth: 4
        implicitHeight: 60
        radius: width / 2
        color: Colors.primary
        opacity: root.pressed ? 1.0 : (root.hovered ? 0.9 : 0.7)
        Behavior on opacity { NumberAnimation { duration: 100 } }
    }

    background: Rectangle {
        implicitWidth: 4
        radius: width / 2
        color: Qt.rgba(
            Colors.overBackground.r,
            Colors.overBackground.g,
            Colors.overBackground.b,
            0.07
        )
        opacity: root.hovered ? 1.0 : 0.0
        Behavior on opacity { NumberAnimation { duration: 150 } }
    }
}
