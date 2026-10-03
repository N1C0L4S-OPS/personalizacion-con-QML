import QtQuick
import Quickshell
import qs.config
import qs.services
import qs.widgets

// Objetivo HTB (servicio Target) con cronometro de maquina.
// Izquierdo: fijar objetivo · Central: copiar IP · Derecho: borrar objetivo
Item {
    id: root

    implicitWidth: content.implicitWidth
    implicitHeight: content.implicitHeight

    Row {
        id: content
        spacing: 6

        Icon {
            anchors.verticalCenter: parent.verticalCenter
            code: 0xf05b
            color: Target.set ? Theme.red : Theme.fgDim
        }
        Label {
            anchors.verticalCenter: parent.verticalCenter
            mono: true
            text: Target.set ? Target.ip : "sin objetivo"
            color: Target.set ? Theme.fg : Theme.fgDim
        }
        Label {
            anchors.verticalCenter: parent.verticalCenter
            visible: Target.set && Target.name.length > 0
            text: Target.name
            color: Theme.fgMuted
        }
        // Cronometro de la maquina
        Row {
            anchors.verticalCenter: parent.verticalCenter
            visible: Target.elapsed.length > 0
            spacing: 4
            Icon {
                anchors.verticalCenter: parent.verticalCenter
                code: 0xf017
                font.pixelSize: Theme.fontSize - 1
                color: Theme.fgDim
            }
            Label {
                anchors.verticalCenter: parent.verticalCenter
                mono: true
                text: Target.elapsed
                color: Theme.fgDim
                font.pixelSize: Theme.fontSizeSmall
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton
        cursorShape: Qt.PointingHandCursor
        onClicked: e => {
            if (e.button === Qt.LeftButton)
                Quickshell.execDetached(["kitty", "--class", "htb-target", "-o", "remember_window_size=no", "-e", "bash", "-c",
                    "source ~/.config/htb_helpers.sh; read -rp 'Target IP: ' ip; read -rp 'Target Name: ' name; settarget \"$ip\" \"$name\" && sleep 1"]);
            else if (e.button === Qt.MiddleButton && Target.set)
                Quickshell.execDetached(["wl-copy", Target.ip]);
            else if (e.button === Qt.RightButton)
                Target.clear();
        }
    }
}
