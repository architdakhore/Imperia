import QtQuick
import QtQuick.Layouts
import Quickshell.Services.SystemTray
import qs.modules.theme
import qs.modules.components

    StyledRect {
    variant: "bg"
    id: root

    // Hide when no tray items
    visible: hasItems

    topLeftRadius: root.vertical ? root.startRadius : root.startRadius
    topRightRadius: root.vertical ? root.startRadius : root.endRadius
    bottomLeftRadius: root.vertical ? root.endRadius : root.startRadius
    bottomRightRadius: root.vertical ? root.endRadius : root.endRadius

    required property var bar
    
    property real radius: 0
    property real startRadius: radius
    property real endRadius: radius

    // Orientación derivada de la barra
    property bool vertical: bar.orientation === "vertical"

    // ── Filter list: icon IDs/titles to exclude from systray ─────────────────
    // Add any app names here to hide them from the bar systray.
    readonly property var blocklist: [
        "bluetooth", "blueman", "bluez",
        "network", "ethernet", "nm-", "networkmanager", "wired",
        "nightlight", "night-light", "night_light",
        "caffeine",
        "powerprofiles", "power-profiles",
        "leaf", "cactus",
        "camera", "screenshot", "flameshot", "spectacle", "grimshot", "grim",
        "gnome-screenshot", "xfce4-screenshooter", "shutter"
    ]

    function isBlocked(item) {
        if (!item) return false;
        const title = (item.title || "").toLowerCase();
        const id    = (item.id    || "").toLowerCase();
        const icon  = (item.icon  || "").toString().toLowerCase();
        for (let b of blocklist) {
            if (title.includes(b) || id.includes(b) || icon.includes(b))
                return true;
        }
        return false;
    }

    // Hide completely when empty - check both orientations
    readonly property bool hasItems: rowRepeater.count > 0 || columnRepeater.count > 0

    // Ajustes de tamaño dinámicos según orientación
    height: vertical ? implicitHeight : parent.height
    Layout.preferredWidth: hasItems ? ((vertical ? columnLayout.implicitWidth : rowLayout.implicitWidth) + 16) : 0
    implicitWidth: hasItems ? ((vertical ? columnLayout.implicitWidth : rowLayout.implicitWidth) + 16) : 0
    implicitHeight: hasItems ? ((vertical ? columnLayout.implicitHeight : rowLayout.implicitHeight) + 16) : 0

    RowLayout {
        id: rowLayout
        visible: !root.vertical
        anchors.fill: parent
        anchors.margins: 8
        spacing: 8

        Repeater {
            id: rowRepeater
            model: SystemTray.items

            SysTrayItem {
                required property SystemTrayItem modelData
                bar: root.bar
                item: modelData
                visible: !root.isBlocked(modelData)
                Layout.preferredWidth: visible ? implicitWidth : 0
            }
        }
    }

    ColumnLayout {
        id: columnLayout
        visible: root.vertical
        anchors.fill: parent
        anchors.margins: 8
        spacing: 8

        Repeater {
            id: columnRepeater
            model: SystemTray.items

            SysTrayItem {
                required property SystemTrayItem modelData
                bar: root.bar
                item: modelData
                visible: !root.isBlocked(modelData)
                Layout.preferredHeight: visible ? implicitHeight : 0
            }
        }
    }
}
