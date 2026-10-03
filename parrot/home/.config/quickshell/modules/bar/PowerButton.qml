import QtQuick
import qs.config
import qs.services
import qs.widgets

// Abre el menu de energia de la shell.
Icon {
    code: 0xf011
    color: area.containsMouse || Ui.panel === "power" ? Theme.red : Theme.fgMuted

    MouseArea {
        id: area
        anchors.fill: parent
        anchors.margins: -4
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: Ui.toggle("power")
    }
}
