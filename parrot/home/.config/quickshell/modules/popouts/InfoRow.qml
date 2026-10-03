import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.config
import qs.widgets

// Fila etiqueta / valor. Si `copyable`, clic copia el valor al portapapeles.
Item {
    id: root

    property string label
    property string value
    property bool copyable: false
    property color valueColor: Theme.fg
    property bool copied: false

    Layout.fillWidth: true
    implicitHeight: 24

    Label {
        anchors { left: parent.left; verticalCenter: parent.verticalCenter }
        text: root.label
        color: Theme.fgDim
    }
    Label {
        anchors { right: parent.right; verticalCenter: parent.verticalCenter }
        mono: true
        text: root.copied ? "copiado" : (root.value || "—")
        color: root.copied ? Theme.accent : area.containsMouse && root.copyable ? Theme.accent : root.valueColor
    }

    Timer { id: reset; interval: 900; onTriggered: root.copied = false }

    MouseArea {
        id: area
        anchors.fill: parent
        enabled: root.copyable && root.value.length > 0
        hoverEnabled: true
        cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
        onClicked: {
            Quickshell.execDetached(["wl-copy", root.value]);
            root.copied = true;
            reset.restart();
        }
    }
}
