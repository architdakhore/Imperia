import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import qs.config
import qs.modules.globals

QtObject {
    id: root

    property Process hyprctlProcess: Process {}

    property var previousimperiaBinds: ({})
    property var previousCustomBinds: []
    property bool hasPreviousBinds: false

    property Timer applyTimer: Timer {
        interval: 100
        repeat: false
        onTriggered: applyKeybindsInternal()
    }

    function applyKeybinds() {
        applyTimer.restart();
    }

    // Helper function to check if an action is compatible with the current layout
    function isActionCompatibleWithLayout(action) {
        // If no compositor specified, action works everywhere
        if (!action.compositor)
            return true;

        // If compositor type is not hyprland, skip (future-proofing)
        if (action.compositor.type && action.compositor.type !== "hyprland")
            return false;

        // If no layouts specified or empty array, action works in all layouts
        if (!action.compositor.layouts || action.compositor.layouts.length === 0)
            return true;

        // Check if current layout is in the allowed list
        const currentLayout = GlobalStates.hyprlandLayout;
        return action.compositor.layouts.indexOf(currentLayout) !== -1;
    }

    function cloneKeybind(keybind) {
        return {
            modifiers: keybind.modifiers ? keybind.modifiers.slice() : [],
            key: keybind.key || ""
        };
    }

    function storePreviousBinds() {
        if (!Config.keybindsLoader.loaded)
            return;

        const imperia = Config.keybindsLoader.adapter.imperia;

        // Store imperia core keybinds
        previousimperiaBinds = {
            imperia: {
                launcher: cloneKeybind(imperia.launcher),
                dashboard: cloneKeybind(imperia.dashboard),
                assistant: cloneKeybind(imperia.assistant),
                clipboard: cloneKeybind(imperia.clipboard),
                emoji: cloneKeybind(imperia.emoji),
                notes: cloneKeybind(imperia.notes),
                tmux: cloneKeybind(imperia.tmux),
                wallpapers: cloneKeybind(imperia.wallpapers)
            },
            system: {
                overview: cloneKeybind(imperia.system.overview),
                powermenu: cloneKeybind(imperia.system.powermenu),
                config: cloneKeybind(imperia.system.config),
                lockscreen: cloneKeybind(imperia.system.lockscreen),
                tools: cloneKeybind(imperia.system.tools),
                screenshot: cloneKeybind(imperia.system.screenshot),
                screenrecord: cloneKeybind(imperia.system.screenrecord),
                lens: cloneKeybind(imperia.system.lens),
                reload: imperia.system.reload ? cloneKeybind(imperia.system.reload) : null,
                quit: imperia.system.quit ? cloneKeybind(imperia.system.quit) : null
            }
        };

        // Store custom keybinds
        const customBinds = Config.keybindsLoader.adapter.custom;
        previousCustomBinds = [];
        if (customBinds && customBinds.length > 0) {
            for (let i = 0; i < customBinds.length; i++) {
                const bind = customBinds[i];
                if (bind.keys) {
                    let keys = [];
                    for (let k = 0; k < bind.keys.length; k++) {
                        keys.push(cloneKeybind(bind.keys[k]));
                    }
                    previousCustomBinds.push({
                        keys: keys
                    });
                } else {
                    previousCustomBinds.push(cloneKeybind(bind));
                }
            }
        }

        hasPreviousBinds = true;
    }

    function applyKeybindsInternal() {
        // Ensure adapter is loaded.
        if (!Config.keybindsLoader.loaded) {
            console.log("HyprlandKeybinds: Esperando que se cargue el adapter...");
            return;
        }

        // Wait for layout to be ready.
        if (!GlobalStates.hyprlandLayoutReady) {
            console.log("HyprlandKeybinds: Esperando que se detecte el layout de Hyprland...");
            return;
        }

        console.log("HyprlandKeybinds: Aplicando keybindings (layout: " + GlobalStates.hyprlandLayout + ")...");

        // Build unbind list.
        let unbindCommands = [];

        // Format modifiers.
        function formatModifiers(modifiers) {
            if (!modifiers || modifiers.length === 0)
                return "";
            return modifiers.join(" ");
        }

        // Create bind command (old format).
        function createBindCommand(keybind, flags) {
            const mods = formatModifiers(keybind.modifiers);
            const key = keybind.key;
            const dispatcher = keybind.dispatcher;
            const argument = keybind.argument || "";
            const bindKeyword = flags ? `bind${flags}` : "bind";
            // For bindm, omit argument if empty.
            if (flags === "m" && !argument) {
                return `keyword ${bindKeyword} ${mods},${key},${dispatcher}`;
            }
            return `keyword ${bindKeyword} ${mods},${key},${dispatcher},${argument}`;
        }

        // Create unbind command (old format).
        function createUnbindCommand(keybind) {
            const mods = formatModifiers(keybind.modifiers);
            const key = keybind.key;
            return `keyword unbind ${mods},${key}`;
        }

        // Create unbind command from key object (new format).
        function createUnbindFromKey(keyObj) {
            const mods = formatModifiers(keyObj.modifiers);
            const key = keyObj.key;
            return `keyword unbind ${mods},${key}`;
        }

        // Create bind command from key + action (new format).
        function createBindFromKeyAction(keyObj, action) {
            const mods = formatModifiers(keyObj.modifiers);
            const key = keyObj.key;
            const dispatcher = action.dispatcher;
            const argument = action.argument || "";
            const flags = action.flags || "";
            const bindKeyword = flags ? `bind${flags}` : "bind";
            // For bindm, omit argument if empty.
            if (flags === "m" && !argument) {
                return `keyword ${bindKeyword} ${mods},${key},${dispatcher}`;
            }
            return `keyword ${bindKeyword} ${mods},${key},${dispatcher},${argument}`;
        }

        // Build batch command for all binds.
        let batchCommands = [];

        // First, unbind previous keybinds if we have them stored
        if (hasPreviousBinds) {
            // Unbind previous imperia core keybinds
            if (previousimperiaBinds.imperia) {
                unbindCommands.push(createUnbindCommand(previousimperiaBinds.imperia.launcher));
                unbindCommands.push(createUnbindCommand(previousimperiaBinds.imperia.dashboard));
                unbindCommands.push(createUnbindCommand(previousimperiaBinds.imperia.assistant));
                unbindCommands.push(createUnbindCommand(previousimperiaBinds.imperia.clipboard));
                unbindCommands.push(createUnbindCommand(previousimperiaBinds.imperia.emoji));
                unbindCommands.push(createUnbindCommand(previousimperiaBinds.imperia.notes));
                unbindCommands.push(createUnbindCommand(previousimperiaBinds.imperia.tmux));
                unbindCommands.push(createUnbindCommand(previousimperiaBinds.imperia.wallpapers));
            }

            // Unbind previous imperia system keybinds
            if (previousimperiaBinds.system) {
                unbindCommands.push(createUnbindCommand(previousimperiaBinds.system.overview));
                unbindCommands.push(createUnbindCommand(previousimperiaBinds.system.powermenu));
                unbindCommands.push(createUnbindCommand(previousimperiaBinds.system.config));
                unbindCommands.push(createUnbindCommand(previousimperiaBinds.system.lockscreen));
                unbindCommands.push(createUnbindCommand(previousimperiaBinds.system.tools));
                unbindCommands.push(createUnbindCommand(previousimperiaBinds.system.screenshot));
                unbindCommands.push(createUnbindCommand(previousimperiaBinds.system.screenrecord));
                unbindCommands.push(createUnbindCommand(previousimperiaBinds.system.lens));
                if (previousimperiaBinds.system.reload) unbindCommands.push(createUnbindCommand(previousimperiaBinds.system.reload));
                if (previousimperiaBinds.system.quit) unbindCommands.push(createUnbindCommand(previousimperiaBinds.system.quit));
            }

            // Unbind previous custom keybinds
            for (let i = 0; i < previousCustomBinds.length; i++) {
                const prev = previousCustomBinds[i];
                if (prev.keys) {
                    for (let k = 0; k < prev.keys.length; k++) {
                        unbindCommands.push(createUnbindFromKey(prev.keys[k]));
                    }
                } else {
                    unbindCommands.push(createUnbindCommand(prev));
                }
            }
        }

        // Process core keybinds.
        const imperia = Config.keybindsLoader.adapter.imperia;

        // Core keybinds
        unbindCommands.push(createUnbindCommand(imperia.launcher));
        unbindCommands.push(createUnbindCommand(imperia.dashboard));
        unbindCommands.push(createUnbindCommand(imperia.assistant));
        unbindCommands.push(createUnbindCommand(imperia.clipboard));
        unbindCommands.push(createUnbindCommand(imperia.emoji));
        unbindCommands.push(createUnbindCommand(imperia.notes));
        unbindCommands.push(createUnbindCommand(imperia.tmux));
        unbindCommands.push(createUnbindCommand(imperia.wallpapers));

        batchCommands.push(createBindCommand(imperia.launcher, imperia.launcher.flags || ""));
        batchCommands.push(createBindCommand(imperia.dashboard, imperia.dashboard.flags || ""));
        batchCommands.push(createBindCommand(imperia.assistant, imperia.assistant.flags || ""));
        batchCommands.push(createBindCommand(imperia.clipboard, imperia.clipboard.flags || ""));
        batchCommands.push(createBindCommand(imperia.emoji, imperia.emoji.flags || ""));
        batchCommands.push(createBindCommand(imperia.notes, imperia.notes.flags || ""));
        batchCommands.push(createBindCommand(imperia.tmux, imperia.tmux.flags || ""));
        batchCommands.push(createBindCommand(imperia.wallpapers, imperia.wallpapers.flags || ""));

        // System keybinds
        const system = imperia.system;
        unbindCommands.push(createUnbindCommand(system.overview));
        unbindCommands.push(createUnbindCommand(system.powermenu));
        unbindCommands.push(createUnbindCommand(system.config));
        unbindCommands.push(createUnbindCommand(system.lockscreen));
        unbindCommands.push(createUnbindCommand(system.tools));
        unbindCommands.push(createUnbindCommand(system.screenshot));
        unbindCommands.push(createUnbindCommand(system.screenrecord));
        unbindCommands.push(createUnbindCommand(system.lens));
        if (system.reload) unbindCommands.push(createUnbindCommand(system.reload));
        if (system.quit) unbindCommands.push(createUnbindCommand(system.quit));

        batchCommands.push(createBindCommand(system.overview, system.overview.flags || ""));
        batchCommands.push(createBindCommand(system.powermenu, system.powermenu.flags || ""));
        batchCommands.push(createBindCommand(system.config, system.config.flags || ""));
        batchCommands.push(createBindCommand(system.lockscreen, system.lockscreen.flags || ""));
        batchCommands.push(createBindCommand(system.tools, system.tools.flags || ""));
        batchCommands.push(createBindCommand(system.screenshot, system.screenshot.flags || ""));
        batchCommands.push(createBindCommand(system.screenrecord, system.screenrecord.flags || ""));
        batchCommands.push(createBindCommand(system.lens, system.lens.flags || ""));
        if (system.reload) batchCommands.push(createBindCommand(system.reload, system.reload.flags || ""));
        if (system.quit) batchCommands.push(createBindCommand(system.quit, system.quit.flags || ""));

        // Process custom keybinds (keys[] and actions[] format).
        const customBinds = Config.keybindsLoader.adapter.custom;
        if (customBinds && customBinds.length > 0) {
            for (let i = 0; i < customBinds.length; i++) {
                const bind = customBinds[i];

                // Check if bind has the new format
                if (bind.keys && bind.actions) {
                    // Unbind all keys first (always unbind regardless of layout)
                    for (let k = 0; k < bind.keys.length; k++) {
                        unbindCommands.push(createUnbindFromKey(bind.keys[k]));
                    }

                    // Only create binds if enabled
                    if (bind.enabled !== false) {
                        // For each key, bind only compatible actions
                        for (let k = 0; k < bind.keys.length; k++) {
                            for (let a = 0; a < bind.actions.length; a++) {
                                const action = bind.actions[a];
                                // Check if this action is compatible with the current layout
                                if (isActionCompatibleWithLayout(action)) {
                                    batchCommands.push(createBindFromKeyAction(bind.keys[k], action));
                                }
                            }
                        }
                    }
                } else {
                    // Fallback for old format (shouldn't happen after normalization)
                    unbindCommands.push(createUnbindCommand(bind));
                    if (bind.enabled !== false) {
                        const flags = bind.flags || "";
                        batchCommands.push(createBindCommand(bind, flags));
                    }
                }
            }
        }

        storePreviousBinds();

        // Combine unbind and bind in a single batch.
        const fullBatchCommand = unbindCommands.join("; ") + "; " + batchCommands.join("; ");

        console.log("HyprlandKeybinds: Ejecutando batch command");
        hyprctlProcess.command = ["sh", "-c", `hyprctl --batch "${fullBatchCommand}"`];
        hyprctlProcess.running = true;
    }

    property Connections configConnections: Connections {
        target: Config.keybindsLoader
        function onFileChanged() {
            applyKeybinds();
        }
        function onLoaded() {
            applyKeybinds();
        }
        function onAdapterUpdated() {
            applyKeybinds();
        }
    }

    // Re-apply keybinds when layout changes
    property Connections globalStatesConnections: Connections {
        target: GlobalStates
        function onHyprlandLayoutChanged() {
            console.log("HyprlandKeybinds: Layout changed to " + GlobalStates.hyprlandLayout + ", reapplying keybindings...");
            applyKeybinds();
        }
        function onHyprlandLayoutReadyChanged() {
            if (GlobalStates.hyprlandLayoutReady) {
                applyKeybinds();
            }
        }
    }

    property Connections hyprlandConnections: Connections {
        target: Hyprland
        function onRawEvent(event) {
            if (event.name === "configreloaded") {
                console.log("HyprlandKeybinds: Detectado configreloaded, reaplicando keybindings...");
                applyKeybinds();
            }
        }
    }

    Component.onCompleted: {
        // Apply immediately if loader is ready.
        if (Config.keybindsLoader.loaded) {
            applyKeybinds();
        }
    }
}
