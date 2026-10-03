import QtQuick
import qs.config
import qs.services
import qs.widgets

// Abre el menu de reverse shells (LHOST + puerto + plantillas).
Item {
    id: root

    required property var screen
    readonly property bool open: Ui.popout === "revshell" && Ui.popoutScreen === screen

    implicitWidth: icon.implicitWidth
    implicitHeight: icon.implicitHeight

    Icon {
        id: icon
        code: 0xf120
        color: root.open || area.containsMouse ? Theme.accent : Theme.fgMuted
    }

    MouseArea {
        id: area
        anchors.fill: parent
        anchors.margins: -4
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: Ui.togglePopout("revshell", root.screen, root.mapToItem(null, root.width / 2, 0).x)
    }
}
