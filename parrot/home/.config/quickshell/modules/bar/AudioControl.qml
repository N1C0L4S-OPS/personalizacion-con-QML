import QtQuick
import Quickshell.Services.Pipewire
import qs.config
import qs.widgets

// Control de audio: salida (por defecto) o microfono (input: true).
// Rueda: ajustar (hasta Theme.maxVolume) · Clic: silenciar. Por encima de 100% se marca en amarillo.
Item {
    id: root

    property bool input: false
    readonly property var node: input ? Pipewire.defaultAudioSource : Pipewire.defaultAudioSink
    readonly property bool muted: node && node.audio ? node.audio.muted : true
    readonly property int volume: node && node.audio ? Math.round(node.audio.volume * 100) : 0
    readonly property bool boosted: volume > 100

    implicitWidth: content.implicitWidth
    implicitHeight: content.implicitHeight

    PwObjectTracker { objects: [root.node] }

    Row {
        id: content
        spacing: 5

        Icon {
            code: root.input ? (root.muted ? 0xf131 : 0xf130)
                : root.muted ? 0xf026 : root.volume < 40 ? 0xf027 : 0xf028
            color: root.muted ? (root.input ? Theme.red : Theme.fgDim) : root.boosted ? Theme.yellow : Theme.fgMuted
        }
        Label {
            mono: true
            text: root.muted ? "mute" : root.volume + "%"
            color: root.muted ? Theme.fgDim : root.boosted ? Theme.yellow : Theme.fgMuted
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: if (root.node) root.node.audio.muted = !root.node.audio.muted
        onWheel: e => {
            if (!root.node) return;
            const v = root.node.audio.volume + (e.angleDelta.y > 0 ? 0.05 : -0.05);
            root.node.audio.volume = Math.max(0, Math.min(Theme.maxVolume, Math.round(v * 20) / 20));
        }
    }
}
