pragma ComponentBehavior: Bound

// ─────────────────────────────────────────────────────────────────────────────
// ImperiaLauncherOverlay.qml — Imperia Shell (Enhanced)
// Features:
//   • Smart 3-level icon fallback chain (fixes Azure DS, IDLE, Bluetooth, etc.)
//   • AppCategoryBar filtering (Illogical Impulse–inspired)
//   • Recent apps section with usage tracking (Illogical Impulse style)
//   • Caelestia-style Material ripple hover layer on every app item
//   • DankMaterial-style rich hover tooltip with app details
//   • Wallpaper chooser tab
//   • Keyboard navigation (↑/↓/Enter/Esc)
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
    implicitWidth: 580
    implicitHeight: Math.min(620, headerArea.implicitHeight + categoryBar.height + appList.contentHeight + recentSection.implicitHeight + 56)
    focus: true

    // Tab index: 0 = apps, 1 = wallpapers
    property int currentTab: 0

    // ── Search state ──────────────────────────────────────────────────────────
    property string searchText: GlobalStates.launcherSearchText
    property int selectedIndex: 0
    property string selectedCategory: "All"

    onVisibleChanged: {
        if (visible) {
            searchInput.focusInput();
            selectedIndex = 0;
            selectedCategory = "All";
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
    property var allApps: []
    property var filteredApps: []
    property var recentApps: []

    function updateApps() {
        if (searchText.length > 0) {
            allApps = AppSearch.fuzzyQuery(searchText);
        } else {
            allApps = AppSearch.getAllApps();
            // Recent: top 6 by usage score when no search
            recentApps = allApps.slice(0, 6).filter(a => a.usageScore > 0);
        }
        applyCategory();
    }

    function applyCategory() {
        if (selectedCategory === "All" || searchText.length > 0) {
            filteredApps = allApps;
        } else {
            filteredApps = allApps.filter(app =>
                app.categories && app.categories.some(c =>
                    c.toLowerCase().includes(selectedCategory.toLowerCase()) ||
                    selectedCategory.toLowerCase().includes(c.toLowerCase())
                )
            );
        }
        selectedIndex = 0;
    }

    onSearchTextChanged: { updateApps(); }
    onSelectedCategoryChanged: { applyCategory(); }
    Component.onCompleted: { Qt.callLater(updateApps); }

    // ── Main layout ───────────────────────────────────────────────────────────
    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // ── Top: Tab bar + Search ─────────────────────────────────────────────
        Item {
            id: headerArea
            Layout.fillWidth: true
            implicitHeight: tabRow.height + searchBar.height + 20

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 8
                spacing: 6

                // Tab bar
                RowLayout {
                    id: tabRow
                    Layout.fillWidth: true
                    spacing: 0

                    LauncherTab {
                        iconStr: "\ue80b"
                        label: "Apps"
                        active: root.currentTab === 0
                        onClicked: root.currentTab = 0
                    }

                    LauncherTab {
                        iconStr: "\ue8df"
                        label: "Wallpapers"
                        active: root.currentTab === 1
                        onClicked: root.currentTab = 1
                    }

                    Item { Layout.fillWidth: true }

                    // App count badge
                    Rectangle {
                        visible: root.currentTab === 0
                        height: 20
                        width: appCountText.width + 12
                        radius: 10
                        color: Colors.surfaceBright
                        Layout.alignment: Qt.AlignVCenter

                        Text {
                            id: appCountText
                            anchors.centerIn: parent
                            text: root.filteredApps.length + " apps"
                            font.family: Config.theme.font
                            font.pixelSize: 10
                            color: Colors.outline
                        }
                    }
                }

                // Search bar
                Item {
                    id: searchBar
                    Layout.fillWidth: true
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
                                text: "\ue8b6"
                                font.family: Icons.font
                                font.pixelSize: 20
                                color: Colors.outline
                            }

                            SearchInput {
                                id: searchInput
                                Layout.fillWidth: true
                                placeholderText: root.currentTab === 0 ? "Search apps, categories…" : "Search wallpapers…"

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
                                onUpPressed: { if (root.selectedIndex > 0) root.selectedIndex--; }
                                onDownPressed: { if (root.selectedIndex < root.filteredApps.length - 1) root.selectedIndex++; }
                            }

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
            }
        }

        // ── Category filter bar (Illogical Impulse style) ─────────────────────
        Item {
            id: categoryBar
            Layout.fillWidth: true
            height: root.currentTab === 0 && root.searchText.length === 0 ? 44 : 0
            clip: true
            visible: height > 0

            Behavior on height {
                NumberAnimation { duration: Config.animDuration / 2; easing.type: Easing.OutCubic }
            }

            ScrollView {
                anchors.fill: parent
                anchors.leftMargin: 8
                anchors.rightMargin: 8
                ScrollBar.horizontal.policy: ScrollBar.AsNeeded
                ScrollBar.vertical.policy: ScrollBar.AlwaysOff
                clip: true

                AppCategoryBar {
                    selectedCategory: root.selectedCategory
                    onCategoryChanged: category => root.selectedCategory = category
                }
            }
        }

        // ── Recent apps section (Illogical Impulse style) ─────────────────────
        Item {
            id: recentSection
            Layout.fillWidth: true
            implicitHeight: recentVisible ? (recentHeader.height + recentGrid.height + 12) : 0
            clip: true

            readonly property bool recentVisible: root.currentTab === 0
                && root.searchText.length === 0
                && root.recentApps.length > 0
                && root.selectedCategory === "All"

            Behavior on implicitHeight {
                NumberAnimation { duration: Config.animDuration / 2; easing.type: Easing.OutCubic }
            }

            ColumnLayout {
                width: parent.width
                spacing: 0
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.margins: 8
                opacity: recentSection.recentVisible ? 1 : 0
                Behavior on opacity { NumberAnimation { duration: 200 } }

                // Section header
                Text {
                    id: recentHeader
                    text: "\ue8ba  Recent"
                    font.family: Icons.font
                    font.pixelSize: 11
                    color: Colors.outline
                    Layout.topMargin: 4
                    Layout.bottomMargin: 4
                }

                // Recent apps grid (DankMaterial style — icon grid)
                Row {
                    id: recentGrid
                    spacing: 6

                    Repeater {
                        model: root.recentApps.slice(0, 6)
                        delegate: Item {
                            required property var modelData
                            width: 52; height: 64

                            ColumnLayout {
                                anchors.fill: parent
                                spacing: 2

                                // Icon with hover glow (Caelestia style)
                                Item {
                                    Layout.alignment: Qt.AlignHCenter
                                    width: 40; height: 40

                                    Rectangle {
                                        id: recentIconBg
                                        anchors.fill: parent
                                        radius: Styling.radius(0)
                                        color: recentHover.hovered
                                            ? Qt.alpha(Colors.primary, 0.18)
                                            : "transparent"
                                        Behavior on color { ColorAnimation { duration: 150 } }

                                        scale: recentHover.hovered ? 1.12 : 1.0
                                        Behavior on scale {
                                            NumberAnimation { duration: 180; easing.type: Easing.OutBack; easing.overshoot: 1.6 }
                                        }

                                        Image {
                                            id: recentIcon
                                            anchors.centerIn: parent
                                            width: 30; height: 30
                                            fillMode: Image.PreserveAspectFit
                                            mipmap: true; smooth: true

                                            property var _sources: IconUtils.iconSources(modelData.icon)
                                            property int _srcIdx: 0
                                            Component.onCompleted: { source = _sources[0]; _srcIdx = 0; }
                                            onStatusChanged: {
                                                if (status === Image.Error && _srcIdx < _sources.length - 1) {
                                                    _srcIdx++;
                                                    source = _sources[_srcIdx];
                                                }
                                            }
                                        }
                                    }

                                    HoverHandler { id: recentHover }
                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: root.closeAndRun(modelData)
                                    }
                                }

                                // App name label
                                Text {
                                    Layout.fillWidth: true
                                    text: modelData.name ?? ""
                                    font.family: Config.theme.font
                                    font.pixelSize: 9
                                    color: Colors.outline
                                    horizontalAlignment: Text.AlignHCenter
                                    elide: Text.ElideRight
                                }
                            }
                        }
                    }
                }

                // Divider
                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: Colors.outline
                    opacity: 0.15
                    Layout.topMargin: 6
                }
            }
        }

        // ── All apps list ─────────────────────────────────────────────────────
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

            // Empty state
            Item {
                visible: root.filteredApps.length === 0 && root.currentTab === 0
                anchors.centerIn: parent
                width: 200; height: 80

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 8

                    Text {
                        text: "\ue5c9"
                        font.family: Icons.font
                        font.pixelSize: 32
                        color: Colors.outline
                        opacity: 0.4
                        Layout.alignment: Qt.AlignHCenter
                    }
                    Text {
                        text: "No apps found"
                        font.family: Config.theme.font
                        font.pixelSize: 13
                        color: Colors.outline
                        opacity: 0.6
                        Layout.alignment: Qt.AlignHCenter
                    }
                }
            }

            Behavior on contentY {
                NumberAnimation { duration: Config.animDuration / 2; easing.type: Easing.OutCubic }
            }

            delegate: Item {
                required property var modelData
                required property int index
                width: appList.width
                height: 54

                readonly property bool isSelected: root.selectedIndex === index

                // Background highlight
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

                // Caelestia-style ripple on click
                CaelestiaHoverLayer {
                    anchors.fill: parent
                    radius: Styling.radius(0)
                    showHoverBg: false
                    rippleColor: isSelected ? Colors.overPrimary : Colors.overBackground
                    onActivated: root.closeAndRun(modelData)
                }

                // Hover scale (Imperia-style)
                scale: appItemHover.hovered ? 1.010 : 1.0
                Behavior on scale {
                    NumberAnimation { duration: Config.animDuration / 3; easing.type: Easing.OutBack; easing.overshoot: 1.5 }
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 10
                    anchors.rightMargin: 10
                    spacing: 12

                    // App icon with 3-level fallback
                    Item {
                        Layout.preferredWidth: 36
                        Layout.preferredHeight: 36

                        Image {
                            id: appIcon
                            anchors.fill: parent
                            fillMode: Image.PreserveAspectFit
                            mipmap: true; smooth: true

                            property var _sources: IconUtils.iconSources(modelData.icon)
                            property int _srcIdx: 0

                            Component.onCompleted: { source = _sources[0]; _srcIdx = 0; }
                            onStatusChanged: {
                                if (status === Image.Error && _srcIdx < _sources.length - 1) {
                                    _srcIdx++;
                                    source = _sources[_srcIdx];
                                }
                            }
                        }

                        Tinted {
                            anchors.fill: parent
                            sourceItem: appIcon
                            visible: Config.theme.tintIcons
                        }
                    }

                    // Name + comment + category chips (DankMaterial style)
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

                            Behavior on color { ColorAnimation { duration: Config.animDuration / 2 } }
                        }

                        RowLayout {
                            spacing: 4

                            Text {
                                text: modelData.comment ?? ""
                                font.family: Config.theme.font
                                font.pixelSize: Styling.fontSize(-2)
                                color: isSelected ? Styling.srItem("primary") : Colors.outline
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                                visible: text.length > 0

                                Behavior on color { ColorAnimation { duration: Config.animDuration / 2 } }
                            }
                        }
                    }

                    // Action buttons (Caelestia style — appear on hover)
                    Row {
                        spacing: 4
                        visible: appItemHover.hovered || isSelected
                        opacity: (appItemHover.hovered || isSelected) ? 1.0 : 0.0
                        Behavior on opacity { NumberAnimation { duration: 150 } }

                        // Pin to dock button
                        Button {
                            flat: true
                            implicitWidth: 28; implicitHeight: 28

                            contentItem: Text {
                                text: TaskbarApps.isPinned(modelData.id) ? "\ue92e" : "\ue145"
                                font.family: Icons.font
                                font.pixelSize: 16
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
