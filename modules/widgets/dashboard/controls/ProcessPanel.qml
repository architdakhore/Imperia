pragma ComponentBehavior: Bound
// ─────────────────────────────────────────────────────────────────────────────
// ProcessPanel.qml — Imperia Shell
// Inspired by Imperia ProcessListModal — live process list with
// CPU/RAM sort, kill button, and search. Updates every 3 seconds.
// ─────────────────────────────────────────────────────────────────────────────
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell.Io
import qs.modules.theme
import qs.modules.components
import qs.config

Item {
    id: root
    anchors.fill: parent

    property string sortBy: "cpu"   // "cpu" | "mem" | "name"
    property string filterText: ""
    property bool loading: true

    ListModel { id: processModel }

    // ── Fetch processes ───────────────────────────────────────────────────────
    function refresh() {
        psProc.running = false;
        psProc.command = ["bash", "-c",
            "ps -eo pid,comm,%cpu,%mem --sort=-%cpu | head -40 | tail -39"];
        psProc.running = true;
    }

    Process {
        id: psProc
        property string output: ""
        onStdoutChanged: output += stdout
        onExited: {
            root.loading = false;
            processModel.clear();
            var lines = output.trim().split("\n");
            output = "";
            for (var i = 0; i < lines.length; i++) {
                var parts = lines[i].trim().replace(/\s+/g, " ").split(" ");
                if (parts.length >= 4) {
                    processModel.append({
                        pid:    parts[0],
                        name:   parts[1],
                        cpu:    parseFloat(parts[2]) || 0,
                        mem:    parseFloat(parts[3]) || 0
                    });
                }
            }
        }
    }

    Process {
        id: killProc
        function kill(pid) {
            command = ["kill", "-9", pid];
            running = false; running = true;
            Qt.callLater(root.refresh);
        }
    }

    Timer {
        interval: 3000; running: true; repeat: true
        onTriggered: root.refresh()
    }
    Component.onCompleted: refresh()

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 8

        // ── Header with search + sort ─────────────────────────────────────────
        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            // Search
            StyledRect {
                Layout.fillWidth: true
                variant: "surface"
                radius: Config.roundness
                implicitHeight: 38

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 6

                    Text {
                        text: Icons.glassPlus
                        font.family: Icons.font
                        font.pixelSize: 16
                        color: Colors.outline
                    }
                    TextField {
                        Layout.fillWidth: true
                        placeholderText: "Filter processes..."
                        font.family: Config.theme.font
                        font.pixelSize: 13
                        color: Colors.overBackground
                        background: Rectangle { color: "transparent" }
                        onTextChanged: root.filterText = text
                    }
                }
            }

            // Sort buttons
            Repeater {
                model: [
                    { label: "CPU", key: "cpu" },
                    { label: "MEM", key: "mem" },
                    { label: "NAME", key: "name" }
                ]
                delegate: Rectangle {
                    required property var modelData
                    width: 52; height: 38
                    radius: Config.roundness
                    color: root.sortBy === modelData.key ? Colors.primary : Colors.surfaceBright

                    Text {
                        anchors.centerIn: parent
                        text: modelData.label
                        font.family: Config.theme.font
                        font.pixelSize: 11
                        font.weight: Font.DemiBold
                        color: root.sortBy === modelData.key ? Colors.overPrimary : Colors.outline
                    }
                    StateLayer {
                        radius: parent.radius
                        onActivated: root.sortBy = parent.parent.modelData.key
                    }
                }
            }
        }

        // ── Column headers ────────────────────────────────────────────────────
        RowLayout {
            Layout.fillWidth: true
            Layout.leftMargin: 12
            Layout.rightMargin: 12
            spacing: 0

            Text { text: "PID"; font.family: Config.theme.font; font.pixelSize: 11; color: Colors.outline; Layout.preferredWidth: 60 }
            Text { text: "Process"; font.family: Config.theme.font; font.pixelSize: 11; color: Colors.outline; Layout.fillWidth: true }
            Text { text: "CPU%"; font.family: Config.theme.font; font.pixelSize: 11; color: Colors.outline; Layout.preferredWidth: 56; horizontalAlignment: Text.AlignRight }
            Text { text: "MEM%"; font.family: Config.theme.font; font.pixelSize: 11; color: Colors.outline; Layout.preferredWidth: 56; horizontalAlignment: Text.AlignRight }
            Item { Layout.preferredWidth: 48 }
        }

        Rectangle { Layout.fillWidth: true; height: 1; color: Colors.surfaceBright; opacity: 0.5 }

        // ── Process list ──────────────────────────────────────────────────────
        ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            spacing: 2

            model: processModel

            // Sort + filter via intermediate sorted model
            delegate: Item {
                required property int index
                required property string pid
                required property string name
                required property real cpu
                required property real mem

                width: ListView.view.width
                height: root.filterText.length > 0 &&
                        !name.toLowerCase().includes(root.filterText.toLowerCase()) ? 0 : 44
                visible: height > 0
                clip: true

                Behavior on height { NumberAnimation { duration: 100 } }

                Rectangle {
                    anchors.fill: parent
                    anchors.margins: 2
                    radius: Config.roundness
                    color: rowHover.containsMouse ? Colors.surfaceBright : "transparent"
                    opacity: rowHover.containsMouse ? 0.5 : 0
                    Behavior on opacity { NumberAnimation { duration: 100 } }
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 12
                    anchors.rightMargin: 12
                    spacing: 0

                    Text {
                        text: pid
                        font.family: Config.theme.numberFont
                        font.pixelSize: 11
                        color: Colors.outline
                        Layout.preferredWidth: 60
                    }

                    Text {
                        text: name
                        font.family: Config.theme.font
                        font.pixelSize: 13
                        color: Colors.overBackground
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }

                    // CPU bar + value
                    RowLayout {
                        Layout.preferredWidth: 56
                        spacing: 4
                        Rectangle {
                            width: 28; height: 4; radius: 2
                            color: Colors.surfaceBright
                            Rectangle {
                                width: Math.min(parent.width, parent.width * cpu / 100)
                                height: parent.height; radius: parent.radius
                                color: cpu > 50 ? Colors.error : cpu > 20 ? "#FF9800" : Colors.primary
                            }
                        }
                        Text {
                            text: cpu.toFixed(1)
                            font.family: Config.theme.numberFont
                            font.pixelSize: 11
                            color: cpu > 50 ? Colors.error : Colors.outline
                            Layout.preferredWidth: 28
                            horizontalAlignment: Text.AlignRight
                        }
                    }

                    // MEM bar + value
                    RowLayout {
                        Layout.preferredWidth: 56
                        spacing: 4
                        Rectangle {
                            width: 28; height: 4; radius: 2
                            color: Colors.surfaceBright
                            Rectangle {
                                width: Math.min(parent.width, parent.width * mem / 10)
                                height: parent.height; radius: parent.radius
                                color: mem > 5 ? "#9C27B0" : Colors.secondary
                            }
                        }
                        Text {
                            text: mem.toFixed(1)
                            font.family: Config.theme.numberFont
                            font.pixelSize: 11
                            color: Colors.outline
                            Layout.preferredWidth: 28
                            horizontalAlignment: Text.AlignRight
                        }
                    }

                    // Kill button
                    Rectangle {
                        width: 40; height: 26
                        radius: Config.roundness
                        color: killHover.containsMouse ? Colors.error : "transparent"
                        Behavior on color { ColorAnimation { duration: 150 } }

                        Text {
                            anchors.centerIn: parent
                            text: Icons.cancel
                            font.family: Icons.font
                            font.pixelSize: 16
                            color: killHover.containsMouse ? Colors.overError : Colors.outline
                            Behavior on color { ColorAnimation { duration: 150 } }
                        }
                        HoverHandler { id: killHover }
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: killProc.kill(parent.parent.parent.parent.parent.pid)
                        }
                    }
                }
                HoverHandler { id: rowHover }
            }
        }
    }
}
