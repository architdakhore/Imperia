pragma ComponentBehavior: Bound

// ─────────────────────────────────────────────────────────────────────────────
// FusionKeybindsPanel.qml  —  Imperia
// Visual keybind editor — reads/writes Config.keybinds (binds.json)
// ─────────────────────────────────────────────────────────────────────────────
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import qs.modules.theme
import qs.modules.components
import qs.modules.globals
import qs.modules.services
import qs.config

Item {
    id: root

    property int maxContentWidth: 480

    // ── Local keybind groups ─────────────────────────────────────────────────
    readonly property var groups: [
        {
            title: "Shell Toggles",
            icon: "\ue5d2",  // layers
            binds: [
                { key: "toggleLauncher",    label: "App Launcher" },
                { key: "toggleDashboard",   label: "Dashboard" },
                { key: "toggleOverview",    label: "Overview" },
                { key: "toggleSettings",    label: "Settings" },
                { key: "togglePowermenu",   label: "Power Menu" },
                { key: "toggleSidebar",     label: "Sidebar" },
                { key: "toggleNightLight",  label: "Night Light" },
                { key: "toggleCafeineMode", label: "Caffeine Mode" },
            ]
        },
        {
            title: "Window Management",
            icon: "\ue3c4",  // view_quilt
            binds: [
                { key: "closeWindow",  label: "Close Window" },
                { key: "fullscreen",   label: "Fullscreen" },
                { key: "toggleFloat",  label: "Toggle Float" },
                { key: "centerWindow", label: "Center Window" },
                { key: "focusLeft",    label: "Focus Left" },
                { key: "focusRight",   label: "Focus Right" },
                { key: "focusUp",      label: "Focus Up" },
                { key: "focusDown",    label: "Focus Down" },
            ]
        },
        {
            title: "Applications",
            icon: "\ue80b",  // apps
            binds: [
                { key: "terminal",     label: "Terminal" },
                { key: "fileManager",  label: "File Manager" },
                { key: "browser",      label: "Browser" },
            ]
        },
        {
            title: "Screenshot & Record",
            icon: "\ue412",  // camera_alt
            binds: [
                { key: "screenshotArea",  label: "Screenshot Area" },
                { key: "screenshotFull",  label: "Screenshot Full" },
                { key: "screenRecord",    label: "Screen Record" },
            ]
        },
        {
            title: "Media",
            icon: "\ue50a",  // music_note
            binds: [
                { key: "volumeUp",      label: "Volume Up" },
                { key: "volumeDown",    label: "Volume Down" },
                { key: "volumeMute",    label: "Mute" },
                { key: "micMute",       label: "Mute Mic" },
                { key: "mediaPlay",     label: "Play / Pause" },
                { key: "mediaNext",     label: "Next Track" },
                { key: "mediaPrev",     label: "Prev Track" },
                { key: "brightnessUp",  label: "Brightness Up" },
                { key: "brightnessDown",label: "Brightness Down" },
            ]
        }
    ]

    // ── Editing state ────────────────────────────────────────────────────────
    property string editingKey: ""
    property bool isCapturing: false

    function getBindValue(key: string): string {
        try {
            const binds = Config.keybindsLoader?.adapter ?? {};
            return binds[key] ?? "—";
        } catch (e) { return "—"; }
    }

    function saveBindValue(key: string, value: string) {
        try {
            if (Config.keybindsLoader?.adapter) {
                Config.keybindsLoader.adapter[key] = value;
                Config.keybindsLoader.writeAdapter();
            }
        } catch (e) {
            console.warn("FusionKeybindsPanel: failed to save bind", key, e);
        }
    }

    ScrollView {
        anchors.fill: parent
        contentWidth: availableWidth
        clip: true

        ColumnLayout {
            width: parent.width
            spacing: 16

            // ── Header ───────────────────────────────────────────────────────
            Text {
                text: "Keybinds"
                font.family: Config.theme.font
                font.pixelSize: Config.theme.fontSize + 6
                font.weight: Font.Bold
                color: Colors.overBackground
                Layout.topMargin: 4
            }

            Text {
                text: "Click a bind to edit it. Press the new key combo, then Enter to save or Escape to cancel."
                font.family: Config.theme.font
                font.pixelSize: Styling.fontSize(-1)
                color: Colors.outline
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
            }

            // ── Modifier key selector ────────────────────────────────────────
            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Text {
                    text: "Modifier Key:"
                    font.family: Config.theme.font
                    font.pixelSize: Config.theme.fontSize
                    color: Colors.overBackground
                }

                Repeater {
                    model: ["SUPER", "ALT", "CTRL", "SHIFT"]
                    delegate: Button {
                        required property string modelData
                        flat: true
                        text: modelData
                        checked: root.getBindValue("mod") === modelData

                        contentItem: Text {
                            text: parent.text
                            font.family: Config.theme.font
                            font.pixelSize: Config.theme.fontSize - 1
                            color: parent.checked ? Colors.overPrimary : Colors.overBackground
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }

                        background: StyledRect {
                            variant: parent.checked ? "primary" : "common"
                            radius: Styling.radius(-4)
                        }

                        onClicked: root.saveBindValue("mod", modelData)
                    }
                }
            }

            // ── Groups ───────────────────────────────────────────────────────
            Repeater {
                model: root.groups

                delegate: ColumnLayout {
                    required property var modelData
                    Layout.fillWidth: true
                    spacing: 4

                    // Group header
                    RowLayout {
                        spacing: 6
                        Text {
                            text: modelData.icon
                            font.family: Icons.font
                            font.pixelSize: 18
                            color: Colors.primary
                        }
                        Text {
                            text: modelData.title
                            font.family: Config.theme.font
                            font.pixelSize: Config.theme.fontSize
                            font.weight: Font.DemiBold
                            color: Colors.overBackground
                        }
                    }

                    // Bind rows
                    Repeater {
                        model: modelData.binds

                        delegate: Item {
                            required property var modelData
                            Layout.fillWidth: true
                            width: parent.width
                            height: 42

                            readonly property bool isEditing: root.editingKey === modelData.key

                            StyledRect {
                                anchors.fill: parent
                                variant: isEditing ? "primaryFocus" : "common"
                                radius: Styling.radius(-4)

                                Behavior on opacity {
                                    NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
                                }

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: 12
                                    anchors.rightMargin: 12

                                    Text {
                                        text: modelData.label
                                        font.family: Config.theme.font
                                        font.pixelSize: Config.theme.fontSize
                                        color: Colors.overBackground
                                        Layout.fillWidth: true
                                    }

                                    // Bind chip
                                    Rectangle {
                                        color: isEditing ? Colors.primary : Colors.surface
                                        radius: 6
                                        width: bindText.implicitWidth + 16
                                        height: 26

                                        Text {
                                            id: bindText
                                            anchors.centerIn: parent
                                            text: isEditing ? (root.isCapturing ? "Press combo…" : root.getBindValue(modelData.key)) : root.getBindValue(modelData.key)
                                            font.family: Config.theme.monoFont
                                            font.pixelSize: Styling.fontSize(-1)
                                            color: isEditing ? Colors.overPrimary : Colors.overSurface
                                        }

                                        Behavior on color {
                                            ColorAnimation { duration: 180; easing.type: Easing.OutCubic }
                                        }
                                    }

                                    // Reset button
                                    Button {
                                        flat: true
                                        visible: isEditing
                                        implicitWidth: 28
                                        implicitHeight: 28
                                        contentItem: Text {
                                            text: "\ue5c9" // close icon
                                            font.family: Icons.font
                                            font.pixelSize: 16
                                            color: Colors.outline
                                            horizontalAlignment: Text.AlignHCenter
                                            verticalAlignment: Text.AlignVCenter
                                        }
                                        background: Item {}
                                        onClicked: {
                                            root.editingKey = "";
                                            root.isCapturing = false;
                                        }
                                    }
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    visible: !isEditing
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        root.editingKey = modelData.key;
                                        root.isCapturing = true;
                                    }
                                }

                                // Key capture when editing
                                Keys.onPressed: event => {
                                    if (!isEditing || !root.isCapturing) return;

                                    if (event.key === Qt.Key_Escape) {
                                        root.editingKey = "";
                                        root.isCapturing = false;
                                        event.accepted = true;
                                        return;
                                    }

                                    if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                                        root.editingKey = "";
                                        root.isCapturing = false;
                                        event.accepted = true;
                                        return;
                                    }

                                    // Build modifier string
                                    let mods = "";
                                    if (event.modifiers & Qt.MetaModifier)  mods += "$mod ";
                                    if (event.modifiers & Qt.AltModifier)   mods += "ALT ";
                                    if (event.modifiers & Qt.ControlModifier) mods += "CTRL ";
                                    if (event.modifiers & Qt.ShiftModifier)  mods += "SHIFT ";

                                    const keyStr = event.text.toUpperCase() || Qt.keyToString(event.key);
                                    if (keyStr && event.key !== Qt.Key_Meta && event.key !== Qt.Key_Alt &&
                                        event.key !== Qt.Key_Control && event.key !== Qt.Key_Shift) {
                                        const combo = `${mods.trim()}, ${keyStr}`;
                                        root.saveBindValue(modelData.key, combo);
                                        root.isCapturing = false;
                                        root.editingKey = "";
                                    }
                                    event.accepted = true;
                                }

                                focus: isEditing
                            }
                        }
                    }

                    // Divider
                    Rectangle {
                        Layout.fillWidth: true
                        height: 1
                        color: Colors.surfaceBright
                        opacity: 0.5
                    }
                }
            }

            Item { height: 12 }
        }
    }
}
