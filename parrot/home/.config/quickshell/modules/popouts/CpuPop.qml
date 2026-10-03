import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.config
import qs.services
import qs.widgets

ColumnLayout {
    id: root

    property string load: ""
    spacing: 12

    FileView {
        id: loadavg
        path: "/proc/loadavg"
        onLoaded: root.load = text().split(" ").slice(0, 3).join("  ")
    }
    Timer { interval: 2000; running: true; repeat: true; onTriggered: loadavg.reload() }

    PopHeader { code: 0xf4bc; title: "CPU"; subtitle: SysInfo.cpuModel }

    Sparkline {
        Layout.fillWidth: true
        Layout.preferredHeight: 64
        values: SysInfo.cpuHist
        max: 100
    }

    ColumnLayout {
        Layout.fillWidth: true
        spacing: 0
        InfoRow { label: "Uso"; value: SysInfo.cpu + " %" }
        InfoRow { label: "Temperatura"; value: SysInfo.cpuTemp + " °C"; valueColor: SysInfo.cpuTemp > 85 ? Theme.yellow : Theme.fg }
        InfoRow { label: "Carga (1 · 5 · 15 min)"; value: root.load }
    }

    ProcList { sort: "cpu" }

    ActionButton {
        code: 0xf0e4
        text: "Abrir monitor (btop)"
        onClicked: { Ui.close(); Quickshell.execDetached(["kitty", "-e", "btop"]); }
    }
}
