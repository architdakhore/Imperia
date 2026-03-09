pragma ComponentBehavior: Bound
// ─────────────────────────────────────────────────────────────────────────────
// HoverGlow.qml — Imperia Shell
// DankMaterial-inspired ambient glow effect for hovered elements.
// Adds a soft colored glow behind items when hovered.
// Usage: Add as a sibling BEHIND the item you want to glow.
// ─────────────────────────────────────────────────────────────────────────────
import QtQuick
import QtQuick.Effects
import qs.modules.theme
import qs.config

Item {
    id: root
    anchors.fill: parent

    property bool active: false
    property color glowColor: Colors.primary
    property real glowRadius: 12
    property real glowOpacity: 0.35

    // Soft glow using MultiEffect blur
    Rectangle {
        anchors.centerIn: parent
        width: parent.width + root.glowRadius * 2
        height: parent.height + root.glowRadius * 2
        radius: width / 2
        color: Qt.alpha(root.glowColor, root.active ? root.glowOpacity : 0)
        visible: root.active

        Behavior on color {
            ColorAnimation { duration: (Config.animDuration ?? 200) / 2 }
        }

        layer.enabled: true
        layer.effect: MultiEffect {
            blurEnabled: true
            blur: 0.8
            blurMax: 32
        }
    }
}
