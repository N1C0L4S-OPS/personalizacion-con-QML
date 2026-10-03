import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import Quickshell.Widgets
import qs.config
import qs.services
import qs.widgets

// Vista general (Super+Tab): en cada monitor, sus 5 espacios con las ventanas EN VIVO.
//  Clic en ventana: ir · clic en espacio: cambiar · arrastrar ventana a otro espacio: moverla
//  Clic central: cerrar ventana · ←/→ espacio · Tab ventana · Enter ir · Supr cerrar · Esc salir
Variants {
    model: Quickshell.screens

    PanelWindow {
        id: win

        required property var modelData
        screen: modelData

        readonly property var hmon: Hyprland.monitorFor(modelData)
        readonly property bool open: Ui.panel === "overview"
        readonly property bool focusedMon: !!Hyprland.focusedMonitor && !!hmon && Hyprland.focusedMonitor.name === hmon.name
        readonly property bool primary: modelData.name === Theme.primaryMonitor
        readonly property var wsIds: primary ? [1, 2, 3, 4, 5] : [6, 7, 8, 9, 10]
        readonly property int activeIndex: Math.max(0, wsIds.indexOf(hmon && hmon.activeWorkspace ? hmon.activeWorkspace.id : wsIds[0]))

        // Geometria de las miniaturas
        readonly property real margin: 64
        readonly property real gap: 22
        readonly property real cardW: (width - 2 * margin - 4 * gap) / 5
        readonly property real cardH: cardW * (hmon ? hmon.height / hmon.width : 9 / 16)
        readonly property real scaleF: hmon ? cardW / hmon.width : 0.18

        // Estado
        property int selWs: 0
        property int selWin: -1
        property var hovered: null          // ventana bajo el raton (para la ficha inferior)
        property int tick: 0                // fuerza a recalcular listas tras mover/cerrar
        property var dragSrc: null          // ventana arrastrada
        property point dragPos: Qt.point(0, 0)
        property point dragOff: Qt.point(0, 0)
        property size dragSize: Qt.size(0, 0)

        property real shown: open ? 1 : 0
        Behavior on shown { NumberAnimation { duration: Theme.durNormal; easing.type: Easing.BezierSpline; easing.bezierCurve: Theme.curve } }

        visible: open || shown > 0.01
        color: "transparent"
        anchors { top: true; bottom: true; left: true; right: true }
        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "hyprshell-overview"
        WlrLayershell.keyboardFocus: open && focusedMon ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

        onOpenChanged: if (open) {
            Hyprland.refreshToplevels();
            selWs = activeIndex;
            selWin = -1;
            hovered = null;
            keys.forceActiveFocus();
        }

        function windowsFor(wsId) {
            tick;
            return Hyprland.toplevels.values.filter(t => t.workspace && t.workspace.id === wsId && t.lastIpcObject && t.lastIpcObject.at);
        }
        function addr(t) { return "0x" + t.address; }
        function refreshSoon() { refreshTimer.restart(); }
        Timer { id: refreshTimer; interval: 160; onTriggered: { Hyprland.refreshToplevels(); win.tick++; } }

        function goWorkspace(wsId) { Hyprland.dispatch("workspace " + wsId); Ui.close(); }
        function goWindow(t) { Hyprland.dispatch("focuswindow address:" + addr(t)); Ui.close(); }
        function closeWindow(t) { Hyprland.dispatch("closewindow address:" + addr(t)); win.selWin = -1; refreshSoon(); }
        function moveWindow(t, wsId) { Hyprland.dispatch("movetoworkspacesilent " + wsId + ",address:" + addr(t)); refreshSoon(); }

        readonly property var selWindows: { tick; return windowsFor(wsIds[selWs]); }
        readonly property var info: hovered ?? (selWin >= 0 ? selWindows[selWin] ?? null : null)

        function iconFor(t) {
            const cls = t && t.lastIpcObject ? t.lastIpcObject.class || "" : "";
            const e = DesktopEntries.heuristicLookup(cls);
            return e && e.icon ? Quickshell.iconPath(e.icon, true) : "";
        }

        // Teclado (solo en el monitor con el foco)
        Item {
            id: keys
            focus: true
            Keys.onPressed: e => {
                const n = win.selWindows.length;
                if (e.key === Qt.Key_Escape) Ui.close();
                else if (e.key === Qt.Key_Right) { win.selWs = (win.selWs + 1) % 5; win.selWin = -1; }
                else if (e.key === Qt.Key_Left) { win.selWs = (win.selWs + 4) % 5; win.selWin = -1; }
                else if (e.key === Qt.Key_Tab || e.key === Qt.Key_Down) { if (n) win.selWin = (win.selWin + 1) % n; }
                else if (e.key === Qt.Key_Backtab || e.key === Qt.Key_Up) { if (n) win.selWin = (win.selWin - 1 + n) % n; }
                else if (e.key === Qt.Key_Return || e.key === Qt.Key_Enter) {
                    if (win.selWin >= 0 && win.selWindows[win.selWin]) win.goWindow(win.selWindows[win.selWin]);
                    else win.goWorkspace(win.wsIds[win.selWs]);
                }
                else if (e.key === Qt.Key_Delete) { if (win.selWin >= 0 && win.selWindows[win.selWin]) win.closeWindow(win.selWindows[win.selWin]); }
                else if (e.key >= Qt.Key_1 && e.key <= Qt.Key_5) win.goWorkspace(win.wsIds[e.key - Qt.Key_1]);
                else return;
                e.accepted = true;
            }
        }

        // Velo de fondo (Hyprland difumina esta capa)
        Rectangle {
            anchors.fill: parent
            color: Theme.alpha(Theme.bg, 0.55)
            opacity: win.shown
            MouseArea { anchors.fill: parent; onClicked: Ui.close() }
        }

        // ---- Fila de espacios ----
        Row {
            id: cards
            x: win.margin
            y: (win.height - win.cardH) / 2 - 40
            spacing: win.gap

            Repeater {
                model: 5

                Item {
                    id: card
                    required property int index
                    readonly property int wsId: win.wsIds[index]
                    readonly property bool active: index === win.activeIndex
                    readonly property bool sel: index === win.selWs
                    readonly property bool dropHere: win.dragSrc !== null && win.dropIndex === index

                    width: win.cardW
                    height: win.cardH

                    // Entrada escalonada
                    opacity: Math.min(1, Math.max(0, win.shown * 1.4 - index * 0.08))
                    scale: 0.92 + 0.08 * opacity
                    transform: Translate { y: (1 - card.opacity) * 18 }

                    ClippingRectangle {
                        id: screenBox
                        anchors.fill: parent
                        radius: Theme.radius
                        color: Theme.bg

                        // El fondo de pantalla (miniatura de themegen)
                        Image {
                            anchors.fill: parent
                            source: Theme.wallpaper ? "file://" + Quickshell.env("HOME") + "/.cache/hyprshell/thumbs/" + Theme.wallpaper.split("/").pop() + ".jpg" : ""
                            fillMode: Image.PreserveAspectCrop
                            asynchronous: true
                            opacity: 0.75
                        }

                        // Clic en zona vacia: ir a ese espacio
                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            onEntered: win.hovered = null
                            onClicked: win.goWorkspace(card.wsId)
                        }

                        // Ventanas en vivo, en su posicion real
                        Repeater {
                            model: win.windowsFor(card.wsId)

                            Item {
                                id: thumb
                                required property var modelData
                                required property int index
                                readonly property var ipc: modelData.lastIpcObject
                                readonly property bool selected: card.sel && win.selWin === index
                                readonly property bool isDragged: win.dragSrc === modelData

                                x: ((ipc.at[0] - (win.hmon ? win.hmon.x : 0)) * win.scaleF)
                                y: ((ipc.at[1] - (win.hmon ? win.hmon.y : 0)) * win.scaleF)
                                width: Math.max(8, ipc.size[0] * win.scaleF)
                                height: Math.max(8, ipc.size[1] * win.scaleF)
                                z: ipc.floating ? 2 : 1
                                opacity: isDragged ? 0.25 : 1

                                ClippingRectangle {
                                    anchors.fill: parent
                                    radius: 4
                                    color: Theme.surface

                                    ScreencopyView {
                                        id: live
                                        anchors.fill: parent
                                        captureSource: win.visible ? thumb.modelData.wayland : null
                                        live: win.open
                                        constraintSize: Qt.size(thumb.width * 2, thumb.height * 2)
                                    }
                                    // Sin captura (aun cargando): icono de la app
                                    IconImage {
                                        anchors.centerIn: parent
                                        visible: !live.hasContent
                                        implicitSize: Math.min(28, parent.height * 0.5)
                                        source: win.iconFor(thumb.modelData)
                                    }
                                }

                                // Borde: seleccion / raton
                                Rectangle {
                                    anchors.fill: parent
                                    radius: 4
                                    color: "transparent"
                                    border.width: thumb.selected || tArea.containsMouse ? 2 : 1
                                    border.color: thumb.selected ? Theme.accent : tArea.containsMouse ? Theme.alpha(Theme.fg, 0.7) : Theme.alpha(Theme.bg, 0.6)
                                }

                                // Icono de la app abajo
                                Rectangle {
                                    anchors { horizontalCenter: parent.horizontalCenter; bottom: parent.bottom; bottomMargin: 4 }
                                    visible: live.hasContent && thumb.height > 40
                                    width: 22; height: 22; radius: 6
                                    color: Theme.alpha(Theme.bg, 0.8)
                                    IconImage { anchors.centerIn: parent; implicitSize: 16; source: win.iconFor(thumb.modelData) }
                                }

                                MouseArea {
                                    id: tArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    acceptedButtons: Qt.LeftButton | Qt.MiddleButton
                                    cursorShape: pressed ? Qt.ClosedHandCursor : Qt.PointingHandCursor
                                    property point start
                                    property bool dragging: false
                                    onEntered: win.hovered = thumb.modelData
                                    onExited: if (win.hovered === thumb.modelData) win.hovered = null
                                    onPressed: e => { start = Qt.point(e.x, e.y); dragging = false; }
                                    onPositionChanged: e => {
                                        if (!pressed || e.buttons !== Qt.LeftButton) return;
                                        if (!dragging && Math.hypot(e.x - start.x, e.y - start.y) > 6) {
                                            dragging = true;
                                            win.dragSrc = thumb.modelData;
                                            win.dragSize = Qt.size(thumb.width, thumb.height);
                                            win.dragOff = Qt.point(start.x, start.y);
                                        }
                                        if (dragging) win.dragPos = mapToItem(win.contentItem, e.x, e.y);
                                    }
                                    onReleased: e => {
                                        if (dragging) {
                                            const target = win.dropIndex;
                                            if (target >= 0 && win.wsIds[target] !== card.wsId) win.moveWindow(thumb.modelData, win.wsIds[target]);
                                            win.dragSrc = null;
                                            dragging = false;
                                        }
                                    }
                                    onClicked: e => {
                                        if (dragging) return;
                                        if (e.button === Qt.MiddleButton) win.closeWindow(thumb.modelData);
                                        else win.goWindow(thumb.modelData);
                                    }
                                }
                            }
                        }
                    }

                    // Marco: activo (acento), seleccionado, destino al arrastrar
                    Rectangle {
                        anchors.fill: parent
                        radius: Theme.radius
                        color: card.dropHere ? Theme.alpha(Theme.accent, 0.12) : "transparent"
                        border.width: card.active || card.dropHere ? 2 : 1
                        border.color: card.dropHere ? Theme.accent : card.active ? Theme.alpha(Theme.accent, 0.85)
                            : card.sel ? Theme.alpha(Theme.fg, 0.55) : Theme.alpha(Theme.overlay, 0.9)
                        Behavior on border.color { ColorAnimation { duration: Theme.durFast } }
                    }

                    // Numero del espacio
                    Rectangle {
                        anchors { left: parent.left; top: parent.top; margins: 8 }
                        width: 24; height: 24; radius: 12
                        color: card.active ? Theme.accent : Theme.alpha(Theme.bg, 0.75)
                        Label {
                            anchors.centerIn: parent
                            text: card.wsId === 10 ? "0" : card.wsId
                            mono: true
                            font.weight: Font.DemiBold
                            color: card.active ? Theme.bg : Theme.fgMuted
                        }
                    }
                    // Vacio
                    Label {
                        anchors.centerIn: parent
                        visible: win.windowsFor(card.wsId).length === 0
                        text: "vacío"
                        color: Theme.alpha(Theme.fg, 0.5)
                        font.pixelSize: Theme.fontSizeSmall
                        font.letterSpacing: 2
                    }
                }
            }
        }

        // Que espacio queda bajo el cursor al arrastrar
        readonly property int dropIndex: {
            if (!dragSrc) return -1;
            for (let i = 0; i < 5; i++) {
                const x0 = cards.x + i * (cardW + gap);
                if (dragPos.x >= x0 && dragPos.x <= x0 + cardW && dragPos.y >= cards.y && dragPos.y <= cards.y + cardH) return i;
            }
            return -1;
        }

        // Fantasma de la ventana arrastrada
        ClippingRectangle {
            visible: win.dragSrc !== null
            x: win.dragPos.x - win.dragOff.x
            y: win.dragPos.y - win.dragOff.y
            width: win.dragSize.width
            height: win.dragSize.height
            radius: 4
            z: 10
            opacity: 0.9
            border.width: 2
            border.color: Theme.accent
            ScreencopyView {
                anchors.fill: parent
                captureSource: win.dragSrc ? win.dragSrc.wayland : null
                live: true
            }
        }

        // ---- Ficha inferior: ventana seleccionada / bajo el raton ----
        Column {
            anchors { horizontalCenter: parent.horizontalCenter; top: cards.bottom; topMargin: 34 }
            spacing: 6
            opacity: win.shown

            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 10
                height: 26
                IconImage {
                    anchors.verticalCenter: parent.verticalCenter
                    visible: !!win.info
                    implicitSize: 22
                    source: win.info ? win.iconFor(win.info) : ""
                }
                Label {
                    anchors.verticalCenter: parent.verticalCenter
                    width: Math.min(implicitWidth, win.width * 0.6)
                    elide: Text.ElideRight
                    text: win.info ? win.info.title : "Espacio " + (win.wsIds[win.selWs] === 10 ? 0 : win.wsIds[win.selWs])
                    font.pixelSize: 17
                    font.weight: Font.Medium
                }
            }
            Label {
                anchors.horizontalCenter: parent.horizontalCenter
                text: win.info ? (win.info.lastIpcObject.class || "") + "  ·  espacio " + (win.info.workspace.id === 10 ? 0 : win.info.workspace.id)
                     : win.selWindows.length + (win.selWindows.length === 1 ? " ventana" : " ventanas")
                color: Theme.fgDim
                font.pixelSize: Theme.fontSizeSmall
            }
        }

        // Pista de teclas (solo en el monitor con el foco)
        Label {
            anchors { horizontalCenter: parent.horizontalCenter; bottom: parent.bottom; bottomMargin: 36 }
            visible: win.focusedMon
            opacity: win.shown * 0.9
            text: "←  →  espacio     Tab  ventana     Enter  ir     arrastrar  mover     clic central / Supr  cerrar     Esc  salir"
            color: Theme.fgDim
            font.pixelSize: Theme.fontSizeSmall
        }
    }
}
