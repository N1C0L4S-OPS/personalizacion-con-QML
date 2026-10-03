import QtQuick
import Quickshell
import Quickshell.Io
import qs.config

// Espectro de audio (cava) para la barra secundaria.
// Barras centradas en vertical, con degradado del acento al acento secundario.
// Si no suena nada durante un momento se pliega y desaparece.
Item {
    id: root

    readonly property int count: 20
    readonly property int barWidth: 3
    readonly property int barGap: 3
    readonly property int maxHeight: 18
    property var levels: []
    property bool sounding: false

    readonly property real fullWidth: count * barWidth + (count - 1) * barGap
    implicitWidth: sounding ? fullWidth : 0
    implicitHeight: maxHeight
    opacity: sounding ? 1 : 0
    clip: true
    Behavior on implicitWidth { NumberAnimation { duration: Theme.durNormal; easing.type: Easing.BezierSpline; easing.bezierCurve: Theme.curve } }
    Behavior on opacity { NumberAnimation { duration: Theme.durNormal } }

    Process {
        id: cava
        command: ["cava", "-p", Quickshell.env("HOME") + "/.config/cava/hyprshell.conf"]
        running: true
        stdout: SplitParser {
            onRead: line => {
                const v = line.split(";").filter(s => s.length).map(Number);
                if (v.length !== root.count)
                    return;
                root.levels = v;
                if (v.some(x => x > 1)) {
                    root.sounding = true;
                    silence.restart();
                }
            }
        }
        // Si cava no esta instalado o se cierra, reintenta
        onExited: retry.start()
    }

    Timer { id: retry; interval: 5000; onTriggered: cava.running = true }
    Timer { id: silence; interval: 1500; onTriggered: root.sounding = false }

    Row {
        anchors.verticalCenter: parent.verticalCenter
        spacing: root.barGap

        Repeater {
            model: root.count

            Rectangle {
                required property int index
                // Raiz cuadrada: realza los niveles medios y bajos sin saturar los picos
                readonly property real level: Math.sqrt((root.levels[index] ?? 0) / 100)

                anchors.verticalCenter: parent.verticalCenter
                width: root.barWidth
                height: Math.max(2, level * root.maxHeight)
                radius: width / 2
                color: Qt.rgba(
                    Theme.accent.r + (Theme.accent2.r - Theme.accent.r) * index / (root.count - 1),
                    Theme.accent.g + (Theme.accent2.g - Theme.accent.g) * index / (root.count - 1),
                    Theme.accent.b + (Theme.accent2.b - Theme.accent.b) * index / (root.count - 1), 1)
                opacity: 0.55 + 0.45 * level
                Behavior on height { NumberAnimation { duration: 60 } }
            }
        }
    }
}
