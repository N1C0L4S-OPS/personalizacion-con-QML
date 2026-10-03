import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Services.Pam
import qs.config

// Pantalla de bloqueo: captura cada monitor, lo difumina todo y muestra un reloj.
// La contrasena no se ve como texto: cada caracter es una barra del color del fondo.
//   qs ipc call lock lock      -> bloquea la sesion (WlSessionLock)
//   qs ipc call lock preview   -> prueba sin bloquear (Esc sale)
Scope {
    id: root

    property bool locked: false
    property bool preview: false
    readonly property bool active: locked || preview

    // idle | checking | fail | unlocking
    property string phase: "idle"
    property bool dropping: false     // fallo: las barras caen
    property string notice: ""        // aviso de PAM (p. ej. demasiados intentos)
    property string buffer: ""
    property int alive: 0             // barras vivas (las muertas solo se desvanecen)
    readonly property ListModel bars: ListModel {}

    property bool wantPreview: false
    readonly property string shotDir: Quickshell.env("XDG_RUNTIME_DIR") || "/tmp"

    function shotPath(name) {
        return `${shotDir}/hyprshell-lock-${name}.ppm`;
    }

    function start(asPreview) {
        if (active || capture.running)
            return;
        wantPreview = asPreview;
        resetInput();
        notice = "";
        // Captura todos los monitores en paralelo antes de cubrirlos
        capture.command = ["sh", "-c", Quickshell.screens.map(s =>
            `grim -t ppm -o '${s.name}' '${shotPath(s.name)}'`).join(" & ") + "; wait"];
        capture.running = true;
    }

    function resetInput() {
        phase = "idle";
        dropping = false;
        buffer = "";
        alive = 0;
        bars.clear();
    }

    function purge() {
        while (bars.count > alive)
            bars.remove(bars.count - 1);
    }

    function addChar(c) {
        purge();
        buffer += c;
        bars.append({ live: true });
        alive++;
        notice = "";
    }

    function backspace() {
        if (alive === 0)
            return;
        buffer = Array.from(buffer).slice(0, -1).join("");
        bars.setProperty(alive - 1, "live", false);
        alive--;
        purgeTimer.restart();
    }

    function clearInput() {
        buffer = "";
        for (let i = 0; i < alive; i++)
            bars.setProperty(i, "live", false);
        alive = 0;
        purgeTimer.restart();
    }

    function key(event) {
        event.accepted = true;
        if (phase !== "idle")
            return;
        const k = event.key;
        if (k === Qt.Key_Return || k === Qt.Key_Enter)
            submit();
        else if (k === Qt.Key_Backspace)
            (event.modifiers & Qt.ControlModifier) ? clearInput() : backspace();
        else if (k === Qt.Key_Escape)
            preview ? closePreview() : clearInput();
        else if (event.text.length > 0 && event.text.charCodeAt(0) >= 32)
            addChar(event.text);
    }

    function submit() {
        if (phase !== "idle" || alive === 0)
            return;
        phase = "checking";
        if (!pam.start())
            fail();
    }

    function succeed() {
        buffer = "";
        phase = "unlocking";
        finish.restart();
    }

    function fail() {
        buffer = "";
        phase = "fail";
        dropTimer.restart();
        failDone.restart();
    }

    function closePreview() {
        if (pam.active)
            pam.abort();
        preview = false;
        resetInput();
    }

    Process {
        id: capture
        // Aunque la captura falle se bloquea igual (fondo liso): la seguridad va primero
        onExited: {
            if (root.wantPreview)
                root.preview = true;
            else
                root.locked = true;
        }
    }

    PamContext {
        id: pam
        config: "hyprlock"   // /etc/pam.d/hyprlock -> common-auth
        onResponseRequiredChanged: if (responseRequired) respond(root.buffer)
        onCompleted: result => {
            if (result === PamResult.Success) {
                root.succeed();
            } else {
                if (result === PamResult.MaxTries)
                    root.notice = "demasiados intentos";
                root.fail();
            }
        }
        onError: err => {
            root.notice = "error de autenticacion";
            root.fail();
        }
    }

    Timer { id: purgeTimer; interval: 320; onTriggered: root.purge() }
    Timer { id: dropTimer; interval: 480; onTriggered: root.dropping = true }
    Timer {
        id: failDone
        interval: 1150
        onTriggered: root.resetInput()
    }
    Timer {
        id: finish
        interval: 1050
        onTriggered: {
            root.locked = false;
            root.preview = false;
            root.resetInput();
        }
    }

    WlSessionLock {
        id: sessionLock
        locked: root.locked

        WlSessionLockSurface {
            id: surface
            color: "black"
            LockSurface {
                anchors.fill: parent
                ctx: root
                screenName: surface.screen ? surface.screen.name : ""
            }
        }
    }

    // Modo prueba: misma interfaz en una capa normal, sin bloquear la sesion
    Variants {
        model: root.preview ? Quickshell.screens : []

        PanelWindow {
            id: win
            required property var modelData
            screen: modelData
            color: "black"
            anchors { top: true; bottom: true; left: true; right: true }
            exclusionMode: ExclusionMode.Ignore
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.namespace: "hyprshell-lock"
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

            LockSurface {
                anchors.fill: parent
                ctx: root
                screenName: win.modelData.name
            }
        }
    }

    IpcHandler {
        target: "lock"
        function lock(): void { root.start(false); }
        function preview(): void { root.start(true); }
        function isLocked(): bool { return root.locked; }

        // Solo en modo prueba: simula escritura y resultado para revisar animaciones
        function debugType(n: int): void {
            if (!root.preview)
                return;
            for (let i = 0; i < n; i++)
                root.addChar("x");
        }
        function debugResult(ok: bool): void {
            if (!root.preview || root.phase !== "idle" || root.alive === 0)
                return;
            root.phase = "checking";
            debugDelay.ok = ok;
            debugDelay.restart();
        }
    }

    Timer {
        id: debugDelay
        property bool ok
        interval: 900
        onTriggered: ok ? root.succeed() : root.fail()
    }
}
