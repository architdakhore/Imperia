import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import qs.modules.services
import qs.modules.components
import "./NotificationDelegate.qml"

ListView {
    id: root
    property bool popup: false

    spacing: 8
    clip: true

    // Show all notifications
    model: root.popup ? Notifications.popupNotifications : Notifications.notifications

    delegate: NotificationDelegate {
        required property int index
        required property var modelData
        anchors.left: parent?.left
        anchors.right: parent?.right
        notificationObject: modelData
        expanded: true
        onlyNotification: true

        onDestroyRequested: {}
    }

    // ── Caelestia-style scrollbar on the right ──────────────────────────────
    StyledScrollBar {
        id: scrollBar
        flickable: root
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.rightMargin: 2
        orientation: Qt.Vertical
        policy: root.contentHeight > root.height ? ScrollBar.AlwaysOn : ScrollBar.AlwaysOff
    }

    ScrollBar.vertical: scrollBar
}
