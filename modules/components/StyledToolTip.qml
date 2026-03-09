pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import qs.config
import qs.modules.theme
import qs.modules.components

// ─────────────────────────────────────────────────────────────────────────────
// StyledToolTip — Imperia Shell (Enhanced)
// DankMaterial-inspired floating tooltip with smooth scale + fade animation.
// ─────────────────────────────────────────────────────────────────────────────
ToolTip {
    id: root
    property string tooltipText: ""
    property bool show: false

    text: tooltipText
    delay: 700
    timeout: -1
    visible: show && tooltipText.length > 0

    enter: Transition {
        ParallelAnimation {
            NumberAnimation {
                property: "opacity"
                from: 0; to: 1
                duration: (Config.animDuration ?? 200) / 2
                easing.type: Easing.OutCubic
            }
            NumberAnimation {
                property: "scale"
                from: 0.88; to: 1.0
                duration: (Config.animDuration ?? 200) / 2
                easing.type: Easing.OutBack
                easing.overshoot: 1.2
            }
        }
    }

    exit: Transition {
        NumberAnimation {
            property: "opacity"
            from: 1; to: 0
            duration: (Config.animDuration ?? 200) / 3
            easing.type: Easing.InCubic
        }
    }

    background: Rectangle {
        color: Colors.surfaceContainer
        radius: Styling.radius(-2)
        border.color: Qt.alpha(Colors.outline, 0.2)
        border.width: 1

        layer.enabled: true
        layer.effect: MultiEffect {
            shadowEnabled: true
            shadowColor: Qt.rgba(0, 0, 0, 0.35)
            shadowBlur: 0.6
            shadowVerticalOffset: 3
            shadowHorizontalOffset: 0
        }
    }

    contentItem: Text {
        text: root.tooltipText
        color: Colors.overBackground
        font.pixelSize: Config.theme.fontSize - 1
        font.weight: Font.Medium
        font.family: Config.theme.font
        leftPadding: 6
        rightPadding: 6
    }
}
