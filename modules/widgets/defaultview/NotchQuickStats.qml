// NotchQuickStats.qml — Imperia Shell
// Caelestia-style system stats row that smoothly animates in on notch hover.
import QtQuick
import QtQuick.Layouts
import qs.modules.theme
import qs.modules.services
import qs.config

Item {
    id: root
    property bool visible_: false
    implicitHeight: visible_ ? content.implicitHeight + 10 : 0
    implicitWidth: content.implicitWidth + 24

    opacity: visible_ ? 1.0 : 0.0
    clip: true

    Behavior on implicitHeight {
        enabled: Config.animDuration > 0
        NumberAnimation { duration: Config.animDuration; easing.type: Easing.OutCubic }
    }
    Behavior on opacity {
        enabled: Config.animDuration > 0
        NumberAnimation { duration: Config.animDuration * 0.6; easing.type: Easing.OutCubic }
    }

    Row {
        id: content
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        spacing: 14

        // CPU
        Stat {
            iconText: Icons.cpu
            valueText: Math.round(SystemResources.cpuUsage) + "%"
            warnLevel: SystemResources.cpuUsage > 80 ? 2 : (SystemResources.cpuUsage > 50 ? 1 : 0)
        }

        Divider {}

        // RAM
        Stat {
            iconText: Icons.ram
            valueText: Math.round(SystemResources.ramUsage) + "%"
            warnLevel: SystemResources.ramUsage > 85 ? 2 : (SystemResources.ramUsage > 65 ? 1 : 0)
        }

        // CPU Temp if available
        Divider { visible: SystemResources.cpuTemp > 0 }

        Stat {
            visible: SystemResources.cpuTemp > 0
            iconText: Icons.thermometer
            valueText: SystemResources.cpuTemp + "°"
            warnLevel: SystemResources.cpuTemp > 85 ? 2 : (SystemResources.cpuTemp > 70 ? 1 : 0)
        }
    }

    // ── Sub-components ───────────────────────────────────────────────────────
    component Stat: Row {
        property string iconText: ""
        property string valueText: ""
        property int warnLevel: 0   // 0=normal, 1=warn, 2=danger

        readonly property color statColor: warnLevel === 2 ? "#ff6b6b" : (warnLevel === 1 ? "#ffd93d" : Colors.overBackground)

        spacing: 4
        anchors.verticalCenter: parent?.verticalCenter

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: parent.iconText
            font.family: Icons.font
            font.pixelSize: 10
            color: parent.statColor
            opacity: 0.7
            Behavior on color { ColorAnimation { duration: 400 } }
        }
        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: parent.valueText
            color: parent.statColor
            font.family: Config.theme.font
            font.pixelSize: Styling.fontSize(-1)
            font.weight: Font.SemiBold
            Behavior on color { ColorAnimation { duration: 400 } }
        }
    }

    component Divider: Rectangle {
        anchors.verticalCenter: parent?.verticalCenter
        width: 1; height: 10
        color: Qt.rgba(Colors.overBackground.r, Colors.overBackground.g, Colors.overBackground.b, 0.2)
    }
}
