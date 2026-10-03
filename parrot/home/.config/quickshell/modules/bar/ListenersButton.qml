import QtQuick
import qs.config
import qs.services
import qs.widgets

// Contador de puertos en escucha; se enciende en verde si hay un handler esperando shell.
Item {
    id: root

    required property var screen
    readonly property bool open: Ui.popout === "listeners" && Ui.popoutScreen === screen
    readonly property bool hot: Listeners.handlerActive

    implicitWidth: content.implicitWidth
    implicitHeight: content.implicitHeight

    Row {
        id: content
        spacing: 5

        Icon {
            anchors.verticalCenter: parent.verticalCenter
            code: 0xf09e
            color: root.hot ? Theme.htbGreen : root.open || area.containsMouse ? Theme.accent : Theme.fgMuted

            // Pulso suave cuando hay un handler activo
            SequentialAnimation on opacity {
                running: root.hot
                loops: Animation.Infinite
                NumberAnimation { to: 0.4; duration: 700; easing.type: Easing.InOutSine }
                NumberAnimation { to: 1; duration: 700; easing.type: Easing.InOutSine }
            }
        }
        Label {
            anchors.verticalCenter: parent.verticalCenter
            mono: true
            text: Listeners.count
            color: root.hot ? Theme.htbGreen : root.open || area.containsMouse ? Theme.fg : Theme.fgMuted
        }
    }

    MouseArea {
        id: area
        anchors.fill: parent
        anchors.margins: -4
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: Ui.togglePopout("listeners", root.screen, root.mapToItem(null, root.width / 2, 0).x)
    }
}
