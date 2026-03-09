pragma ComponentBehavior: Bound

// ─────────────────────────────────────────────────────────────────────────────
// WallpaperChooser.qml — Imperia
// Wallpaper browser adapted from Imperia, using imperia theming.
// Calls `imperia wallpaper -f <path>` or swww/hyprpaper as fallback.
// ─────────────────────────────────────────────────────────────────────────────
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import qs.modules.theme
import qs.modules.components
import qs.modules.globals
import qs.config

Item {
    id: root

    // ── Wallpaper discovery ───────────────────────────────────────────────────
    property var wallpaperDirs: [
        Quickshell.env("HOME") + "/Pictures/Wallpapers",
        Quickshell.env("HOME") + "/Pictures",
        Quickshell.env("HOME") + "/.local/share/wallpapers",
        "/usr/share/wallpapers"
    ]

    property var wallpaperList: []
    property string currentWallpaper: ""
    property string previewWallpaper: ""

    // ── Scanner process ───────────────────────────────────────────────────────
    Process {
        id: scanner
        running: true
        command: [
            "bash", "-c",
            wallpaperDirs.map(d =>
                `find "${d}" -maxdepth 3 -type f \\( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \\) 2>/dev/null`
            ).join("; ")
        ]
        stdout: StdioCollector {
            onStreamFinished: {
                root.wallpaperList = text.trim().split("\n").filter(l => l.length > 0);
                if (root.wallpaperList.length > 0)
                    root.currentWallpaper = root.wallpaperList[0];
            }
        }
    }

    // ── Setter ────────────────────────────────────────────────────────────────
    Process {
        id: wallpaperSetter
        running: false
        property string pendingPath: ""
        command: ["bash", "-c", buildSetCommand(pendingPath)]

        function buildSetCommand(path: string): string {
            // Prefer imperia > swww > swaybg as setter
            return `if command -v imperia >/dev/null 2>&1; then
                        imperia wallpaper -f "${path}"
                    elif command -v swww >/dev/null 2>&1; then
                        swww img "${path}" --transition-type fade --transition-duration 0.8
                    elif command -v hyprpaper >/dev/null 2>&1; then
                        hyprpaper settarget , "${path}"
                    else
                        swaybg -i "${path}" -m fill &
                    fi`;
        }
    }

    function setWallpaper(path: string) {
        currentWallpaper = path;
        wallpaperSetter.pendingPath = path;
        wallpaperSetter.running = true;
    }

    // ── Search filter ─────────────────────────────────────────────────────────
    property string filterText: ""

    property var displayList: {
        if (filterText.length === 0) return wallpaperList;
        const q = filterText.toLowerCase();
        return wallpaperList.filter(p => p.toLowerCase().includes(q));
    }

    // ── UI ────────────────────────────────────────────────────────────────────
    ColumnLayout {
        anchors.fill: parent
        spacing: 8

        // Empty state
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: root.displayList.length === 0

            ColumnLayout {
                anchors.centerIn: parent
                spacing: 8

                Text {
                    text: "\ue8df"  // wallpaper icon
                    font.family: Icons.font
                    font.pixelSize: 48
                    color: Colors.outline
                    Layout.alignment: Qt.AlignHCenter
                }

                Text {
                    text: "No wallpapers found"
                    font.family: Config.theme.font
                    font.pixelSize: Config.theme.fontSize
                    color: Colors.outline
                    Layout.alignment: Qt.AlignHCenter
                }

                Text {
                    text: "Add images to ~/Pictures/Wallpapers"
                    font.family: Config.theme.font
                    font.pixelSize: Styling.fontSize(-2)
                    color: Colors.outline
                    opacity: 0.7
                    Layout.alignment: Qt.AlignHCenter
                }
            }
        }

        // Grid of wallpaper thumbnails
        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: root.displayList.length > 0
            clip: true

            GridView {
                id: wallGrid
                width: parent.width
                cellWidth: 160
                cellHeight: 104
                model: root.displayList

                ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }

                delegate: Item {
                    required property string modelData
                    required property int index
                    width: wallGrid.cellWidth
                    height: wallGrid.cellHeight

                    readonly property bool isSelected: root.currentWallpaper === modelData

                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: 4
                        radius: Styling.radius(-2)
                        color: isSelected ? Colors.primary : Colors.surface
                        border.width: isSelected ? 2 : 0
                        border.color: Colors.primary
                        clip: true

                        Image {
                            anchors.fill: parent
                            anchors.margins: isSelected ? 2 : 0
                            source: "file://" + modelData
                            fillMode: Image.PreserveAspectCrop
                            mipmap: true
                            smooth: true
                            asynchronous: true

                            Rectangle {
                                anchors.fill: parent
                                color: "transparent"
                                border.width: 1
                                border.color: Qt.rgba(0, 0, 0, 0.15)
                                radius: parent.parent.radius
                            }
                        }

                        // Loading placeholder
                        Rectangle {
                            anchors.fill: parent
                            color: Colors.surface
                            visible: parent.children[0].status === Image.Loading
                            radius: parent.radius

                            Text {
                                anchors.centerIn: parent
                                text: "\ue8df"
                                font.family: Icons.font
                                font.pixelSize: 24
                                color: Colors.outline
                                opacity: 0.5
                            }
                        }

                        // Selected check
                        Rectangle {
                            visible: isSelected
                            anchors.top: parent.top
                            anchors.right: parent.right
                            anchors.margins: 4
                            width: 22; height: 22
                            radius: 11
                            color: Colors.primary

                            Text {
                                anchors.centerIn: parent
                                text: "\ue876"  // check
                                font.family: Icons.font
                                font.pixelSize: 14
                                color: Colors.overPrimary
                            }
                        }
                    }

                    // Hover state
                    HoverHandler { id: wallHover }
                    scale: wallHover.hovered ? 1.04 : 1.0
                    Behavior on scale {
                        NumberAnimation { duration: Config.animDuration / 3; easing.type: Easing.OutBack; easing.overshoot: 1.5 }
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: root.setWallpaper(modelData)
                    }
                }
            }
        }
    }
}
