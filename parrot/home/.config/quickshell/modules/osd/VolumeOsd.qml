import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import Quickshell.Services.Pipewire
import qs.config
import qs.widgets

// Aviso de volumen/microfono: aparece abajo al centro cuando cambia el nivel o el silencio.
// La barra llega hasta Theme.maxVolume; la marca indica el 100 %.
PanelWindow {
    id: root

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property var source: Pipewire.defaultAudioSource
    property bool showingMic: false
    readonly property var node: showingMic ? source : sink
    readonly property bool muted: node && node.audio ? node.audio.muted : false
    readonly property real volume: node && node.audio ? node.audio.volume : 0

    property bool shown: false
    property bool armed: false  // evita mostrarlo al arrancar la shell

    screen: {
        const fm = Hyprland.focusedMonitor;
        return Quickshell.screens.find(s => fm && s.name === fm.name) ?? Quickshell.screens[0];
    }

    visible: pill.opacity > 0
    color: "transparent"
    anchors.bottom: true
    margins.bottom: 90
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "hyprshell-osd"
    implicitWidth: 300
    implicitHeight: 52
    mask: Region {}  // no captura clics

    PwObjectTracker { objects: [root.sink, root.source] }

    function poke(mic) {
        if (!armed)
            return;
        showingMic = mic;
        shown = true;
        hideTimer.restart();
    }

    Connections {
        target: root.sink ? root.sink.audio : null
        function onVolumeChanged() { root.poke(false); }
        function onMutedChanged() { root.poke(false); }
    }
    Connections {
        target: root.source ? root.source.audio : null
        function onVolumeChanged() { root.poke(true); }
        function onMutedChanged() { root.poke(true); }
    }

    Timer { interval: 1500; running: true; onTriggered: root.armed = true }
    Timer { id: hideTimer; interval: 1600; onTriggered: root.shown = false }

    Rectangle {
        id: pill
        anchors.fill: parent
        radius: height / 2
        color: Theme.alpha(Theme.bg, 0.9)
        border.width: 1
        border.color: Theme.alpha(Theme.overlay, 0.7)
        opacity: root.shown ? 1 : 0
        scale: root.shown ? 1 : 0.92
        Behavior on opacity { NumberAnimation { duration: Theme.durNormal } }
        Behavior on scale { NumberAnimation { duration: Theme.durNormal; easing.type: Easing.BezierSpline; easing.bezierCurve: Theme.curve } }

        readonly property color tone: root.muted ? Theme.fgDim : root.volume > 1.001 ? Theme.yellow : Theme.accent

        Icon {
            id: icon
            anchors { left: parent.left; leftMargin: 20; verticalCenter: parent.verticalCenter }
            width: 18
            code: root.showingMic ? (root.muted ? 0xf131 : 0xf130)
                : root.muted ? 0xf026 : root.volume < 0.4 ? 0xf027 : 0xf028
            color: pill.tone
        }

        Rectangle {
            id: track
            anchors { left: icon.right; leftMargin: 12; right: value.left; rightMargin: 14; verticalCenter: parent.verticalCenter }
            height: 4
            radius: 2
            color: Theme.overlay

            Rectangle {
                height: parent.height
                radius: 2
                width: parent.width * Math.min(1, root.volume / Theme.maxVolume)
                color: pill.tone
                Behavior on width { NumberAnimation { duration: Theme.durFast } }
            }

            // Marca del 100 %
            Rectangle {
                x: parent.width / Theme.maxVolume - 1
                anchors.verticalCenter: parent.verticalCenter
                width: 2
                height: 10
                radius: 1
                color: Theme.fgDim
            }
        }

        Label {
            id: value
            anchors { right: parent.right; rightMargin: 20; verticalCenter: parent.verticalCenter }
            width: 40
            horizontalAlignment: Text.AlignRight
            mono: true
            text: root.muted ? "mute" : Math.round(root.volume * 100)
            color: Theme.fgMuted
        }
    }
}
