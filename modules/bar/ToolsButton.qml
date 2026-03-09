import QtQuick
import qs.modules.components
import qs.modules.theme
import qs.modules.services

ToggleButton {
    id: toolsButton
    buttonIcon: Icons.toolbox
    tooltipText: "Tools"
    iconColor: "#8b5cf6"   // Purple
    onToggle: function () {
        if (Visibilities.currentActiveModule === "tools") {
            Visibilities.setActiveModule("");
        } else {
            Visibilities.setActiveModule("tools");
        }
    }
}
