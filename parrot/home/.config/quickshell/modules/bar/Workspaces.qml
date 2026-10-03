import QtQuick
import Quickshell.Hyprland
import qs.config

// Espacios fijos del monitor: 1-5 en el principal, 6-10 (mostrado como 0) en el secundario.
// El activo se alarga y muestra su numero; con ventanas = claro; vacio = tenue.
Row {
    id: root

    required property var monitor
    readonly property bool primary: monitor && monitor.name === Theme.primaryMonitor
    readonly property int first: primary ? 1 : 6
    readonly property int activeId: monitor && monitor.activeWorkspace ? monitor.activeWorkspace.id : -1

    spacing: 6

    function occupied(id) {
        const ws = Hyprland.workspaces.values.find(w => w.id === id);
        return ws ? ws.toplevels.values.length > 0 : false;
    }

    Repeater {
        model: 5

        Rectangle {
            id: pill

            required property int index
            readonly property int wsId: root.first + index
            readonly property bool active: root.activeId === wsId
            readonly property bool busy: root.occupied(wsId)

            anchors.verticalCenter: parent.verticalCenter
            width: active ? 26 : 8
            height: active ? 16 : 8
            radius: height / 2
            color: active ? Theme.accent : busy ? Theme.fgMuted : Theme.overlay

            Behavior on width { NumberAnimation { duration: Theme.durNormal; easing.type: Easing.BezierSpline; easing.bezierCurve: Theme.curve } }
            Behavior on height { NumberAnimation { duration: Theme.durNormal; easing.type: Easing.BezierSpline; easing.bezierCurve: Theme.curve } }
            Behavior on color { ColorAnimation { duration: Theme.durNormal } }

            Text {
                anchors.centerIn: parent
                text: pill.wsId % 10
                font.family: Theme.fontMono
                font.pixelSize: 10
                font.weight: Font.Bold
                color: Theme.bg
                opacity: pill.active ? 1 : 0
                Behavior on opacity { NumberAnimation { duration: Theme.durFast } }
            }

            MouseArea {
                anchors.fill: parent
                anchors.margins: -4
                cursorShape: Qt.PointingHandCursor
                onClicked: Hyprland.dispatch("workspace " + pill.wsId)
            }
        }
    }

    // Rueda: recorre solo los 5 espacios de este monitor, en ciclo
    WheelHandler {
        onWheel: e => {
            const cur = root.activeId >= root.first && root.activeId < root.first + 5 ? root.activeId : root.first;
            const next = root.first + ((cur - root.first + (e.angleDelta.y > 0 ? 4 : 1)) % 5);
            Hyprland.dispatch("workspace " + next);
        }
    }
}
