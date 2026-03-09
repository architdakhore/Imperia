pragma ComponentBehavior: Bound

// ─────────────────────────────────────────────────────────────────────────────
// CaelestiaHoverLayer.qml — Imperia
// Caelestia-style Material ripple hover layer for interactive elements.
// Drop this over any clickable Item to get hover + ripple effects.
// ─────────────────────────────────────────────────────────────────────────────
import QtQuick
import qs.modules.theme
import qs.config

MouseArea {
    id: root

    property bool disabled: false
    property bool showHoverBg: true
    property color rippleColor: Colors.overBackground
    property real radius: parent?.radius ?? Styling.radius(0)
    property real hoverOpacity: 0.08
    property real pressOpacity: 0.15

    signal activated()

    anchors.fill: parent
    enabled: !disabled
    cursorShape: disabled ? undefined : Qt.PointingHandCursor
    hoverEnabled: true

    onPressed: event => {
        if (disabled) return;
        rippleItem.x = event.x;
        rippleItem.y = event.y;
        const d = (ox, oy) => ox * ox + oy * oy;
        rippleItem.implicitRadius = Math.sqrt(
            Math.max(
                d(event.x, event.y),
                d(event.x, height - event.y),
                d(width - event.x, event.y),
                d(width - event.x, height - event.y)
            )
        );
        rippleAnim.restart();
    }

    onClicked: if (!disabled) root.activated()

    // ── Hover + press background ──────────────────────────────────────────────
    Rectangle {
        id: hoverBg
        anchors.fill: parent
        radius: root.radius
        color: Qt.alpha(root.rippleColor,
            root.disabled ? 0 :
            root.pressed ? root.pressOpacity :
            (root.showHoverBg && root.containsMouse) ? root.hoverOpacity : 0
        )
        clip: true

        Behavior on color {
            ColorAnimation { duration: Config.animDuration / 3; easing.type: Easing.OutCubic }
        }

        // ── Ripple ────────────────────────────────────────────────────────────
        Item {
            id: rippleItem
            property real implicitRadius: 0
            width: implicitWidth
            height: implicitHeight
            implicitWidth: 0
            implicitHeight: 0
            opacity: 0

            transform: Translate {
                x: -rippleItem.width / 2
                y: -rippleItem.height / 2
            }

            Rectangle {
                anchors.fill: parent
                radius: Math.max(width, height) / 2
                color: Qt.alpha(root.rippleColor, 0.3)
            }
        }

        SequentialAnimation {
            id: rippleAnim
            PropertyAction { target: rippleItem; property: "implicitWidth";  value: 0 }
            PropertyAction { target: rippleItem; property: "implicitHeight"; value: 0 }
            PropertyAction { target: rippleItem; property: "opacity"; value: 0.9 }
            ParallelAnimation {
                NumberAnimation {
                    target: rippleItem; property: "implicitWidth"
                    from: 0; to: rippleItem.implicitRadius * 2
                    duration: Config.animDuration; easing.type: Easing.OutQuart
                }
                NumberAnimation {
                    target: rippleItem; property: "implicitHeight"
                    from: 0; to: rippleItem.implicitRadius * 2
                    duration: Config.animDuration; easing.type: Easing.OutQuart
                }
            }
            NumberAnimation {
                target: rippleItem; property: "opacity"
                to: 0; duration: Config.animDuration / 2; easing.type: Easing.OutCubic
            }
        }
    }
}
