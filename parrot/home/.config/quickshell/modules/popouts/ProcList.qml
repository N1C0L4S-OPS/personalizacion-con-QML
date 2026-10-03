import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import qs.config
import qs.widgets

// Top 5 de procesos por CPU o memoria (sort: "cpu" | "mem"), refresco cada 2 s.
ColumnLayout {
    id: root

    property string sort: "cpu"
    property var procs: []

    Layout.fillWidth: true
    spacing: 2

    Process {
        id: ps
        command: ["ps", "-eo", "pid=,comm=,%cpu=,%mem=", "--sort=-%" + root.sort]
        stdout: StdioCollector {
            onStreamFinished: root.procs = text.trim().split("\n").slice(0, 5).map(l => {
                const p = l.trim().split(/\s+/);
                return { pid: p[0], name: p[1], cpu: p[2], mem: p[3] };
            })
        }
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: ps.running = true
    }

    Label {
        text: root.sort === "cpu" ? "Procesos con mas CPU" : "Procesos con mas memoria"
        color: Theme.fgDim
        font.pixelSize: Theme.fontSizeSmall
        Layout.bottomMargin: 4
    }

    Repeater {
        model: root.procs

        RowLayout {
            required property var modelData
            Layout.fillWidth: true
            spacing: 8
            Label { mono: true; text: modelData.pid; color: Theme.fgDim; font.pixelSize: Theme.fontSizeSmall; Layout.preferredWidth: 52 }
            Label { Layout.fillWidth: true; text: modelData.name; color: Theme.fgMuted; elide: Text.ElideRight }
            Label { mono: true; text: (root.sort === "cpu" ? modelData.cpu : modelData.mem) + "%"; color: Theme.fg }
        }
    }
}
