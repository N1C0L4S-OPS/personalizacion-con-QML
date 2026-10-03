import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland
import qs.config
import qs.widgets

// Titulo de la ventana activa (solo en el monitor donde esta).
Label {
    required property var monitor
    readonly property var win: Hyprland.activeToplevel

    text: win && win.monitor && monitor && win.monitor.name === monitor.name ? win.title : ""
    color: Theme.fgMuted
    elide: Text.ElideRight
    Layout.maximumWidth: 380
    opacity: text ? 1 : 0
    Behavior on opacity { NumberAnimation { duration: Theme.durFast } }
}
