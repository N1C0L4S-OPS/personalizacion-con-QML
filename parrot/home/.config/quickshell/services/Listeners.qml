pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Puertos TCP en escucha (ss -tlnpH). Detecta "handlers" de reverse shell
// (nc, socat, pwncat, msf...) para encender el modulo de la barra.
Singleton {
    id: root

    property var all: []        // [{port, addr, proc, pid, handler}]
    readonly property int count: all.length
    readonly property var handlers: all.filter(l => l.handler)
    readonly property bool handlerActive: handlers.length > 0

    // Procesos tipicos de un listener a la espera de una shell
    readonly property var handlerProcs: ["nc", "ncat", "nc.traditional", "socat", "pwncat",
                                         "pwncat-cs", "msfconsole", "ruby", "rlwrap"]

    Process {
        id: probe
        command: ["ss", "-tlnpH"]
        stdout: StdioCollector {
            onStreamFinished: {
                const out = [];
                for (const line of text.trim().split("\n")) {
                    if (!line.trim())
                        continue;
                    const f = line.trim().split(/\s+/);
                    const local = f[3] || "";
                    const m = local.match(/:(\d+)$/);
                    if (!m)
                        continue;
                    const proc = (line.match(/users:\(\("([^"]+)"/) || [0, ""])[1];
                    const pid = (line.match(/pid=(\d+)/) || [0, ""])[1];
                    out.push({
                        port: m[1],
                        addr: local.slice(0, local.lastIndexOf(":")),
                        proc: proc,
                        pid: pid,
                        handler: root.handlerProcs.includes(proc)
                    });
                }
                out.sort((a, b) => (b.handler - a.handler) || (Number(a.port) - Number(b.port)));
                root.all = out;
            }
        }
    }

    Timer {
        interval: 3000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: probe.running = true
    }
}
