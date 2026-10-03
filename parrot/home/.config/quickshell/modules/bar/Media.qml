import QtQuick
import Quickshell
import Quickshell.Services.Mpris
import qs.config
import qs.services
import qs.widgets

// Reproductor activo (Spotify, navegador, mpv...). Sin reproduccion muestra la fecha completa.
// Clic: desplegable con caratula y controles · Central: play/pausa · Derecho: siguiente
Rectangle {
    id: root

    required property var screen
    property real maxWidth: 420   // la barra lo limita al espacio libre real
    readonly property var player: Mpris.players.values.find(p => p.isPlaying) ?? Mpris.players.values[0] ?? null
    readonly property bool hasTrack: player && player.trackTitle
    readonly property bool open: Ui.popout === "media" && Ui.popoutScreen === screen

    // Limpia el ruido tipico de YouTube/Spotify: "(Official Video)", "VEVO", "- Topic", artista repetido
    function clean(s) {
        return (s || "")
            .replace(/\s*[\(\[][^\)\]]*(official|oficial|video|lyric|letra|audio|visuali[sz]er|hd|4k|remaster)[^\)\]]*[\)\]]/gi, "")
            .replace(/\s*-\s*Topic$/i, "")
            .replace(/VEVO$/i, "")
            .replace(/\s{2,}/g, " ")
            .trim();
    }
    readonly property string artist: clean(player ? player.trackArtist : "")
    readonly property string title: {
        let t = clean(player ? player.trackTitle : "");
        // "Artista - Cancion" con el mismo artista: no repetirlo
        const m = t.match(/^(.+?)\s+[-–]\s+(.+)$/);
        if (m && artist && (m[1].toLowerCase().replace(/\s/g, "").includes(artist.toLowerCase().replace(/\s/g, ""))
                            || artist.toLowerCase().replace(/\s/g, "").includes(m[1].toLowerCase().replace(/\s/g, ""))))
            return m[2] + "\u0001" + m[1];   // marca: el artista real es m[1]
        return t;
    }
    readonly property string line: {
        if (!hasTrack)
            return "";
        const parts = title.split("\u0001");
        const a = parts.length > 1 ? parts[1] : artist;
        return (a ? a + "  ·  " : "") + parts[0];
    }

    implicitWidth: content.implicitWidth + 20
    implicitHeight: 26
    radius: Theme.radiusSmall
    color: open ? Theme.alpha(Theme.accent, 0.14) : area.containsMouse ? Theme.surface2 : "transparent"
    Behavior on color { ColorAnimation { duration: Theme.durFast } }

    SystemClock { id: clock; precision: SystemClock.Minutes }

    Row {
        id: content
        anchors.centerIn: parent
        spacing: 8

        Icon {
            visible: root.hasTrack
            code: root.player && root.player.isPlaying ? 0xf04c : 0xf04b
            color: Theme.accent
            font.pixelSize: Theme.fontSize - 1
        }
        // Titulo: se corta con "..." si no cabe; al pasar el raton se desliza para leerlo entero
        Item {
            id: titleBox
            visible: root.hasTrack
            readonly property real avail: Math.max(60, root.maxWidth - 20 - 8 - 14)
            readonly property bool overflow: fullTitle.implicitWidth > avail
            width: Math.min(fullTitle.implicitWidth, avail)
            height: fullTitle.implicitHeight
            anchors.verticalCenter: parent.verticalCenter
            clip: true

            Label {
                id: fullTitle
                visible: titleBox.overflow && area.containsMouse
                text: root.line
                color: Theme.fg
                x: 0
                SequentialAnimation on x {
                    running: fullTitle.visible
                    loops: Animation.Infinite
                    PauseAnimation { duration: 700 }
                    NumberAnimation {
                        to: titleBox.width - fullTitle.implicitWidth
                        duration: Math.max(1, (fullTitle.implicitWidth - titleBox.width) * 28)
                        easing.type: Easing.InOutSine
                    }
                    PauseAnimation { duration: 1200 }
                    NumberAnimation { to: 0; duration: 400; easing.type: Easing.OutCubic }
                }
                onVisibleChanged: if (!visible) x = 0
            }
            Label {
                visible: !fullTitle.visible
                width: titleBox.width
                elide: Text.ElideRight
                text: root.line
                color: root.open || area.containsMouse ? Theme.fg : Theme.fgMuted
            }
        }
        Label {
            visible: !root.hasTrack
            text: clock.date.toLocaleDateString(Qt.locale("es_ES"), "dddd d 'de' MMMM")
            color: Theme.fgDim
        }
    }

    MouseArea {
        id: area
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton
        cursorShape: Qt.PointingHandCursor
        onClicked: e => {
            if (e.button === Qt.LeftButton)
                Ui.togglePopout("media", root.screen, root.mapToItem(null, root.width / 2, 0).x);
            else if (root.hasTrack)
                e.button === Qt.MiddleButton ? root.player.togglePlaying() : root.player.next();
        }
    }
}
