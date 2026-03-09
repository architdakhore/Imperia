pragma ComponentBehavior: Bound

// ─────────────────────────────────────────────────────────────────────────────
// QuickTilesPanel.qml — Imperia Shell
// Inspired by Imperia quick settings tiles — Android-style toggles
// for WiFi, Bluetooth, Night Light, Do Not Disturb, Game Mode, VPN.
// ─────────────────────────────────────────────────────────────────────────────
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell.Io
import qs.modules.theme
import qs.modules.components
import qs.modules.globals
import qs.modules.services
import qs.config

Item {
    id: root
    anchors.fill: parent

    // ── Tile model ────────────────────────────────────────────────────────────
    property var tiles: [
        {
            id: "wifi",
            label: "Wi-Fi",
            icon: Icons.wifiHigh,
            iconOff: Icons.wifiOff,
            activeColor: Colors.primary,
            getActive: function() { return Network ? (Network.state === "connected" || Network.wifiEnabled) : false; },
            toggle: function() {
                if (Network && Network.toggleWifi) Network.toggleWifi();
                else tileProc.run(["nmcli", "radio", "wifi", "toggle"]);
            }
        },
        {
            id: "bluetooth",
            label: "Bluetooth",
            icon: Icons.bluetoothConnected,
            iconOff: Icons.bluetoothOff,
            activeColor: "#2196F3",
            getActive: function() { return Bluetooth ? Bluetooth.enabled : false; },
            toggle: function() {
                tileProc.run(["bluetoothctl", "power", (Bluetooth && Bluetooth.enabled) ? "off" : "on"]);
            }
        },
        {
            id: "nightlight",
            label: "Night Light",
            icon: Icons.moon,
            iconOff: Icons.sun,
            activeColor: "#FF9800",
            getActive: function() { return GlobalStates.nightLightEnabled; },
            toggle: function() {
                GlobalStates.nightLightEnabled = !GlobalStates.nightLightEnabled;
            }
        },
        {
            id: "dnd",
            label: "Do Not Disturb",
            icon: Icons.bellSlash,
            iconOff: Icons.bell,
            activeColor: "#9C27B0",
            getActive: function() { return GlobalStates.doNotDisturbEnabled; },
            toggle: function() {
                GlobalStates.doNotDisturbEnabled = !GlobalStates.doNotDisturbEnabled;
            }
        },
        {
            id: "gamemode",
            label: "Game Mode",
            icon: Icons.gamepad,
            iconOff: Icons.gamepad,
            activeColor: "#F44336",
            getActive: function() { return GlobalStates.gameModeEnabled; },
            toggle: function() {
                GlobalStates.gameModeEnabled = !GlobalStates.gameModeEnabled;
                tileProc.run(["gamemoded", "-t", "30"]);
            }
        },
        {
            id: "caffeine",
            label: "Caffeine",
            icon: Icons.caffeine,
            iconOff: Icons.caffeine,
            activeColor: "#795548",
            getActive: function() { return GlobalStates.caffeineEnabled; },
            toggle: function() {
                GlobalStates.caffeineEnabled = !GlobalStates.caffeineEnabled;
            }
        },
        {
            id: "performance",
            label: "Performance",
            icon: Icons.performance,
            iconOff: Icons.balanced,
            activeColor: "#FF5722",
            getActive: function() { return GlobalStates.powerProfile === "performance"; },
            toggle: function() {
                var next = GlobalStates.powerProfile === "performance" ? "balanced" : "performance";
                GlobalStates.powerProfile = next;
                tileProc.run(["powerprofilesctl", "set", next]);
            }
        },
        {
            id: "airplane",
            label: "Airplane Mode",
            icon: Icons.paperPlane,
            iconOff: Icons.paperPlane,
            activeColor: "#607D8B",
            getActive: function() { return airplaneMode; },
            toggle: function() {
                airplaneMode = !airplaneMode;
                tileProc.run(["nmcli", "radio", "all", airplaneMode ? "off" : "on"]);
            }
        }
    ]

    property bool airplaneMode: false

    Process {
        id: tileProc
        function run(cmd) {
            command = cmd;
            running = false;
            running = true;
        }
    }

    // ── Refresh timer ─────────────────────────────────────────────────────────
    Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: tilesGrid.model = null, tilesGrid.model = root.tiles
    }

    ScrollView {
        anchors.fill: parent
        anchors.margins: 16
        contentWidth: availableWidth

        ColumnLayout {
            width: parent.width
            spacing: 20

            Text {
                text: "Quick Settings"
                font.family: Config.theme.font
                font.pixelSize: Config.theme.fontSize + 2
                font.weight: Font.DemiBold
                color: Colors.overBackground
            }

            // ── Tiles grid ────────────────────────────────────────────────────
            GridLayout {
                id: tilesGrid
                Layout.fillWidth: true
                columns: 4
                rowSpacing: 10
                columnSpacing: 10
                model: root.tiles

                Repeater {
                    model: root.tiles
                    delegate: Item {
                        required property var modelData
                        Layout.fillWidth: true
                        height: 80

                        property bool isActive: modelData.getActive()

                        StyledRect {
                            anchors.fill: parent
                            radius: Config.roundness + 2
                            variant: "surface"

                            Rectangle {
                                anchors.fill: parent
                                radius: parent.radius
                                color: parent.parent.isActive ? modelData.activeColor : "transparent"
                                opacity: parent.parent.isActive ? 0.18 : 0
                                Behavior on opacity { NumberAnimation { duration: 200 } }
                            }

                            Rectangle {
                                anchors.fill: parent
                                radius: parent.radius
                                color: tileHover.hovered ? Colors.surfaceBright : "transparent"
                                opacity: tileHover.hovered && !parent.parent.isActive ? 0.5 : 0
                                Behavior on opacity { NumberAnimation { duration: 150 } }
                            }

                            ColumnLayout {
                                anchors.centerIn: parent
                                spacing: 6

                                // Pill icon container
                                Rectangle {
                                    Layout.alignment: Qt.AlignHCenter
                                    width: 44; height: 28
                                    radius: 14
                                    color: parent.parent.parent.parent.isActive
                                        ? modelData.activeColor
                                        : Colors.surfaceBright

                                    Behavior on color { ColorAnimation { duration: 200 } }

                                    Text {
                                        anchors.centerIn: parent
                                        text: parent.parent.parent.parent.parent.isActive
                                            ? modelData.icon
                                            : (modelData.iconOff || modelData.icon)
                                        font.family: Icons.font
                                        font.pixelSize: 16
                                        color: parent.parent.parent.parent.isActive
                                            ? "#ffffff"
                                            : Colors.outline
                                        Behavior on color { ColorAnimation { duration: 200 } }
                                    }
                                }

                                Text {
                                    Layout.alignment: Qt.AlignHCenter
                                    text: modelData.label
                                    font.family: Config.theme.font
                                    font.pixelSize: 11
                                    color: parent.parent.parent.isActive
                                        ? Colors.overBackground
                                        : Colors.outline
                                    horizontalAlignment: Text.AlignHCenter
                                }
                            }

                            HoverHandler { id: tileHover }
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    modelData.toggle();
                                    parent.parent.isActive = modelData.getActive();
                                }
                            }

                            // Active indicator dot
                            Rectangle {
                                anchors.top: parent.top
                                anchors.right: parent.right
                                anchors.margins: 6
                                width: 6; height: 6
                                radius: 3
                                color: modelData.activeColor
                                visible: parent.parent.isActive
                                Behavior on visible { NumberAnimation { duration: 150 } }
                            }
                        }
                    }
                }
            }

            // ── Brightness + Volume quick sliders ─────────────────────────────
            Text {
                text: "Quick Controls"
                font.family: Config.theme.font
                font.pixelSize: Config.theme.fontSize + 2
                font.weight: Font.DemiBold
                color: Colors.overBackground
            }

            Repeater {
                model: [
                    { label: "Brightness", icon: Icons.sun, getVal: function() { return GlobalStates.brightnessPercent ?? 80; }, set: function(v) { GlobalStates.brightnessPercent = v; tileProc.run(["brightnessctl", "set", Math.round(v) + "%"]); } },
                    { label: "Volume",     icon: Icons.speakerHigh, getVal: function() { return GlobalStates.volumePercent ?? 70; }, set: function(v) { GlobalStates.volumePercent = v; tileProc.run(["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", (v/100).toFixed(2)]); } }
                ]
                delegate: RowLayout {
                    required property var modelData
                    Layout.fillWidth: true
                    spacing: 12

                    Text {
                        text: modelData.icon
                        font.family: Icons.font
                        font.pixelSize: 18
                        color: Colors.primary
                    }

                    Text {
                        text: modelData.label
                        font.family: Config.theme.font
                        font.pixelSize: Config.theme.fontSize
                        color: Colors.overBackground
                        Layout.preferredWidth: 80
                    }

                    Slider {
                        id: quickSlider
                        Layout.fillWidth: true
                        from: 0; to: 100
                        value: modelData.getVal()
                        stepSize: 1

                        onMoved: modelData.set(value)

                        background: Rectangle {
                            x: quickSlider.leftPadding
                            y: quickSlider.topPadding + quickSlider.availableHeight / 2 - height / 2
                            implicitWidth: 200; implicitHeight: 4
                            width: quickSlider.availableWidth; height: implicitHeight
                            radius: 2
                            color: Colors.surfaceBright

                            Rectangle {
                                width: quickSlider.visualPosition * parent.width
                                height: parent.height
                                radius: parent.radius
                                color: Colors.primary
                            }
                        }

                        handle: Rectangle {
                            x: quickSlider.leftPadding + quickSlider.visualPosition * (quickSlider.availableWidth - width)
                            y: quickSlider.topPadding + quickSlider.availableHeight / 2 - height / 2
                            width: 16; height: 16; radius: 8
                            color: Colors.primary
                        }
                    }

                    Text {
                        text: Math.round(quickSlider.value) + "%"
                        font.family: Config.theme.numberFont
                        font.pixelSize: 13
                        color: Colors.outline
                        Layout.preferredWidth: 36
                    }
                }
            }
        }
    }
}
