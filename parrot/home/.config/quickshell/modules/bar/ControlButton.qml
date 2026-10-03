import QtQuick
import qs.config
import qs.services
import qs.widgets

// Boton del centro de control. En rojo y latiendo mientras se graba la pantalla; taza si hay cafeina.
Item {
    id: root
    implicitWidth: row.implicitWidth
    implicitHeight: row.implicitHeight

    Row {
        id: row
        spacing: 6
        Icon {
            visible: Controls.caffeine
            code: 0xf0f4
            color: Theme.yellow
        }
        Icon {
            id: ic
            code: Controls.recording ? 0xf111 : 0xf1de
            color: Controls.recording ? Theme.red : Ui.panel === "control" ? Theme.accent : Theme.fgMuted
            SequentialAnimation on opacity {
                running: Controls.recording
                loops: Animation.Infinite
                NumberAnimation { to: 0.35; duration: 700 }
                NumberAnimation { to: 1; duration: 700 }
                onRunningChanged: if (!running) ic.opacity = 1
            }
        }
    }
    MouseArea {
        anchors.fill: parent
        anchors.margins: -4
        cursorShape: Qt.PointingHandCursor
        onClicked: Ui.toggle("control")
    }
}
