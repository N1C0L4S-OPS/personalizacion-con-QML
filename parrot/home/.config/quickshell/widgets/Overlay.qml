import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import qs.config
import qs.services

// Panel flotante centrado en el monitor enfocado, con entrada animada.
// Uso: Overlay { name: "launcher"; cardWidth: ...; cardHeight: ...; <contenido> }
PanelWindow {
    id: root

    required property string name
    readonly property bool open: Ui.panel === name
    property int cardWidth: 560
    property int cardHeight: 420
    default property alias content: card.data

    property var targetScreen: Quickshell.screens[0]
    screen: targetScreen
    onOpenChanged: if (open) {
        const fm = Hyprland.focusedMonitor;
        targetScreen = Quickshell.screens.find(s => fm && s.name === fm.name) ?? Quickshell.screens[0];
    }

    visible: open || card.opacity > 0
    color: "transparent"
    anchors { top: true; bottom: true; left: true; right: true }
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "hyprshell-overlay"
    WlrLayershell.keyboardFocus: open ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    // Velo: oscurece el escritorio; clic fuera cierra
    Rectangle {
        anchors.fill: parent
        color: Theme.alpha(Theme.bg, 0.25)
        opacity: root.open ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: Theme.durNormal } }
        MouseArea { anchors.fill: parent; onClicked: Ui.close() }
    }

    Rectangle {
        id: card
        anchors.centerIn: parent
        width: root.cardWidth
        height: root.cardHeight
        radius: Theme.radius + 4
        color: Theme.alpha(Theme.bg, 0.9)
        border.width: 1
        border.color: Theme.alpha(Theme.overlay, 0.7)
        clip: true

        opacity: root.open ? 1 : 0
        scale: root.open ? 1 : 0.94
        Behavior on opacity { NumberAnimation { duration: Theme.durNormal; easing.type: Easing.BezierSpline; easing.bezierCurve: Theme.curve } }
        Behavior on scale { NumberAnimation { duration: Theme.durNormal; easing.type: Easing.BezierSpline; easing.bezierCurve: Theme.curve } }

        // Evita que los clics dentro de la tarjeta lleguen al velo
        MouseArea { anchors.fill: parent }
    }
}
