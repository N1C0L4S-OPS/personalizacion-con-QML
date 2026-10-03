import QtQuick
import qs.config
import qs.services
import qs.widgets

// Campana: clic abre el centro de notificaciones · clic derecho alterna "no molestar"
Item {
    id: root

    implicitWidth: bell.implicitWidth
    implicitHeight: bell.implicitHeight

    Icon {
        id: bell
        code: Notifs.dnd ? 0xf1f6 : 0xf0f3
        color: Ui.panel === "notifications" ? Theme.accent : Notifs.dnd ? Theme.fgDim : Theme.fgMuted
    }

    // Punto de "sin leer"
    Rectangle {
        visible: Notifs.unread > 0 && !Notifs.dnd
        anchors { right: bell.right; top: bell.top; rightMargin: -2; topMargin: 4 }
        width: 6
        height: 6
        radius: 3
        color: Theme.accent
        border.width: 1
        border.color: Theme.bg
    }

    MouseArea {
        anchors.fill: parent
        anchors.margins: -4
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        cursorShape: Qt.PointingHandCursor
        onClicked: e => e.button === Qt.RightButton ? Notifs.dnd = !Notifs.dnd : Ui.toggle("notifications")
    }
}
