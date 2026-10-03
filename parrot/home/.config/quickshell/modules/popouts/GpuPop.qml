import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import qs.config
import qs.services
import qs.widgets

ColumnLayout {
    id: root

    property string model: ""
    spacing: 12

    Process {
        running: true
        // Nombre comercial exacto desde libdrm (id de dispositivo + revision), como fastfetch
        command: ["sh", "-c", "d=" + SysInfo._gpuDev + "; id=$(sed 's/0x//' $d/device | tr a-z A-Z); rev=$(sed 's/0x//' $d/revision | tr a-z A-Z); grep -iE \"^$id,\\s*$rev,\" /usr/share/libdrm/amdgpu.ids | cut -f3"]
        stdout: StdioCollector { onStreamFinished: root.model = text.trim() }
    }

    PopHeader { code: 0xf108; title: "GPU"; subtitle: root.model }

    Sparkline {
        Layout.fillWidth: true
        Layout.preferredHeight: 64
        values: SysInfo.gpuHist
        max: 100
    }

    ColumnLayout {
        Layout.fillWidth: true
        spacing: 0
        InfoRow { label: "Uso"; value: SysInfo.gpuBusy + " %" }
        InfoRow { label: "Temperatura"; value: SysInfo.gpuTemp + " °C"; valueColor: SysInfo.gpuTemp > 85 ? Theme.yellow : Theme.fg }
    }

    Meter {
        label: "VRAM"
        detail: SysInfo.bytes(SysInfo.vramUsed) + " / " + SysInfo.bytes(SysInfo.vramTotal)
        fraction: SysInfo.vramTotal > 0 ? SysInfo.vramUsed / SysInfo.vramTotal : 0
    }
}
