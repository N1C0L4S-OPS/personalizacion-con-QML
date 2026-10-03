import QtQuick
import qs.config
import qs.services
import qs.widgets

// Estado de AnonSurf/Tor. Verde = bajo Tor. Clic alterna (abre terminal para la contrasena).
Item {
    id: root

    implicitWidth: content.implicitWidth
    implicitHeight: content.implicitHeight

    Row {
        id: content
        spacing: 6

        Icon {
            anchors.verticalCenter: parent.verticalCenter
            code: 0xf21b
            opacity: Anon.busy ? 0.5 : 1
            color: Anon.active ? Theme.htbGreen : area.containsMouse ? Theme.accent : Theme.fgMuted
            Behavior on color { ColorAnimation { duration: Theme.durNormal } }
        }
        Label {
            anchors.verticalCenter: parent.verticalCenter
            text: Anon.busy ? "..." : Anon.active ? "tor" : "clear"
            color: Anon.active ? Theme.htbGreen : Theme.fgDim
            font.pixelSize: Theme.fontSizeSmall
        }
    }

    MouseArea {
        id: area
        anchors.fill: parent
        anchors.margins: -4
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: Anon.toggle()
    }
}
