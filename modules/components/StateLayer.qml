// ─────────────────────────────────────────────────────────────────────────────
// StateLayer.qml — Imperia Shell
// Material 3 state layer: hover highlight + ripple on click.
// Adapted from Imperia. Drop over any clickable Item.
// Usage:
//   Item {
//     StateLayer { onActivated: doSomething() }
//   }
// ─────────────────────────────────────────────────────────────────────────────
import QtQuick
import qs.modules.theme
import qs.config

MouseArea {
    id: root

    // ── Config ────────────────────────────────────────────────────────────────
    property bool disabled: false
    property bool showHoverBg: true
    property color rippleColor: Colors.overBackground
    property real radius: parent?.radius ?? Config.roundness

    signal activated()

    // ── Layout ────────────────────────────────────────────────────────────────
    anchors.fill: parent
    enabled: !disabled
    cursorShape: disabled ? undefined : Qt.PointingHandCursor
    hoverEnabled: true

    // ── Ripple trigger ────────────────────────────────────────────────────────
    onPressed: event => {
        if (disabled) return;
        rippleAnim.startX = event.x;
        rippleAnim.startY = event.y;
        var dx = Math.max(event.x, width - event.x);
        var dy = Math.max(event.y, height - event.y);
        rippleAnim.targetRadius = Math.sqrt(dx * dx + dy * dy) * 2;
        rippleAnim.restart();
    }

    onClicked: { if (!disabled) root.activated(); }

    // ── Hover + press background ──────────────────────────────────────────────
    Rectangle {
        id: hoverBg
        anchors.fill: parent
        radius: root.radius
        color: root.rippleColor
        opacity: root.disabled ? 0
               : root.pressed  ? 0.14
               : (root.showHoverBg && root.containsMouse) ? 0.07
               : 0
        Behavior on opacity { NumberAnimation { duration: 120 } }
    }

    // ── Ripple circle ─────────────────────────────────────────────────────────
    Rectangle {
        id: rippleDot
        color: root.rippleColor
        radius: width / 2
        opacity: 0
        width: 0; height: 0

        // Center-offset via transform so x,y is the click origin
        x: rippleAnim.startX - width / 2
        y: rippleAnim.startY - height / 2
    }

    SequentialAnimation {
        id: rippleAnim
        property real startX: 0
        property real startY: 0
        property real targetRadius: 100

        PropertyAction { target: rippleDot; property: "opacity"; value: 0.18 }
        ParallelAnimation {
            NumberAnimation {
                target: rippleDot
                properties: "width,height"
                from: 0
                to: rippleAnim.targetRadius
                duration: 380
                easing.type: Easing.OutCubic
            }
        }
        NumberAnimation {
            target: rippleDot
            property: "opacity"
            to: 0
            duration: 200
            easing.type: Easing.InCubic
        }
        PropertyAction { target: rippleDot; property: "width"; value: 0 }
        PropertyAction { target: rippleDot; property: "height"; value: 0 }
    }
}
