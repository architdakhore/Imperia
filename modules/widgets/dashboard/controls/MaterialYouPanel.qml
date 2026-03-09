pragma ComponentBehavior: Bound

// ─────────────────────────────────────────────────────────────────────────────
// MaterialYouPanel.qml — Imperia Shell
// Imperia-inspired Material You dynamic theming.
// Extracts accent colors from your wallpaper automatically.
// ─────────────────────────────────────────────────────────────────────────────
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell.Io
import qs.modules.theme
import qs.modules.components
import qs.modules.globals
import qs.config

Item {
    id: root
    anchors.fill: root.parent

    property var extractedColors: null
    property bool extracting: false
    property string currentWallpaper: ""
    property bool autoExtract: false

    function extractColors(wallpaperPath) {
        if (!wallpaperPath) return;
        currentWallpaper = wallpaperPath;
        extracting = true;
        colorProc.running = false;
        colorProc.command = [Qt.resolvedUrl("../../../../scripts/material-colors.sh").toString().replace("file://", ""), wallpaperPath];
        colorProc.running = true;
    }

    function applyColors(colors) {
        if (!colors) return;
        // Write to theme config
        Config.theme.accentColor = colors.primary;
        Config.theme.secondaryColor = colors.secondary;
        // Trigger config save
        if (Config.saveTheme) Config.saveTheme();
    }

    Process {
        id: colorProc
        property string output: ""
        onStdoutChanged: output += stdout
        onExited: {
            root.extracting = false;
            try {
                var json = JSON.parse(output);
                output = "";
                if (!json.error) {
                    root.extractedColors = json;
                }
            } catch(e) {
                output = "";
            }
        }
    }

    ScrollView {
        anchors.fill: parent
        anchors.margins: 16
        contentWidth: availableWidth

        ColumnLayout {
            width: parent.width
            spacing: 16

            // ── Header ────────────────────────────────────────────────────────
            RowLayout {
                Layout.fillWidth: true

                ColumnLayout {
                    spacing: 4
                    Text {
                        text: "Material You"
                        font.family: Config.theme.font
                        font.pixelSize: Config.theme.fontSize + 4
                        font.weight: Font.DemiBold
                        color: Colors.overBackground
                    }
                    Text {
                        text: "Extract accent colors from your wallpaper automatically"
                        font.family: Config.theme.font
                        font.pixelSize: 12
                        color: Colors.outline
                    }
                }

                Item { Layout.fillWidth: true }

                // Auto-extract toggle
                RowLayout {
                    spacing: 8
                    Text {
                        text: "Auto on wallpaper change"
                        font.family: Config.theme.font
                        font.pixelSize: 12
                        color: Colors.outline
                    }
                    Rectangle {
                        width: 44; height: 24; radius: 12
                        color: root.autoExtract ? Colors.primary : Colors.surfaceBright
                        Behavior on color { ColorAnimation { duration: 200 } }

                        Rectangle {
                            x: root.autoExtract ? parent.width - width - 3 : 3
                            y: 3; width: 18; height: 18; radius: 9
                            color: root.autoExtract ? Colors.overPrimary : Colors.outline
                            Behavior on x { NumberAnimation { duration: 200; easing.type: Easing.OutBack } }
                        }
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.autoExtract = !root.autoExtract
                        }
                    }
                }
            }

            // ── Wallpaper path ────────────────────────────────────────────────
            StyledRect {
                Layout.fillWidth: true
                variant: "surface"
                radius: Config.roundness
                implicitHeight: 54

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 8

                    Text {
                        text: Icons.image
                        font.family: Icons.font
                        font.pixelSize: 18
                        color: Colors.primary
                    }

                    Text {
                        Layout.fillWidth: true
                        text: root.currentWallpaper || "No wallpaper selected"
                        font.family: Config.theme.font
                        font.pixelSize: 12
                        color: root.currentWallpaper ? Colors.overBackground : Colors.outline
                        elide: Text.ElideMiddle
                    }

                    Rectangle {
                        width: 100; height: 34
                        radius: Config.roundness
                        color: extractBtn.hovered ? Colors.primary : Colors.surfaceBright
                        Behavior on color { ColorAnimation { duration: 150 } }

                        Text {
                            anchors.centerIn: parent
                            text: root.extracting ? "Extracting…" : "Extract Colors"
                            font.family: Config.theme.font
                            font.pixelSize: 12
                            color: extractBtn.hovered ? Colors.overPrimary : Colors.overBackground
                        }
                        HoverHandler { id: extractBtn }
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            enabled: !root.extracting
                            onClicked: {
                                var wp = GlobalStates.currentWallpaper || root.currentWallpaper;
                                if (wp) root.extractColors(wp);
                            }
                        }
                    }
                }
            }

            // ── Color swatches ────────────────────────────────────────────────
            Text {
                text: "Extracted Palette"
                font.family: Config.theme.font
                font.pixelSize: 13
                font.weight: Font.DemiBold
                color: Colors.outline
                visible: root.extractedColors !== null
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 10
                visible: root.extractedColors !== null

                Repeater {
                    model: root.extractedColors ? [
                        { label: "Primary",    color: root.extractedColors.primary },
                        { label: "Secondary",  color: root.extractedColors.secondary },
                        { label: "Tertiary",   color: root.extractedColors.tertiary },
                        { label: "Surface",    color: root.extractedColors.surface },
                        { label: "Background", color: root.extractedColors.background }
                    ] : []

                    delegate: ColumnLayout {
                        required property var modelData
                        Layout.fillWidth: true
                        spacing: 6

                        Rectangle {
                            Layout.fillWidth: true
                            height: 56
                            radius: Config.roundness
                            color: modelData.color

                            Rectangle {
                                anchors.fill: parent
                                radius: parent.radius
                                color: swatchHover.hovered ? "white" : "transparent"
                                opacity: 0.1
                            }
                            HoverHandler { id: swatchHover }
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                // Could copy hex to clipboard
                            }
                        }

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: modelData.label
                            font.family: Config.theme.font
                            font.pixelSize: 11
                            color: Colors.outline
                        }
                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: modelData.color
                            font.family: Config.theme.numberFont
                            font.pixelSize: 10
                            color: Colors.outline
                        }
                    }
                }
            }

            // All colors strip
            RowLayout {
                Layout.fillWidth: true
                spacing: 4
                visible: root.extractedColors && root.extractedColors.allColors

                Repeater {
                    model: root.extractedColors?.allColors ?? []
                    delegate: Rectangle {
                        required property string modelData
                        Layout.fillWidth: true
                        height: 20
                        radius: 4
                        color: modelData
                    }
                }
            }

            // ── Apply button ──────────────────────────────────────────────────
            Rectangle {
                Layout.fillWidth: true
                height: 44
                radius: Config.roundness
                color: applyHover.hovered ? Colors.primary : Colors.surfaceBright
                visible: root.extractedColors !== null
                Behavior on color { ColorAnimation { duration: 150 } }

                Text {
                    anchors.centerIn: parent
                    text: "Apply These Colors to Theme"
                    font.family: Config.theme.font
                    font.pixelSize: Config.theme.fontSize
                    font.weight: Font.DemiBold
                    color: applyHover.hovered ? Colors.overPrimary : Colors.overBackground
                }
                HoverHandler { id: applyHover }
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.applyColors(root.extractedColors)
                }
            }
        }
    }
}
