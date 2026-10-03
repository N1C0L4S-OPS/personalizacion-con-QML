import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.config
import qs.services

// Desplegable bajo el modulo pulsado de la barra. Esc o clic fuera cierra.
PanelWindow {
    id: root

    readonly property bool open: Ui.popout !== ""
    property string shown: ""   // conserva el contenido durante la animacion de salida

    onOpenChanged: if (open) shown = Ui.popout
    Connections {
        target: Ui
        function onPopoutChanged() { if (Ui.popout) root.shown = Ui.popout; }
    }

    screen: Ui.popoutScreen ?? Quickshell.screens[0]
    visible: open || card.opacity > 0
    color: "transparent"
    anchors { top: true; bottom: true; left: true; right: true }
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "hyprshell-popout"
    WlrLayershell.keyboardFocus: open ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

    MouseArea {
        anchors.fill: parent
        onClicked: Ui.close()
    }

    Rectangle {
        id: card

        readonly property int margin: Theme.gap + 4
        x: Math.max(margin, Math.min(root.width - width - margin, Ui.popoutX - width / 2))
        y: Theme.barHeight + Theme.gap * 2
        width: 340
        height: loader.implicitHeight + 32
        radius: Theme.radius + 2
        color: Theme.alpha(Theme.bg, 0.92)
        border.width: 1
        border.color: Theme.alpha(Theme.overlay, 0.7)
        focus: true
        clip: true

        opacity: root.open ? 1 : 0
        transform: Translate {
            y: root.open ? 0 : -10
            Behavior on y { NumberAnimation { duration: Theme.durNormal; easing.type: Easing.BezierSpline; easing.bezierCurve: Theme.curve } }
        }
        Behavior on opacity { NumberAnimation { duration: Theme.durNormal } }
        Behavior on x { enabled: root.open; NumberAnimation { duration: Theme.durNormal; easing.type: Easing.BezierSpline; easing.bezierCurve: Theme.curve } }
        Behavior on height { NumberAnimation { duration: Theme.durFast } }

        Keys.onEscapePressed: Ui.close()
        MouseArea { anchors.fill: parent }

        Loader {
            id: loader
            anchors { left: parent.left; right: parent.right; top: parent.top; margins: 16 }
            active: root.visible
            source: ({
                net: "NetPop.qml", cpu: "CpuPop.qml", gpu: "GpuPop.qml", mem: "MemPop.qml",
                disk: "DiskPop.qml", sys: "SysPop.qml", media: "MediaPop.qml",
                revshell: "RevShellPop.qml", listeners: "ListenersPop.qml",
                calendar: "CalendarPop.qml"
            })[root.shown] ?? ""
        }
    }
}
