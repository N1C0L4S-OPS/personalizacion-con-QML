import QtQuick
import Quickshell
import qs.config
import qs.services
import qs.widgets

// VPN de Hack The Box (tun0): logo oficial + IP en verde HTB si esta conectada,
// "disconnected" en rojo si no.
// Clic central: copiar la IP de la VPN.
Item {
    id: root

    readonly property bool up: SysInfo.vpnIp.length > 0

    implicitWidth: content.implicitWidth
    implicitHeight: content.implicitHeight

    Row {
        id: content
        spacing: 7

        Image {
            anchors.verticalCenter: parent.verticalCenter
            source: "file:///usr/share/icons/htb-logo.svg"
            sourceSize.width: 15
            sourceSize.height: 16
            width: 15
            height: 16
            smooth: true
        }
        Label {
            mono: true
            text: root.up ? SysInfo.vpnIp : "disconnected"
            color: root.up ? Theme.htbGreen : Theme.red
        }
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.MiddleButton
        cursorShape: root.up ? Qt.PointingHandCursor : Qt.ArrowCursor
        onClicked: if (root.up) Quickshell.execDetached(["wl-copy", SysInfo.vpnIp])
    }
}
