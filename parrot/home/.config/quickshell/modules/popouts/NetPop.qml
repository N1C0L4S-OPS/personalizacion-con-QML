import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import qs.config
import qs.services
import qs.widgets

ColumnLayout {
    id: root

    property string publicIp: ""
    property bool fetching: false

    spacing: 12

    PopHeader { code: 0xf0e8; title: "Red"; subtitle: SysInfo.iface }

    Sparkline {
        Layout.fillWidth: true
        Layout.preferredHeight: 64
        values: SysInfo.downHist
        values2: SysInfo.upHist
    }

    RowLayout {
        Layout.fillWidth: true
        spacing: 14
        Row { spacing: 5; Icon { code: 0xf063; color: Theme.accent; font.pixelSize: Theme.fontSize } Label { mono: true; text: SysInfo.rate(SysInfo.netDown); color: Theme.fgMuted } }
        Row { spacing: 5; Icon { code: 0xf062; color: Theme.accent2; font.pixelSize: Theme.fontSize } Label { mono: true; text: SysInfo.rate(SysInfo.netUp); color: Theme.fgMuted } }
    }

    ColumnLayout {
        Layout.fillWidth: true
        spacing: 0
        InfoRow { label: "IP local"; value: SysInfo.lanIp; copyable: true }
        InfoRow { label: "Puerta de enlace"; value: SysInfo.gateway; copyable: true }
        InfoRow { label: "MAC"; value: SysInfo.mac; copyable: true }
        InfoRow { label: "VPN (tun0)"; value: SysInfo.vpnIp || "disconnected"; copyable: SysInfo.vpnIp.length > 0
                  valueColor: SysInfo.vpnIp ? Theme.htbGreen : Theme.red }
        InfoRow { label: "IP publica"; value: root.fetching ? "consultando..." : root.publicIp; copyable: root.publicIp.length > 0 }
    }

    // La IP publica solo se consulta a peticion (hace una peticion a ifconfig.me)
    ActionButton {
        code: 0xf0ac
        text: root.publicIp ? "Volver a consultar IP publica" : "Consultar IP publica"
        onClicked: { root.fetching = true; curl.running = true; }
    }

    Process {
        id: curl
        command: ["curl", "-s", "--max-time", "5", "https://ifconfig.me/ip"]
        stdout: StdioCollector {
            onStreamFinished: { root.publicIp = text.trim() || "sin respuesta"; root.fetching = false; }
        }
    }
}
