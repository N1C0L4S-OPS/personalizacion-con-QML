import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Mpris
import Quickshell.Widgets
import qs.config
import qs.widgets

ColumnLayout {
    id: root

    readonly property var player: Mpris.players.values.find(p => p.isPlaying) ?? Mpris.players.values[0] ?? null
    readonly property bool hasTrack: player && player.trackTitle
    spacing: 12

    PopHeader { code: 0xf001; title: "Reproduciendo"; subtitle: root.player ? root.player.identity : "" }

    ClippingRectangle {
        visible: root.hasTrack && art.status === Image.Ready
        Layout.fillWidth: true
        Layout.preferredHeight: width * 0.56
        radius: Theme.radius
        color: Theme.surface
        Image {
            id: art
            anchors.fill: parent
            source: root.player ? root.player.trackArtUrl : ""
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
        }
    }

    ColumnLayout {
        visible: root.hasTrack
        Layout.fillWidth: true
        spacing: 2
        Label { Layout.fillWidth: true; text: root.player ? root.player.trackTitle : ""; font.weight: Font.DemiBold; elide: Text.ElideRight }
        Label { Layout.fillWidth: true; text: root.player ? root.player.trackArtist : ""; color: Theme.fgMuted; elide: Text.ElideRight }
    }

    Row {
        visible: root.hasTrack
        Layout.alignment: Qt.AlignHCenter
        spacing: 22

        component Ctl: Icon {
            id: ctl
            property bool main: false
            signal pressed()
            font.pixelSize: main ? 22 : 16
            color: ctlArea.containsMouse ? Theme.accent : main ? Theme.fg : Theme.fgMuted
            anchors.verticalCenter: parent.verticalCenter
            MouseArea { id: ctlArea; anchors.fill: parent; anchors.margins: -8; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: ctl.pressed() }
        }

        Ctl { code: 0xf048; onPressed: root.player.previous() }
        Ctl { code: root.player && root.player.isPlaying ? 0xf04c : 0xf04b; main: true; onPressed: root.player.togglePlaying() }
        Ctl { code: 0xf051; onPressed: root.player.next() }
    }

    Label {
        visible: !root.hasTrack
        text: "Nada reproduciendose"
        color: Theme.fgDim
    }
}
