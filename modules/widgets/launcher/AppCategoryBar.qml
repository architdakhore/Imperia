pragma ComponentBehavior: Bound

// ─────────────────────────────────────────────────────────────────────────────
// AppCategoryBar.qml — Imperia Shell
// Imperia + Imperia-inspired category filter bar for the launcher.
// Filters the app list by .desktop Categories field.
// ─────────────────────────────────────────────────────────────────────────────
import QtQuick
import QtQuick.Layouts
import qs.modules.theme
import qs.modules.components
import qs.config

Item {
    id: root
    implicitHeight: 40
    implicitWidth: row.implicitWidth

    property string selectedCategory: "All"
    signal categoryChanged(string category)

    readonly property var categories: [
        { id: "All",            icon: "\uf009",   label: "All" },         // fa-th
        { id: "Development",    icon: "\uf121",   label: "Dev" },         // fa-code
        { id: "Network",        icon: "\uf0ac",   label: "Web" },         // fa-globe
        { id: "Graphics",       icon: "\uf1fc",   label: "Art" },         // fa-paint-brush
        { id: "Game",           icon: "\uf11b",   label: "Games" },       // fa-gamepad
        { id: "AudioVideo",     icon: "\uf001",   label: "Media" },       // fa-music
        { id: "Office",         icon: "\uf15c",   label: "Office" },      // fa-file-text
        { id: "System",         icon: "\uf013",   label: "System" },      // fa-gear
        { id: "Utility",        icon: "\uf0ad",   label: "Tools" },       // fa-wrench
        { id: "Science",        icon: "\uf0c3",   label: "Science" },     // fa-flask
        { id: "Education",      icon: "\uf19d",   label: "Edu" },         // fa-graduation-cap
    ]

    Row {
        id: row
        anchors.fill: parent
        spacing: 4

        Repeater {
            model: root.categories
            delegate: Item {
                required property var modelData
                property bool isSelected: root.selectedCategory === modelData.id
                height: parent.height
                width: chip.implicitWidth

                Rectangle {
                    id: chip
                    height: 30
                    anchors.verticalCenter: parent.verticalCenter
                    implicitWidth: chipRow.implicitWidth + 18
                    radius: height / 2

                    color: isSelected
                        ? Colors.primary
                        : (chipHover.hovered ? Colors.surfaceBright : "transparent")

                    Behavior on color { ColorAnimation { duration: 150 } }

                    Row {
                        id: chipRow
                        anchors.centerIn: parent
                        spacing: 5

                        Text {
                            text: modelData.icon
                            font.family: "Font Awesome 6 Free"
                            font.pixelSize: 11
                            color: isSelected ? Colors.overPrimary : Colors.outline
                            anchors.verticalCenter: parent.verticalCenter
                            Behavior on color { ColorAnimation { duration: 150 } }
                        }

                        Text {
                            text: modelData.label
                            font.family: Config.theme.font
                            font.pixelSize: 12
                            color: isSelected ? Colors.overPrimary : Colors.overBackground
                            anchors.verticalCenter: parent.verticalCenter
                            Behavior on color { ColorAnimation { duration: 150 } }
                        }
                    }

                    HoverHandler { id: chipHover }
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            root.selectedCategory = modelData.id;
                            root.categoryChanged(modelData.id);
                        }
                    }
                }
            }
        }
    }
}
