pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Objetivo HTB actual (~/.config/target_info: "IP NOMBRE EPOCH", lo escribe `settarget`).
Singleton {
    id: root

    readonly property string file: Quickshell.env("HOME") + "/.config/target_info"
    property string ip: ""
    property string name: ""
    property int startEpoch: 0
    property int now: Math.floor(Date.now() / 1000)
    readonly property bool set: ip.length > 0

    // Cronometro HH:MM:SS desde que se fijo el objetivo
    readonly property string elapsed: {
        if (!set || startEpoch <= 0)
            return "";
        const s = Math.max(0, now - startEpoch);
        const pad = n => String(n).padStart(2, "0");
        return pad(Math.floor(s / 3600)) + ":" + pad(Math.floor(s % 3600 / 60)) + ":" + pad(s % 60);
    }

    function clear() {
        Quickshell.execDetached(["rm", "-f", root.file]);
    }

    Timer {
        interval: 1000
        running: root.set && root.startEpoch > 0
        repeat: true
        onTriggered: root.now = Math.floor(Date.now() / 1000)
    }

    FileView {
        path: root.file
        watchChanges: true
        printErrors: false
        onFileChanged: reload()
        onLoaded: {
            const p = text().trim().split(/\s+/);
            root.ip = p[0] || "";
            root.name = p[1] || "";
            root.startEpoch = Number(p[2]) || 0;
        }
        onLoadFailed: { root.ip = ""; root.name = ""; root.startEpoch = 0; }
    }
}
