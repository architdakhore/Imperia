pragma ComponentBehavior: Bound

// ─────────────────────────────────────────────────────────────────────────────
// CaelestiaLauncherOverlay.qml — Imperia
// Caelestia-style launcher with Ambxst theming, hover states, wallpaper changer,
// Smart icon resolution for every app including Azure Data Studio, IDLE, etc.
// ─────────────────────────────────────────────────────────────────────────────
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import Quickshell.Widgets
import qs.modules.theme
import qs.modules.components
import qs.modules.globals
import qs.modules.services
import qs.config
import "../../utils/IconUtils.js" as IconUtils

Rectangle {
    id: root
    color: "transparent"

    // ── Sizing ────────────────────────────────────────────────────────────────
    implicitWidth: 560
    implicitHeight: Math.min(600, searchInput.height + appList.contentHeight + wallpaperStrip.height + 48)
    focus: true

    // Tab index: 0 = apps, 1 = wallpapers
    property int currentTab: 0

    // ── Search state ──────────────────────────────────────────────────────────
    property string searchText: GlobalStates.launcherSearchText
    property int selectedIndex: 0

    onVisibleChanged: {
        if (visible) {
            searchInput.focusInput();
            selectedIndex = 0;
        }
    }

    function closeAndRun(app) {
        if (app && app.execute) {
            app.execute();
            UsageTracker.recordUsage(app.id);
        }
        Visibilities.setActiveModule("");
    }

    // ── Icon helper: smart multi-fallback resolution ──────────────────────────
    function iconSource(iconName) {
        return IconUtils.resolveIcon(iconName);
    }

    // ── Apps model ────────────────────────────────────────────────────────────
    property var filteredApps: []

    function updateApps() {
        if (searchText.length > 0)
            filteredApps = AppSearch.fuzzyQuery(searchText);
        else
            filteredApps = AppSearch.getAllApps();
    }

    onSearchTextChanged: { updateApps(); selectedIndex = 0; }
    Component.onCompleted: { Qt.callLater(updateApps); }

    // ── Main layout ───────────────────────────────────────────────────────────
    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // ── Top: Tab bar ──────────────────────────────────────────────────────
        RowLayout {
            Layout.fillWidth: true
            spacing: 0
            Layout.leftMargin: 8
            Layout.rightMargin: 8
            Layout.topMargin: 8

            // Apps tab
            LauncherTab {
                id: appsTab
                iconStr: "\ue80b"    // apps icon
                label: "Apps"
                active: root.currentTab === 0
                onClicked: root.currentTab = 0
            }

            // Wallpapers tab
            LauncherTab {
                iconStr: "\ue8df"    // wallpaper icon
                label: "Wallpapers"
                active: root.currentTab === 1
                onClicked: root.currentTab = 1
            }

            Item { Layout.fillWidth: true }
        }

        // ── Search bar ────────────────────────────────────────────────────────
        Item {
            Layout.fillWidth: true
            Layout.margins: 8
            height: 44

            StyledRect {
                anchors.fill: parent
                variant: "pane"
                radius: Styling.radius(4)

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 12
                    anchors.rightMargin: 12
                    spacing: 8

                    Text {
                        text: "\ue8b6"  // search icon
                        font.family: Icons.font
                        font.pixelSize: 20
                        color: Colors.outline
                    }

                    SearchInput {
                        id: searchInput
                        Layout.fillWidth: true
                        placeholderText: root.currentTab === 0 ? "Search apps…" : "Search wallpapers…"

                        onSearchTextChanged: text => {
                            GlobalStates.launcherSearchText = text;
                            root.searchText = text;
                        }

                        onAccepted: {
                            if (root.currentTab === 0 && root.filteredApps.length > 0) {
                                root.closeAndRun(root.filteredApps[root.selectedIndex] ?? root.filteredApps[0]);
                            }
                        }

                        onEscapePressed: Visibilities.setActiveModule("")

                        onUpPressed: {
                            if (root.selectedIndex > 0) root.selectedIndex--;
                        }
                        onDownPressed: {
                            if (root.selectedIndex < root.filteredApps.length - 1)
                                root.selectedIndex++;
                        }
                    }

                    // Clear button
                    Button {
                        flat: true
                        visible: root.searchText.length > 0
                        implicitWidth: 28; implicitHeight: 28
                        contentItem: Text {
                            text: "\ue5c9"
                            font.family: Icons.font
                            font.pixelSize: 16
                            color: Colors.outline
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                        background: Item {}
                        onClicked: {
                            GlobalStates.launcherSearchText = "";
                            searchInput.focusInput();
                        }
                    }
                }
            }
        }

        // ── Apps list ─────────────────────────────────────────────────────────
        ListView {
            id: appList
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.leftMargin: 8
            Layout.rightMargin: 8
            visible: root.currentTab === 0
            clip: true
            spacing: 2
            currentIndex: root.selectedIndex

            model: root.filteredApps

            ScrollBar.vertical: ScrollBar {
                policy: ScrollBar.AsNeeded
                implicitWidth: 6
            }

            Behavior on contentY {
                NumberAnimation { duration: Config.animDuration / 2; easing.type: Easing.OutCubic }
            }

            delegate: Item {
                required property var modelData
                required property int index
                width: appList.width
                height: 52

                readonly property bool isSelected: root.selectedIndex === index

                // Hover highlight
                StyledRect {
                    anchors.fill: parent
                    visible: appItemHover.hovered || isSelected
                    variant: isSelected ? "primary" : "focus"
                    radius: Styling.radius(0)
                    opacity: isSelected ? 0.9 : 0.7

                    Behavior on opacity {
                        NumberAnimation { duration: Config.animDuration / 2; easing.type: Easing.OutCubic }
                    }
                }

                // Hover scale effect (Caelestia-style)
                scale: appItemHover.hovered ? 1.012 : 1.0
                Behavior on scale {
                    NumberAnimation { duration: Config.animDuration / 3; easing.type: Easing.OutBack; easing.overshoot: 1.5 }
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 10
                    anchors.rightMargin: 10
                    spacing: 12

                    // App Icon — smart fallback chain (handles absolute paths, IDLE, Azure DS, etc.)
                    Item {
                        Layout.preferredWidth: 36
                        Layout.preferredHeight: 36

                        Image {
                            id: appIcon
                            anchors.fill: parent
                            fillMode: Image.PreserveAspectFit
                            mipmap: true
                            smooth: true

                            property var _sources: IconUtils.iconSources(modelData.icon)

                            Component.onCompleted: { source = _sources[0]; }

                            onStatusChanged: {
                                if (status === Image.Error && source !== _sources[1])
                                    source = _sources[1];
                            }
                        }

                        // Tint overlay when selected
                        Tinted {
                            anchors.fill: parent
                            sourceItem: appIcon
                            visible: Config.theme.tintIcons
                        }
                    }

                    // Name + comment
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 0

                        Text {
                            text: modelData.name ?? ""
                            font.family: Config.theme.font
                            font.pixelSize: Config.theme.fontSize
                            font.weight: Font.DemiBold
                            color: isSelected ? Styling.srItem("overprimary") : Colors.overBackground
                            elide: Text.ElideRight
                            width: parent.width

                            Behavior on color {
                                ColorAnimation { duration: Config.animDuration / 2 }
                            }
                        }

                        Text {
                            text: modelData.comment ?? ""
                            font.family: Config.theme.font
                            font.pixelSize: Styling.fontSize(-2)
                            color: isSelected ? Styling.srItem("primary") : Colors.outline
                            elide: Text.ElideRight
                            width: parent.width
                            visible: text.length > 0

                            Behavior on color {
                                ColorAnimation { duration: Config.animDuration / 2 }
                            }
                        }
                    }

                    // Pin/action button on hover
                    Button {
                        flat: true
                        visible: appItemHover.hovered || isSelected
                        implicitWidth: 30; implicitHeight: 30
                        opacity: (appItemHover.hovered || isSelected) ? 1.0 : 0.0
                        Behavior on opacity { NumberAnimation { duration: 150 } }

                        contentItem: Text {
                            text: TaskbarApps.isPinned(modelData.id) ? "\ue92e" : "\ue145"
                            font.family: Icons.font
                            font.pixelSize: 18
                            color: isSelected ? Colors.overPrimary : Colors.outline
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }

                        background: StyledRect {
                            variant: "focus"
                            radius: Styling.radius(-2)
                        }

                        ToolTip.text: TaskbarApps.isPinned(modelData.id) ? "Unpin from Dock" : "Pin to Dock"
                        ToolTip.visible: hovered
                        ToolTip.delay: 500

                        onClicked: TaskbarApps.togglePin(modelData.id)
                    }
                }

                // Click to launch
                MouseArea {
                    anchors.fill: parent
                    onClicked: root.closeAndRun(modelData)
                }

                HoverHandler { id: appItemHover }
            }
        }

        // ── Wallpapers grid ───────────────────────────────────────────────────
        Item {
            id: wallpaperStrip
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.margins: 8
            visible: root.currentTab === 1

            WallpaperChooser {
                anchors.fill: parent
            }
        }

        // ── Bottom spacer ─────────────────────────────────────────────────────
        Item { height: 8 }
    }

    // ── Tab component ─────────────────────────────────────────────────────────
    component LauncherTab: Button {
        id: tab
        property string iconStr: ""
        property string label: ""
        property bool active: false

        flat: true
        implicitHeight: 34

        contentItem: RowLayout {
            spacing: 6
            Text {
                text: tab.iconStr
                font.family: Icons.font
                font.pixelSize: 16
                color: tab.active ? Colors.overPrimary : Colors.outline
                Behavior on color { ColorAnimation { duration: Config.animDuration / 2 } }
            }
            Text {
                text: tab.label
                font.family: Config.theme.font
                font.pixelSize: Config.theme.fontSize - 1
                font.weight: tab.active ? Font.DemiBold : Font.Normal
                color: tab.active ? Colors.overPrimary : Colors.outline
                Behavior on color { ColorAnimation { duration: Config.animDuration / 2 } }
            }
        }

        background: StyledRect {
            variant: tab.active ? "primary" : "common"
            radius: Styling.radius(-2)
            opacity: tab.active ? 1.0 : (tab.hovered ? 0.7 : 0.0)
            Behavior on opacity { NumberAnimation { duration: Config.animDuration / 3 } }
        }
    }
}
