pragma ComponentBehavior: Bound
// ─────────────────────────────────────────────────────────────────────────────
// PerformancePanel.qml — Imperia Shell
// Circular dial gauges for CPU, GPU, RAM, Disk, Network.
// ─────────────────────────────────────────────────────────────────────────────
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell.Io
import qs.modules.theme
import qs.modules.components
import qs.modules.services
import qs.config

Item {
    id: root
    anchors.fill: parent

    // ── Live data from SystemMetrics ─────────────────────────────────────────
    property real cpuPercent:  SystemMetrics?.cpuPercent  ?? 0
    property real gpuPercent:  SystemMetrics?.gpuPercent  ?? 0
    property real ramPercent:  SystemMetrics?.ramPercent  ?? 0
    property real diskPercent: SystemMetrics?.diskPercent ?? 0
    property real netUpKb:     SystemMetrics?.netUpBytes   ?? 0
    property real netDownKb:   SystemMetrics?.netDownBytes ?? 0
    property string cpuTemp:   SystemMetrics?.cpuTempStr  ?? "--°C"
    property string gpuTemp:   SystemMetrics?.gpuTempStr  ?? "--°C"
    property string ramUsed:   SystemMetrics?.ramUsedStr  ?? "-- GB"
    property string ramTotal:  SystemMetrics?.ramTotalStr ?? "-- GB"
    property string cpuName:   SystemMetrics?.cpuName     ?? "CPU"
    property string gpuName:   SystemMetrics?.gpuName     ?? "GPU"

    // ── Circular Dial Component ───────────────────────────────────────────────
    component DialGauge: Item {
        id: dial
        property real value: 0          // 0-100
        property string label: "CPU"
        property string sublabel: "0%"
        property string iconChar: "\uf2db"
        property color arcColor: Colors.primary
        property int dialSize: 110

        width: dialSize
        height: dialSize + 28

        // Shadow ring
        Rectangle {
            anchors.centerIn: dialCanvas
            width: dialCanvas.width + 10
            height: dialCanvas.height + 10
            radius: (width) / 2
            color: "transparent"
            border.width: 3
            border.color: Qt.rgba(0,0,0,0.15)
        }

        // Background ring
        Rectangle {
            id: bgRing
            anchors.centerIn: dialCanvas
            width: dialCanvas.width
            height: dialCanvas.height
            radius: width / 2
            color: Colors.surfaceBright.lighter ? Qt.darker(Colors.surfaceBright, 1.1) : "#1a1a2e"
            border.width: 2
            border.color: Qt.rgba(1,1,1,0.05)
        }

        // Dial arc canvas
        Canvas {
            id: dialCanvas
            width: dial.dialSize
            height: dial.dialSize
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top

            onPaint: {
                var ctx = getContext("2d");
                ctx.reset();
                var cx = width / 2, cy = height / 2;
                var r = (width / 2) - 9;
                var startAngle = (Math.PI * 0.75);      // 135°
                var endAngle   = (Math.PI * 2.25);      // 405° (270° sweep)
                var valAngle   = startAngle + (dial.value / 100) * (Math.PI * 1.5);

                // Track
                ctx.beginPath();
                ctx.arc(cx, cy, r, startAngle, endAngle);
                ctx.strokeStyle = Qt.rgba(1, 1, 1, 0.06);
                ctx.lineWidth = 9;
                ctx.lineCap = "round";
                ctx.stroke();

                // Value arc
                if (dial.value > 0) {
                    ctx.beginPath();
                    ctx.arc(cx, cy, r, startAngle, valAngle);
                    var grad = ctx.createLinearGradient(0, 0, width, height);
                    grad.addColorStop(0, Qt.lighter(dial.arcColor, 1.3));
                    grad.addColorStop(1, dial.arcColor);
                    ctx.strokeStyle = grad;
                    ctx.lineWidth = 9;
                    ctx.lineCap = "round";
                    ctx.stroke();

                    // Glow dot at tip
                    var tipX = cx + r * Math.cos(valAngle);
                    var tipY = cy + r * Math.sin(valAngle);
                    ctx.beginPath();
                    ctx.arc(tipX, tipY, 5, 0, Math.PI * 2);
                    ctx.fillStyle = Qt.lighter(dial.arcColor, 1.5);
                    ctx.fill();
                }
            }

            Behavior on width {} // Force repaint when value changes
        }

        // Repaint on value change
        onValueChanged: dialCanvas.requestPaint()

        // Center content
        Column {
            anchors.centerIn: dialCanvas
            spacing: 2

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: dial.iconChar
                font.family: Icons.font
                font.pixelSize: 18
                font.weight: Font.Bold
                color: dial.arcColor
            }
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: dial.sublabel
                font.family: Config.theme.numberFont
                font.pixelSize: 15
                font.weight: Font.Bold
                color: Colors.overBackground
            }
        }

        // Label below dial
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: dialCanvas.bottom
            anchors.topMargin: 6
            text: dial.label
            font.family: Config.theme.font
            font.pixelSize: 12
            font.weight: Font.DemiBold
            color: Colors.outline
            horizontalAlignment: Text.AlignHCenter
        }
    }

    // ── Main layout ───────────────────────────────────────────────────────────
    ScrollView {
        anchors.fill: parent
        anchors.margins: 16
        contentWidth: availableWidth
        clip: true

        ColumnLayout {
            width: parent.width
            spacing: 20

            // ── Top dials row ─────────────────────────────────────────────────
            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                // CPU
                DialGauge {
                    Layout.fillWidth: true
                    value: root.cpuPercent
                    label: root.cpuName.length > 14 ? root.cpuName.substring(0, 14) + "…" : root.cpuName
                    sublabel: Math.round(root.cpuPercent) + "%"
                    iconChar: Icons.cpu
                    arcColor: {
                        if (cpuPercent > 80) return "#ef4444"
                        if (cpuPercent > 50) return "#f97316"
                        return "#6366f1"
                    }
                }

                // RAM
                DialGauge {
                    Layout.fillWidth: true
                    value: root.ramPercent
                    label: root.ramUsed + " / " + root.ramTotal
                    sublabel: Math.round(root.ramPercent) + "%"
                    iconChar: Icons.ram
                    arcColor: {
                        if (ramPercent > 80) return "#ef4444"
                        if (ramPercent > 60) return "#f59e0b"
                        return "#10b981"
                    }
                }

                // GPU
                DialGauge {
                    Layout.fillWidth: true
                    value: root.gpuPercent
                    label: root.gpuName.length > 14 ? root.gpuName.substring(0, 14) + "…" : root.gpuName
                    sublabel: Math.round(root.gpuPercent) + "%"
                    iconChar: Icons.gpu
                    arcColor: {
                        if (gpuPercent > 80) return "#ef4444"
                        if (gpuPercent > 50) return "#8b5cf6"
                        return "#3b82f6"
                    }
                }

                // Disk
                DialGauge {
                    Layout.fillWidth: true
                    value: root.diskPercent
                    label: "Disk"
                    sublabel: Math.round(root.diskPercent) + "%"
                    iconChar: Icons.disk
                    arcColor: {
                        if (diskPercent > 90) return "#ef4444"
                        if (diskPercent > 70) return "#f59e0b"
                        return "#14b8a6"
                    }
                }
            }

            // ── Temperature row ───────────────────────────────────────────────
            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Repeater {
                    model: [
                        { label: "CPU Temp", value: root.cpuTemp, icon: Icons.temperature, color: "#f97316" },
                        { label: "GPU Temp", value: root.gpuTemp, icon: Icons.temperature, color: "#8b5cf6" }
                    ]
                    delegate: StyledRect {
                        required property var modelData
                        Layout.fillWidth: true
                        variant: "surface"
                        radius: Config.roundness + 2
                        implicitHeight: 58

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 14
                            spacing: 10

                            Text {
                                text: modelData.icon
                                font.family: Icons.font
                                font.pixelSize: 22
                                font.weight: Font.Bold
                                color: modelData.color
                            }
                            ColumnLayout {
                                spacing: 1
                                Text {
                                    text: modelData.value
                                    font.family: Config.theme.numberFont
                                    font.pixelSize: 18
                                    font.weight: Font.Bold
                                    color: Colors.overBackground
                                }
                                Text {
                                    text: modelData.label
                                    font.family: Config.theme.font
                                    font.pixelSize: 11
                                    color: Colors.outline
                                }
                            }
                        }
                    }
                }
            }

            // ── Network ───────────────────────────────────────────────────────
            StyledRect {
                Layout.fillWidth: true
                variant: "surface"
                radius: Config.roundness + 2
                implicitHeight: 70

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 14
                    spacing: 16

                    // Upload
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10

                        Text {
                            text: Icons.arrowUp
                            font.family: Icons.font
                            font.pixelSize: 20
                            font.weight: Font.Bold
                            color: "#22c55e"
                        }
                        ColumnLayout {
                            spacing: 1
                            Text {
                                text: root.netUpKb >= 1024
                                    ? (root.netUpKb / 1024).toFixed(1) + " MB/s"
                                    : root.netUpKb.toFixed(0) + " KB/s"
                                font.family: Config.theme.numberFont
                                font.pixelSize: 16
                                font.weight: Font.Bold
                                color: Colors.overBackground
                            }
                            Text {
                                text: "Upload"
                                font.family: Config.theme.font
                                font.pixelSize: 11
                                color: Colors.outline
                            }
                        }
                    }

                    Rectangle { width: 1; height: 40; color: Colors.surfaceBright; opacity: 0.5 }

                    // Download
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10

                        Text {
                            text: Icons.arrowDown
                            font.family: Icons.font
                            font.pixelSize: 20
                            font.weight: Font.Bold
                            color: "#60a5fa"
                        }
                        ColumnLayout {
                            spacing: 1
                            Text {
                                text: root.netDownKb >= 1024
                                    ? (root.netDownKb / 1024).toFixed(1) + " MB/s"
                                    : root.netDownKb.toFixed(0) + " KB/s"
                                font.family: Config.theme.numberFont
                                font.pixelSize: 16
                                font.weight: Font.Bold
                                color: Colors.overBackground
                            }
                            Text {
                                text: "Download"
                                font.family: Config.theme.font
                                font.pixelSize: 11
                                color: Colors.outline
                            }
                        }
                    }
                }
            }
        }
    }
}
