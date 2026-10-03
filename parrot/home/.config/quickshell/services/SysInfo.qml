pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Telemetria del sistema, sondeada una sola vez para toda la shell.
Singleton {
    id: root

    property int cpu: 0
    property int mem: 0
    property int cpuTemp: 0
    property int gpuTemp: 0
    property int disk: 0
    property string iface: ""
    property string lanIp: ""
    property real netDown: 0  // bytes/s
    property real netUp: 0
    property string uptime: ""
    property string vpnIp: ""
    property int gpuBusy: 0
    property real vramUsed: 0   // bytes
    property real vramTotal: 0
    property string gateway: ""
    property string mac: ""
    property string cpuModel: ""

    // Historial (ultimos 60 muestreos = 2 min) para las graficas de los paneles
    readonly property int histSize: 60
    property list<real> cpuHist: []
    property list<real> gpuHist: []
    property list<real> downHist: []
    property list<real> upHist: []

    function push(arr, v) {
        const a = arr.slice(-(histSize - 1));
        a.push(v);
        return a;
    }

    function bytes(b) {
        if (b >= 1073741824) return (b / 1073741824).toFixed(1) + " GiB";
        if (b >= 1048576) return Math.round(b / 1048576) + " MiB";
        return Math.round(b / 1024) + " KiB";
    }

    property var _lastCpu: null
    property var _lastNet: null
    property string _cpuTempPath: ""
    property string _gpuTempPath: ""
    property string _gpuDev: ""

    function rate(bps) {
        if (bps >= 1048576) return (bps / 1048576).toFixed(1) + " MB/s";
        if (bps >= 1024) return Math.round(bps / 1024) + " KB/s";
        return Math.round(bps) + " B/s";
    }

    FileView { id: stat; path: "/proc/stat" }
    FileView { id: meminfo; path: "/proc/meminfo" }
    FileView { id: netdev; path: "/proc/net/dev" }
    FileView { id: uptimeFile; path: "/proc/uptime" }
    FileView { id: cpuTempFile; path: root._cpuTempPath; printErrors: false }
    FileView { id: gpuTempFile; path: root._gpuTempPath; printErrors: false }
    FileView { id: gpuBusyFile; path: root._gpuDev ? root._gpuDev + "/gpu_busy_percent" : ""; printErrors: false }
    FileView { id: vramUsedFile; path: root._gpuDev ? root._gpuDev + "/mem_info_vram_used" : ""; printErrors: false }
    FileView { id: vramTotalFile; path: root._gpuDev ? root._gpuDev + "/mem_info_vram_total" : ""; printErrors: false }
    FileView {
        path: "/proc/cpuinfo"
        onLoaded: root.cpuModel = ((text().match(/model name\s*:\s*(.+)/) || [0, ""])[1]).trim()
    }

    // Rapido (2 s): CPU, memoria, red, temperaturas
    Timer {
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            stat.reload(); meminfo.reload(); netdev.reload();

            const f = stat.text().split("\n")[0].trim().split(/\s+/).slice(1).map(Number);
            const idle = f[3] + f[4];
            const total = f.reduce((a, b) => a + b, 0);
            if (root._lastCpu && total > root._lastCpu.total)
                root.cpu = Math.round(100 * (1 - (idle - root._lastCpu.idle) / (total - root._lastCpu.total)));
            root._lastCpu = { idle, total };

            const m = meminfo.text();
            const kb = k => Number((m.match(new RegExp(k + ":\\s+(\\d+)")) || [0, 0])[1]);
            if (kb("MemTotal") > 0)
                root.mem = Math.round(100 * (1 - kb("MemAvailable") / kb("MemTotal")));

            if (root.iface) {
                const line = netdev.text().split("\n").find(l => l.trim().startsWith(root.iface + ":"));
                if (line) {
                    const v = line.split(":")[1].trim().split(/\s+/).map(Number);
                    const now = Date.now();
                    if (root._lastNet) {
                        const dt = (now - root._lastNet.t) / 1000;
                        root.netDown = Math.max(0, (v[0] - root._lastNet.rx) / dt);
                        root.netUp = Math.max(0, (v[8] - root._lastNet.tx) / dt);
                    }
                    root._lastNet = { rx: v[0], tx: v[8], t: now };
                }
            }

            if (root._cpuTempPath) { cpuTempFile.reload(); root.cpuTemp = Math.round(Number(cpuTempFile.text()) / 1000); }
            if (root._gpuTempPath) { gpuTempFile.reload(); root.gpuTemp = Math.round(Number(gpuTempFile.text()) / 1000); }

            if (root._gpuDev) {
                gpuBusyFile.reload(); vramUsedFile.reload(); vramTotalFile.reload();
                root.gpuBusy = Number(gpuBusyFile.text()) || 0;
                root.vramUsed = Number(vramUsedFile.text()) || 0;
                root.vramTotal = Number(vramTotalFile.text()) || 0;
            }

            root.cpuHist = root.push(root.cpuHist, root.cpu);
            root.gpuHist = root.push(root.gpuHist, root.gpuBusy);
            root.downHist = root.push(root.downHist, root.netDown);
            root.upHist = root.push(root.upHist, root.netUp);

            vpnProbe.running = true;
        }
    }

    // Lento (30 s): disco, interfaz/IP local, tiempo encendido
    Timer {
        interval: 30000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            diskProbe.running = true;
            routeProbe.running = true;
            uptimeFile.reload();
            const s = Math.floor(Number(uptimeFile.text().split(" ")[0]));
            const d = Math.floor(s / 86400), h = Math.floor(s % 86400 / 3600), mi = Math.floor(s % 3600 / 60);
            root.uptime = (d > 0 ? d + "d " : "") + (h > 0 || d > 0 ? h + "h " : "") + mi + "m";
        }
    }

    Process {
        id: vpnProbe
        command: ["ip", "-4", "-o", "addr", "show", "dev", "tun0"]
        stdout: StdioCollector {
            onStreamFinished: {
                const m = text.match(/inet (\d+\.\d+\.\d+\.\d+)/);
                root.vpnIp = m ? m[1] : "";
            }
        }
    }

    Process {
        id: diskProbe
        command: ["df", "--output=pcent", "/"]
        stdout: StdioCollector {
            onStreamFinished: root.disk = Number((text.match(/(\d+)%/) || [0, 0])[1])
        }
    }

    Process {
        id: routeProbe
        command: ["ip", "-4", "route", "show", "default"]
        stdout: StdioCollector {
            onStreamFinished: {
                const dev = text.match(/dev (\S+)/);
                const src = text.match(/src (\S+)/);
                const via = text.match(/via (\S+)/);
                if (dev && dev[1] !== root.iface) { root.iface = dev[1]; root._lastNet = null; }
                root.lanIp = src ? src[1] : "";
                root.gateway = via ? via[1] : "";
                if (root.iface) macProbe.running = true;
            }
        }
    }

    Process {
        id: macProbe
        command: ["cat", "/sys/class/net/" + root.iface + "/address"]
        stdout: StdioCollector { onStreamFinished: root.mac = text.trim() }
    }

    // GPU: primera tarjeta DRM que exponga gpu_busy_percent (amdgpu)
    Process {
        running: true
        command: ["sh", "-c", "for c in /sys/class/drm/card[0-9]; do [ -f $c/device/gpu_busy_percent ] && readlink -f $c/device && break; done"]
        stdout: StdioCollector { onStreamFinished: root._gpuDev = text.trim() }
    }

    // Localiza los sensores por nombre (la numeracion hwmonN cambia entre arranques)
    Process {
        running: true
        command: ["sh", "-c", "for h in /sys/class/hwmon/hwmon*; do echo \"$h $(cat $h/name)\"; done"]
        stdout: StdioCollector {
            onStreamFinished: {
                for (const l of text.trim().split("\n")) {
                    const [p, n] = l.split(" ");
                    if (n === "k10temp" || n === "coretemp") root._cpuTempPath = p + "/temp1_input";
                    else if (n === "amdgpu") root._gpuTempPath = p + "/temp1_input";
                }
            }
        }
    }
}
