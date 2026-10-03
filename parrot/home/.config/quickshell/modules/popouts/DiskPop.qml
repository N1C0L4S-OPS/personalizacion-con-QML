import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.config
import qs.services
import qs.widgets

ColumnLayout {
    id: root

    property var mounts: []
    spacing: 12

    Process {
        running: true
        command: ["df", "-B1", "--output=target,size,used", "-x", "tmpfs", "-x", "devtmpfs", "-x", "efivarfs", "-x", "overlay", "-x", "squashfs"]
        stdout: StdioCollector {
            onStreamFinished: root.mounts = text.trim().split("\n").slice(1).map(l => {
                const p = l.trim().split(/\s+/);
                return { target: p[0], size: Number(p[1]), used: Number(p[2]) };
            }).filter(m => m.size > 0 && !m.target.startsWith("/boot"))
        }
    }

    PopHeader { code: 0xf0a0; title: "Almacenamiento" }

    Repeater {
        model: root.mounts
        Meter {
            required property var modelData
            label: modelData.target
            detail: SysInfo.bytes(modelData.used) + " / " + SysInfo.bytes(modelData.size)
            fraction: modelData.used / modelData.size
        }
    }

    ActionButton {
        code: 0xf07c
        text: "Abrir gestor de archivos"
        onClicked: { Ui.close(); Quickshell.execDetached(["dolphin"]); }
    }
}
