import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Services.Pipewire
import Quickshell.Wayland
import qs.config
import qs.services
import qs.widgets

// Centro de control (Super+C o el boton de ajustes de la barra).
// Volumen y micro · ajustes rapidos · accesos directos. Esc o clic fuera cierra.
PanelWindow {
    id: root

    readonly property bool open: Ui.panel === "control"
    property var targetScreen: Quickshell.screens[0]
    screen: targetScreen
    onOpenChanged: if (open) {
        const fm = Hyprland.focusedMonitor;
        targetScreen = Quickshell.screens.find(s => fm && s.name === fm.name) ?? Quickshell.screens[0];
        Controls.recheck();
        card.forceActiveFocus();
    }

    visible: open || card.opacity > 0
    color: "transparent"
    anchors { top: true; bottom: true; left: true; right: true }
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "hyprshell-control"
    WlrLayershell.keyboardFocus: open ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    MouseArea { anchors.fill: parent; onClicked: Ui.close() }

    function run(cmd) { Ui.close(); Quickshell.execDetached(cmd); }

    Rectangle {
        id: card
        anchors { top: parent.top; right: parent.right; topMargin: Theme.barHeight + Theme.gap * 2; rightMargin: Theme.gap + 4 }
        width: 404
        height: content.implicitHeight + 36
        radius: Theme.radius + 4
        color: Theme.alpha(Theme.bg, 0.9)
        border.width: 1
        border.color: Theme.alpha(Theme.overlay, 0.7)
        focus: true
        Keys.onEscapePressed: Ui.close()

        opacity: root.open ? 1 : 0
        transform: Translate {
            y: root.open ? 0 : -14
            Behavior on y { NumberAnimation { duration: Theme.durNormal; easing.type: Easing.BezierSpline; easing.bezierCurve: Theme.curve } }
        }
        Behavior on opacity { NumberAnimation { duration: Theme.durNormal } }
        MouseArea { anchors.fill: parent }

        Column {
            id: content
            anchors { left: parent.left; right: parent.right; top: parent.top; margins: 18 }
            spacing: 16

            // ---- Cabecera: usuario, tiempo encendido, bloquear, energia ----
            Item {
                width: parent.width
                height: 44
                Rectangle {
                    id: avatar
                    width: 40; height: 40; radius: 20
                    color: Theme.alpha(Theme.accent, 0.16)
                    anchors.verticalCenter: parent.verticalCenter
                    Icon { anchors.centerIn: parent; code: 0xf329; font.pixelSize: 20; color: Theme.accent }
                }
                Column {
                    anchors { left: avatar.right; leftMargin: 12; verticalCenter: parent.verticalCenter }
                    spacing: 1
                    Label { text: Quickshell.env("USER") || ""; font.weight: Font.DemiBold; font.pixelSize: 14 }
                    Label { text: "encendido " + SysInfo.uptime; color: Theme.fgDim; font.pixelSize: Theme.fontSizeSmall }
                }
                Row {
                    anchors { right: parent.right; verticalCenter: parent.verticalCenter }
                    spacing: 6
                    RoundButton { code: 0xf023; tip: "Bloquear"; onClicked: root.run(["loginctl", "lock-session"]) }
                    RoundButton { code: 0xf011; tip: "Energía"; danger: true; onClicked: Ui.toggle("power") }
                }
            }

            // ---- Volumen y microfono ----
            Column {
                width: parent.width
                spacing: 10
                VolumeSlider { width: parent.width; node: Pipewire.defaultAudioSink; input: false }
                VolumeSlider { width: parent.width; node: Pipewire.defaultAudioSource; input: true }
            }

            // ---- Ajustes rapidos ----
            Grid {
                width: parent.width
                columns: 2
                columnSpacing: 10
                rowSpacing: 10
                readonly property real tileW: (width - columnSpacing) / 2

                Tile {
                    width: parent.tileW; code: Notifs.dnd ? 0xf1f6 : 0xf0f3
                    title: "No molestar"; subtitle: Notifs.dnd ? "solo avisos criticos" : "desactivado"
                    active: Notifs.dnd
                    onClicked: Notifs.dnd = !Notifs.dnd
                }
                Tile {
                    width: parent.tileW; code: 0xf186
                    title: "Luz nocturna"; subtitle: Controls.night ? Controls.nightTemp + " K" : "desactivada"
                    active: Controls.night; available: Controls.has("hyprsunset"); pkg: "hyprsunset"
                    onClicked: Controls.toggleNight()
                }
                Tile {
                    width: parent.tileW; code: 0xf0f4
                    title: "Cafeína"; subtitle: Controls.caffeine ? "sin bloqueo ni apagado" : "desactivada"
                    active: Controls.caffeine; available: Controls.has("systemd-inhibit")
                    onClicked: Controls.toggleCaffeine()
                }
                Tile {
                    width: parent.tileW
                    code: Controls.profile === "performance" ? 0xf0e7 : Controls.profile === "power-saver" ? 0xf06c : 0xf24e
                    title: "Energía"; subtitle: Controls.profileNames[Controls.profile] ?? "..."
                    active: Controls.profile === "performance"; available: Controls.has("powerprofilesctl")
                    onClicked: Controls.cycleProfile()
                }
                Tile {
                    width: parent.tileW; code: 0xf21b
                    title: "AnonSurf"; subtitle: Anon.busy ? "cambiando..." : Anon.active ? "trafico por Tor" : "desactivado"
                    active: Anon.active
                    onClicked: { Ui.close(); Anon.toggle(); }
                }
                Tile {
                    width: parent.tileW; code: 0xf132
                    title: "VPN HTB"; subtitle: SysInfo.vpnIp || (Controls.has("openvpn") ? "desconectada" : "openvpn no instalado")
                    active: SysInfo.vpnIp.length > 0
                    onClicked: if (SysInfo.vpnIp) Quickshell.execDetached(["wl-copy", SysInfo.vpnIp])
                }
                Tile {
                    width: parent.tileW; code: Controls.recording ? 0xf04d : 0xf03d
                    title: Controls.recording ? "Detener" : "Grabar pantalla"
                    subtitle: Controls.recording ? "grabando..." : "monitor actual"
                    active: Controls.recording; danger: Controls.recording
                    available: Controls.has("wf-recorder"); pkg: "wf-recorder"
                    onClicked: { if (!Controls.recording) Ui.close(); Controls.toggleRecording(); }
                }
                Tile {
                    width: parent.tileW; code: 0xf1fb
                    title: "Selector de color"; subtitle: "copia el hex"
                    available: Controls.has("hyprpicker"); pkg: "hyprpicker"
                    onClicked: { Ui.close(); pickDelay.restart(); }
                }
            }

            // ---- Accesos directos ----
            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 10
                RoundButton { code: 0xf125; tip: "Captura de zona"; big: true; onClicked: root.run([Quickshell.env("HOME") + "/.config/hypr/scripts/screenshot.sh", "zona"]) }
                RoundButton { code: 0xf108; tip: "Captura de pantalla"; big: true; onClicked: root.run([Quickshell.env("HOME") + "/.config/hypr/scripts/screenshot.sh", "pantalla"]) }
                RoundButton { code: 0xf0ea; tip: "Portapapeles"; big: true; onClicked: Ui.toggle("clipboard") }
                RoundButton { code: 0xf487; tip: "Paquetes"; big: true; onClicked: Ui.toggle("packages") }
                RoundButton { code: 0xf009; tip: "Vista general"; big: true; onClicked: Ui.toggle("overview") }
                RoundButton { code: 0xf03e; tip: "Fondos"; big: true; onClicked: Ui.toggle("wallpaper") }
            }

            Label {
                anchors.horizontalCenter: parent.horizontalCenter
                text: hoverTip || " "
                color: Theme.fgDim
                font.pixelSize: Theme.fontSizeSmall
            }
        }
    }

    property string hoverTip: ""
    Timer { id: pickDelay; interval: 250; onTriggered: Controls.pickColor() }

    // ==================== Componentes ====================
    component RoundButton: Rectangle {
        id: rb
        property int code
        property string tip
        property bool danger: false
        property bool big: false
        signal clicked()
        width: big ? 50 : 34
        height: width
        radius: width / 2
        color: rbArea.containsMouse ? (danger ? Theme.alpha(Theme.red, 0.18) : Theme.alpha(Theme.accent, 0.16)) : Theme.alpha(Theme.surface2, 0.8)
        Behavior on color { ColorAnimation { duration: Theme.durFast } }
        Icon {
            anchors.centerIn: parent
            code: rb.code
            font.pixelSize: rb.big ? 17 : 14
            color: rbArea.containsMouse ? (rb.danger ? Theme.red : Theme.accent) : Theme.fgMuted
        }
        MouseArea {
            id: rbArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onEntered: root.hoverTip = rb.tip
            onExited: if (root.hoverTip === rb.tip) root.hoverTip = ""
            onClicked: rb.clicked()
        }
    }

    component Tile: Rectangle {
        id: tile
        property int code
        property string title
        property string subtitle
        property bool active: false
        property bool danger: false
        property bool available: true
        property string pkg: ""
        signal clicked()
        height: 62
        radius: Theme.radius
        readonly property color tone: danger ? Theme.red : Theme.accent
        color: !available ? Theme.alpha(Theme.surface, 0.5)
            : active ? Theme.alpha(tone, 0.18)
            : tArea.containsMouse ? Theme.surface2 : Theme.alpha(Theme.surface2, 0.6)
        border.width: active ? 1 : 0
        border.color: Theme.alpha(tone, 0.55)
        Behavior on color { ColorAnimation { duration: Theme.durFast } }
        opacity: available ? 1 : 0.55

        Rectangle {
            id: tIconBox
            anchors { left: parent.left; leftMargin: 12; verticalCenter: parent.verticalCenter }
            width: 36; height: 36; radius: 18
            color: tile.active ? tile.tone : Theme.alpha(Theme.overlay, 0.7)
            Behavior on color { ColorAnimation { duration: Theme.durFast } }
            Icon { anchors.centerIn: parent; code: tile.code; font.pixelSize: 15; color: tile.active ? Theme.bg : Theme.fgMuted }
        }
        Column {
            anchors { left: tIconBox.right; leftMargin: 10; right: parent.right; rightMargin: 10; verticalCenter: parent.verticalCenter }
            spacing: 1
            Label { width: parent.width; elide: Text.ElideRight; text: tile.title; font.weight: Font.DemiBold; color: tile.active ? Theme.fg : Theme.fgMuted }
            Label {
                width: parent.width; elide: Text.ElideRight
                text: tile.available ? tile.subtitle : "no instalado · " + tile.pkg
                color: tile.available ? Theme.fgDim : Theme.yellow
                font.pixelSize: Theme.fontSizeSmall
            }
        }
        MouseArea {
            id: tArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: tile.available ? Qt.PointingHandCursor : Qt.ArrowCursor
            onClicked: if (tile.available) tile.clicked()
        }
    }

    component VolumeSlider: Item {
        id: vs
        property var node
        property bool input: false
        readonly property bool muted: node && node.audio ? node.audio.muted : true
        readonly property real vol: node && node.audio ? node.audio.volume : 0
        height: 34
        PwObjectTracker { objects: [vs.node] }

        Rectangle {
            id: muteBtn
            anchors { left: parent.left; verticalCenter: parent.verticalCenter }
            width: 34; height: 34; radius: 17
            color: muteArea.containsMouse ? Theme.surface2 : "transparent"
            Icon {
                anchors.centerIn: parent
                code: vs.input ? (vs.muted ? 0xf131 : 0xf130) : vs.muted ? 0xf026 : vs.vol < 0.4 ? 0xf027 : 0xf028
                color: vs.muted ? (vs.input ? Theme.red : Theme.fgDim) : vs.vol > 1 ? Theme.yellow : Theme.fgMuted
            }
            MouseArea { id: muteArea; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                onClicked: if (vs.node) vs.node.audio.muted = !vs.node.audio.muted }
        }
        Item {
            id: track
            anchors { left: muteBtn.right; leftMargin: 10; right: valLbl.left; rightMargin: 12; verticalCenter: parent.verticalCenter }
            height: 20
            readonly property real frac: Math.min(1, vs.vol / Theme.maxVolume)
            Rectangle { anchors.verticalCenter: parent.verticalCenter; width: parent.width; height: 6; radius: 3; color: Theme.alpha(Theme.overlay, 0.8) }
            // Marca del 100%
            Rectangle { x: parent.width * (1 / Theme.maxVolume) - 1; anchors.verticalCenter: parent.verticalCenter; width: 2; height: 10; radius: 1; color: Theme.alpha(Theme.fg, 0.25) }
            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                width: Math.max(6, parent.width * track.frac); height: 6; radius: 3
                color: vs.muted ? Theme.fgDim : vs.vol > 1 ? Theme.yellow : Theme.accent
            }
            Rectangle {
                x: parent.width * track.frac - width / 2
                anchors.verticalCenter: parent.verticalCenter
                width: 14; height: 14; radius: 7
                color: Theme.fg
                visible: !vs.muted
            }
            MouseArea {
                anchors.fill: parent
                anchors.margins: -6
                cursorShape: Qt.PointingHandCursor
                function setAt(x) { if (vs.node) vs.node.audio.volume = Math.max(0, Math.min(1, x / track.width)) * Theme.maxVolume; }
                onPressed: e => setAt(e.x - 6)
                onPositionChanged: e => { if (pressed) setAt(e.x - 6); }
                onWheel: e => { if (vs.node) vs.node.audio.volume = Math.max(0, Math.min(Theme.maxVolume, Math.round((vs.vol + (e.angleDelta.y > 0 ? 0.05 : -0.05)) * 20) / 20)); }
            }
        }
        Label {
            id: valLbl
            anchors { right: parent.right; verticalCenter: parent.verticalCenter }
            width: 42
            horizontalAlignment: Text.AlignRight
            mono: true
            text: vs.muted ? "mute" : Math.round(vs.vol * 100) + "%"
            color: vs.vol > 1 ? Theme.yellow : Theme.fgMuted
        }
    }
}
