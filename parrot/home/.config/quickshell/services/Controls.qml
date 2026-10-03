pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import qs.services

// Estado de los ajustes rapidos del centro de control (Super+C).
// Cada funcion comprueba si su herramienta esta instalada; si no, aparece como "no instalado".
Singleton {
    id: root

    property var tools: ({})                    // { hyprsunset: true, ... }
    function has(t) { return !!tools[t]; }

    // ---- Comprobar herramientas ----
    Process {
        id: probe
        running: true
        command: ["sh", "-c", "for c in hyprsunset wf-recorder hyprpicker powerprofilesctl systemd-inhibit openvpn; do command -v $c >/dev/null && echo $c; done"]
        stdout: StdioCollector {
            onStreamFinished: {
                const t = {};
                for (const l of text.split("\n")) if (l) t[l] = true;
                root.tools = t;
            }
        }
    }
    function recheck() { probe.running = true; profileGet.running = true; }

    // ---- Luz nocturna (hyprsunset) ----
    property int nightTemp: 4200
    readonly property bool night: nightProc.running
    Process { id: nightProc; command: ["hyprsunset", "-t", String(root.nightTemp)] }
    function toggleNight() { if (has("hyprsunset")) nightProc.running = !nightProc.running; }

    // ---- Cafeina: impide el bloqueo y el apagado de monitores (hypridle respeta los inhibidores) ----
    readonly property bool caffeine: caffeineProc.running
    Process { id: caffeineProc; command: ["systemd-inhibit", "--what=idle", "--who=hyprshell", "--why=Cafeina", "sleep", "infinity"] }
    function toggleCaffeine() { caffeineProc.running = !caffeineProc.running; }

    // ---- Perfil de energia ----
    property string profile: ""
    readonly property var profiles: ["power-saver", "balanced", "performance"]
    readonly property var profileNames: ({ "power-saver": "Ahorro", "balanced": "Equilibrado", "performance": "Rendimiento" })
    Process {
        id: profileGet
        running: true
        command: ["powerprofilesctl", "get"]
        stdout: StdioCollector { onStreamFinished: root.profile = text.trim() }
    }
    Process { id: profileSet; onExited: profileGet.running = true }
    function cycleProfile() {
        if (!has("powerprofilesctl")) return;
        const next = profiles[(profiles.indexOf(profile) + 1) % profiles.length];
        profileSet.command = ["powerprofilesctl", "set", next];
        profileSet.running = true;
    }

    // ---- Grabacion de pantalla (wf-recorder, monitor con el foco) ----
    property string recFile: ""
    property real recStart: 0
    readonly property bool recording: recProc.running
    Process {
        id: recProc
        onExited: {
            if (root.recFile)
                Quickshell.execDetached(["notify-send", "-a", "Grabacion", "-i", "media-record", "Grabacion guardada",
                    root.recFile.replace(Quickshell.env("HOME"), "~")]);
        }
    }
    function toggleRecording() {
        if (!has("wf-recorder")) return;
        if (recProc.running) { recProc.signal(2); return; }   // SIGINT: cierra el video correctamente
        const mon = Hyprland.focusedMonitor ? Hyprland.focusedMonitor.name : "";
        recFile = Quickshell.env("HOME") + "/Videos/Grabaciones/Grabacion_" + Qt.formatDateTime(new Date(), "yyyy-MM-dd_HH-mm-ss") + ".mp4";
        recProc.command = ["wf-recorder", "-o", mon, "-f", recFile];
        recStart = Date.now();
        recProc.running = true;
    }

    // ---- Selector de color ----
    Process {
        id: picker
        command: ["hyprpicker", "-a", "-f", "hex"]
        stdout: StdioCollector {
            onStreamFinished: {
                const c = text.trim();
                if (c) Quickshell.execDetached(["notify-send", "-a", "Color", "Color copiado", c]);
            }
        }
    }
    function pickColor() { if (has("hyprpicker")) picker.running = true; }

    // qs ipc call control caffeine | night | record | profile | color | dnd
    IpcHandler {
        target: "control"
        function caffeine(): void { root.toggleCaffeine(); }
        function night(): void { root.toggleNight(); }
        function record(): void { root.toggleRecording(); }
        function profile(): void { root.cycleProfile(); }
        function color(): void { root.pickColor(); }
        function dnd(): void { Notifs.dnd = !Notifs.dnd; }
        function state(): string {
            return JSON.stringify({ caffeine: root.caffeine, night: root.night, recording: root.recording, profile: root.profile, dnd: Notifs.dnd, tools: root.tools });
        }
    }
}
