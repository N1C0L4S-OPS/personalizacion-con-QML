pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Estado de AnonSurf (Tor). El cambio abre una terminal porque necesita contrasena (sudo).
Singleton {
    id: root

    property bool active: false
    property bool busy: false

    function toggle() {
        const action = active ? "stop" : "start";
        busy = true;
        // Terminal visible: anonsurf necesita sudo; la contrasena se escribe ahi
        Quickshell.execDetached(["kitty", "--class", "anonsurf-ctl", "-e", "bash", "-c",
            "sudo anonsurf " + action + "; echo; read -n1 -rp 'Pulsa una tecla para cerrar...'"]);
        // Re-sondea unas cuantas veces mientras el cambio surte efecto
        recheck.count = 0;
        recheck.restart();
    }

    Process {
        id: probe
        command: ["anonsurf", "status"]
        stdout: StdioCollector {
            onStreamFinished: {
                root.active = /is running/.test(text) && !/not running/.test(text);
                root.busy = false;
            }
        }
    }

    Timer {
        interval: 5000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: probe.running = true
    }

    Timer {
        id: recheck
        property int count: 0
        interval: 2000
        repeat: true
        onTriggered: {
            probe.running = true;
            if (++count >= 8)
                stop();
        }
    }
}
