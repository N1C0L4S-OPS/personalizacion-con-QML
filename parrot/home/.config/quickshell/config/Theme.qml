pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Paleta y tokens de diseno de toda la shell.
// Los colores vienen de ~/.cache/hyprshell/colors.json (generado por themegen)
// y se recargan en vivo al cambiar el fondo de pantalla.
Singleton {
    id: root

    // Tipografia
    readonly property string fontSans: "Inter"
    readonly property string fontMono: "JetBrainsMono Nerd Font Propo"
    readonly property int fontSize: 13
    readonly property int fontSizeSmall: 11

    // Geometria
    readonly property int radius: 12
    readonly property int radiusSmall: 8
    readonly property int gap: 8
    readonly property int barHeight: 36

    // Monitores: el principal (izquierdo) lleva los espacios 1-5, el secundario 6-10
    readonly property string primaryMonitor: "DP-2"

    // Volumen maximo (salida y microfono): 1.5 = 150 %
    readonly property real maxVolume: 1.5

    // Color de marca de Hack The Box
    readonly property color htbGreen: "#9fef00"

    // Movimiento (curva "emphasized decelerate", la que da el aire Caelestia)
    readonly property int durFast: 160
    readonly property int durNormal: 320
    readonly property int durSlow: 600
    readonly property list<real> curve: [0.05, 0.7, 0.1, 1, 1, 1]

    // Colores (valores por defecto: Obsidian teal, hasta que cargue colors.json)
    property color bg: "#0e1111"
    property color surface: "#161b1b"
    property color surface2: "#1c2222"
    property color overlay: "#2c3434"
    property color fg: "#c8d0cc"
    property color fgMuted: "#8f9995"
    property color fgDim: "#6b7774"
    property color accent: "#7fb3ad"
    property color accentDim: "#5c8b8b"
    property color accent2: "#9fb8c9"
    property color red: "#c87b7b"
    property color yellow: "#c9a96e"
    property color green: "#8fbf8f"
    property color blue: "#7da7c9"
    property color magenta: "#b493b8"
    property color cyan: "#7fbcc0"
    property string wallpaper: ""

    Behavior on bg { ColorAnimation { duration: root.durSlow } }
    Behavior on surface { ColorAnimation { duration: root.durSlow } }
    Behavior on surface2 { ColorAnimation { duration: root.durSlow } }
    Behavior on overlay { ColorAnimation { duration: root.durSlow } }
    Behavior on fg { ColorAnimation { duration: root.durSlow } }
    Behavior on fgMuted { ColorAnimation { duration: root.durSlow } }
    Behavior on fgDim { ColorAnimation { duration: root.durSlow } }
    Behavior on accent { ColorAnimation { duration: root.durSlow } }
    Behavior on accentDim { ColorAnimation { duration: root.durSlow } }
    Behavior on accent2 { ColorAnimation { duration: root.durSlow } }

    function alpha(c, a) {
        return Qt.rgba(c.r, c.g, c.b, a);
    }

    FileView {
        path: Quickshell.env("HOME") + "/.cache/hyprshell/colors.json"
        watchChanges: true
        onFileChanged: reload()
        onLoaded: {
            try {
                const c = JSON.parse(text());
                for (const k of ["bg", "surface", "surface2", "overlay", "fg", "fgMuted", "fgDim",
                                 "accent", "accentDim", "accent2", "red", "yellow", "green",
                                 "blue", "magenta", "cyan", "wallpaper"])
                    if (c[k] !== undefined)
                        root[k] = c[k];
            } catch (e) {
                console.warn("Theme: colors.json invalido:", e);
            }
        }
    }
}
