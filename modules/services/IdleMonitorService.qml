pragma Singleton
// ─────────────────────────────────────────────────────────────────────────────
// IdleMonitorService.qml — Imperia Shell
// Adapted from Caelestia Shell's IdleMonitors.
// Manages idle detection and screen lock integration.
// ─────────────────────────────────────────────────────────────────────────────
import QtQuick
import Quickshell
import Quickshell.Io
import qs.config
import qs.modules.globals

Singleton {
    id: root

    property bool idleScreenLockEnabled: true
    property int idleTimeoutSeconds: 300    // 5 minutes
    property int lockTimeoutSeconds: 600    // 10 minutes
    property bool isIdle: false
    property bool isLocked: false

    // Idle detection via swayidle
    Process {
        id: idleProc
        running: false

        property var idleTimeout: root.idleTimeoutSeconds
        property var lockTimeout: root.lockTimeoutSeconds

        command: [
            "swayidle", "-w",
            "timeout", String(idleTimeout),
            "echo idle",
            "timeout", String(lockTimeout),
            "echo lock",
            "resume",
            "echo resume"
        ]

        onStdoutChanged: {
            var line = stdout.trim();
            if (line === "idle") {
                root.isIdle = true;
                // Dim screen
                GlobalStates.screenDimmed = true;
            } else if (line === "lock") {
                root.isLocked = true;
                Quickshell.execDetached(["loginctl", "lock-session"]);
            } else if (line === "resume") {
                root.isIdle = false;
                root.isLocked = false;
                GlobalStates.screenDimmed = false;
            }
        }
    }

    function start() {
        if (idleScreenLockEnabled) {
            idleProc.running = false;
            idleProc.running = true;
        }
    }

    function stop() {
        idleProc.running = false;
    }

    Component.onCompleted: start()
}
