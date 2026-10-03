import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import qs.config
import qs.services
import qs.widgets

ColumnLayout {
    id: root

    property real total: 0
    property real avail: 0
    property real swapTotal: 0
    property real swapFree: 0
    spacing: 12

    FileView {
        id: meminfo
        path: "/proc/meminfo"
        onLoaded: {
            const m = text();
            const kb = k => 1024 * Number((m.match(new RegExp(k + ":\\s+(\\d+)")) || [0, 0])[1]);
            root.total = kb("MemTotal");
            root.avail = kb("MemAvailable");
            root.swapTotal = kb("SwapTotal");
            root.swapFree = kb("SwapFree");
        }
    }
    Timer { interval: 2000; running: true; repeat: true; onTriggered: meminfo.reload() }

    PopHeader { code: 0xf2db; title: "Memoria"; subtitle: SysInfo.bytes(root.total) }

    Meter {
        label: "RAM"
        detail: SysInfo.bytes(root.total - root.avail) + " / " + SysInfo.bytes(root.total)
        fraction: root.total > 0 ? (root.total - root.avail) / root.total : 0
    }
    Meter {
        visible: root.swapTotal > 0
        label: "Swap"
        detail: SysInfo.bytes(root.swapTotal - root.swapFree) + " / " + SysInfo.bytes(root.swapTotal)
        fraction: root.swapTotal > 0 ? (root.swapTotal - root.swapFree) / root.swapTotal : 0
    }

    ProcList { sort: "mem" }
}
