import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import qs.config
import qs.services
import qs.widgets

// Instalador de paquetes (Super+I), al estilo de Omarchy.
//  1. Fuentes compatibles con el sistema (APT, Flatpak)  ->  2. Buscador con la descripcion abajo
// Enter instala · Supr desinstala · Tab solo instalados · Esc vuelve / cierra
Overlay {
    id: root

    name: "packages"
    cardWidth: 900
    cardHeight: 660

    readonly property string helper: Quickshell.env("HOME") + "/.local/bin/hyprshell-pkg"
    property string stage: "sources"          // sources | search
    property var srcs: []
    property int srcIndex: 0
    readonly property var source: srcs[srcIndex] ?? null
    property var items: []                      // catalogo de la fuente elegida
    property bool loading: false
    property bool onlyInstalled: false
    property var results: []
    property var info: null
    readonly property var current: results[list.currentIndex] ?? null

    function fmt(n) { return Number(n).toLocaleString(Qt.locale("es_ES"), "f", 0); }

    onOpenChanged: if (open) {
        stage = "sources";
        sourcesProc.running = true;
        keys.forceActiveFocus();
    }

    function openSource(i) {
        if (!srcs[i]) return;
        srcIndex = i;
        stage = "search";
        items = [];
        results = [];
        info = null;
        onlyInstalled = false;
        search.text = "";
        loading = true;
        listProc.command = [helper, "list", srcs[i].id];
        listProc.running = true;
        search.forceActiveFocus();
    }

    function back() {
        stage = "sources";
        keys.forceActiveFocus();
    }

    // ---- Filtro ----
    function compute() {
        const q = search.text.trim().toLowerCase();
        const pool = onlyInstalled ? items.filter(x => x.i) : items;
        let out;
        if (!q) {
            out = (onlyInstalled || source?.id === "flatpak") ? pool.slice().sort((a, b) => a.l.localeCompare(b.l)).slice(0, 400) : [];
        } else {
            const toks = q.split(/\s+/);
            const scored = [];
            for (const x of pool) {
                let s = 0;
                if (x.l === q || x.k === q) s = 1000;
                else if (x.l.startsWith(q)) s = 700 - x.l.length;
                else if (x.l.split(/[\s\-_.]+/).some(w => w.startsWith(q))) s = 500 - x.l.length;
                else if (x.l.includes(q) || x.k.includes(q)) s = 400 - x.l.indexOf(q);
                else {
                    const hay = x.l + " " + x.dl;
                    if (toks.every(t => hay.includes(t))) s = 120;
                    else if (x.dl.includes(q)) s = 80;
                }
                if (s > 0) scored.push({ x, s: s + (x.i ? 5 : 0) });
            }
            scored.sort((a, b) => b.s - a.s || a.x.l.localeCompare(b.x.l));
            out = scored.slice(0, 300).map(o => o.x);
        }
        results = out;
        list.currentIndex = 0;
        infoTimer.restart();
    }

    function act(remove) {
        const it = current;
        if (!it || !source) return;
        if (remove && !it.i) return;
        if (!remove && it.i) return;
        Quickshell.execDetached(["kitty", "--class", "hyprshell-pkg", "--title", "Paquetes",
            "-o", "remember_window_size=no", helper, "run", remove ? "remove" : "install", source.id, it.id]);
        Ui.close();
    }

    Process {
        id: sourcesProc
        command: [root.helper, "sources"]
        stdout: StdioCollector { onStreamFinished: { try { root.srcs = JSON.parse(text); } catch (e) {} } }
    }
    Process {
        id: listProc
        stdout: StdioCollector {
            onStreamFinished: {
                const flat = root.source?.id === "flatpak";
                root.items = text.split("\n").filter(l => l.length).map(l => {
                    const p = l.split("\t");
                    const id = flat ? p[4] : p[0];
                    return { n: p[0], d: p[1] || "", i: p[2] === "1", v: p[3] || "", id, l: p[0].toLowerCase(), k: id.toLowerCase(), dl: (p[1] || "").toLowerCase() };
                });
                root.loading = false;
                root.compute();
            }
        }
    }
    Process {
        id: infoProc
        stdout: StdioCollector { onStreamFinished: { try { root.info = JSON.parse(text); } catch (e) { root.info = null; } } }
    }
    Timer { id: filterTimer; interval: 70; onTriggered: root.compute() }
    Timer {
        id: infoTimer
        interval: 140
        onTriggered: {
            if (!root.current || !root.source) { root.info = null; return; }
            infoProc.running = false;
            infoProc.command = [root.helper, "info", root.source.id, root.current.id];
            infoProc.running = true;
        }
    }

    // =====================================================================
    // Etapa 1: fuentes
    // =====================================================================
    Item {
        id: keys
        anchors.fill: parent
        visible: root.stage === "sources"
        focus: root.stage === "sources"
        Keys.onPressed: e => {
            if (e.key === Qt.Key_Escape) Ui.close();
            else if (e.key === Qt.Key_Right || e.key === Qt.Key_Tab) root.srcIndex = (root.srcIndex + 1) % Math.max(1, root.srcs.length);
            else if (e.key === Qt.Key_Left || e.key === Qt.Key_Backtab) root.srcIndex = (root.srcIndex + root.srcs.length - 1) % Math.max(1, root.srcs.length);
            else if (e.key === Qt.Key_Return || e.key === Qt.Key_Enter) root.openSource(root.srcIndex);
            else if (e.key >= Qt.Key_1 && e.key <= Qt.Key_9) root.openSource(e.key - Qt.Key_1);
            else return;
            e.accepted = true;
        }

        Column {
            anchors { top: parent.top; topMargin: 44; horizontalCenter: parent.horizontalCenter }
            spacing: 6
            Label { anchors.horizontalCenter: parent.horizontalCenter; text: "Instalar paquetes"; font.pixelSize: 26; font.weight: Font.Light }
            Label { anchors.horizontalCenter: parent.horizontalCenter; text: "Elige de donde instalar"; color: Theme.fgDim }
        }

        Row {
            anchors.centerIn: parent
            anchors.verticalCenterOffset: 10
            spacing: 22

            Repeater {
                model: root.srcs
                Rectangle {
                    id: card
                    required property var modelData
                    required property int index
                    readonly property bool sel: root.srcIndex === index
                    width: 360
                    height: 280
                    radius: Theme.radius + 4
                    color: sel ? Theme.alpha(Theme.accent, 0.08) : Theme.alpha(Theme.surface, 0.6)
                    border.width: 1
                    border.color: sel ? Theme.alpha(Theme.accent, 0.7) : Theme.alpha(Theme.overlay, 0.6)
                    scale: sel ? 1.0 : 0.96
                    Behavior on scale { NumberAnimation { duration: Theme.durNormal; easing.type: Easing.BezierSpline; easing.bezierCurve: Theme.curve } }
                    Behavior on color { ColorAnimation { duration: Theme.durFast } }
                    Behavior on border.color { ColorAnimation { duration: Theme.durFast } }

                    Column {
                        anchors { left: parent.left; right: parent.right; top: parent.top; margins: 26 }
                        spacing: 10
                        Icon {
                            code: card.modelData.id === "apt" ? 0xf329 : 0xf324
                            font.pixelSize: 44
                            color: card.sel ? Theme.accent : Theme.fgMuted
                        }
                        Item { width: 1; height: 4 }
                        Row {
                            spacing: 10
                            Label { text: card.modelData.name; font.pixelSize: 22; font.weight: Font.DemiBold }
                            Label { anchors.baseline: parent.children[0].baseline; text: card.modelData.subtitle; color: Theme.fgDim }
                        }
                        Label { text: card.modelData.detail; color: Theme.fgMuted; width: parent.width; wrapMode: Text.WordWrap }
                        Item { width: 1; height: 6 }
                        Row {
                            spacing: 18
                            Column {
                                Label { text: root.fmt(card.modelData.count); font.pixelSize: 18; color: Theme.fg }
                                Label { text: "paquetes"; color: Theme.fgDim; font.pixelSize: Theme.fontSizeSmall }
                            }
                            Column {
                                Label { text: root.fmt(card.modelData.installed); font.pixelSize: 18; color: Theme.accent }
                                Label { text: "instalados"; color: Theme.fgDim; font.pixelSize: Theme.fontSizeSmall }
                            }
                        }
                    }
                    Row {
                        anchors { left: parent.left; bottom: parent.bottom; margins: 26 }
                        spacing: 6
                        Icon { code: card.modelData.sudo ? 0xf023 : 0xf09c; font.pixelSize: 11; color: card.modelData.sudo ? Theme.yellow : Theme.green }
                        Label { text: card.modelData.sudo ? "pide contraseña" : "sin contraseña"; font.pixelSize: Theme.fontSizeSmall; color: Theme.fgDim }
                    }
                    Label {
                        anchors { right: parent.right; bottom: parent.bottom; margins: 26 }
                        text: card.index + 1
                        mono: true
                        color: Theme.fgDim
                    }
                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onEntered: root.srcIndex = card.index
                        onClicked: root.openSource(card.index)
                    }
                }
            }
        }

        Label {
            anchors { bottom: parent.bottom; bottomMargin: 22; horizontalCenter: parent.horizontalCenter }
            text: "←  →  elegir      Enter  abrir      Esc  cerrar"
            color: Theme.fgDim
            font.pixelSize: Theme.fontSizeSmall
        }
    }

    // =====================================================================
    // Etapa 2: buscador
    // =====================================================================
    Item {
        anchors.fill: parent
        visible: root.stage === "search"

        // Cabecera: fuente + buscador + filtro
        Item {
            id: header
            anchors { top: parent.top; left: parent.left; right: parent.right }
            height: 60

            Rectangle {
                id: chip
                anchors { left: parent.left; leftMargin: 14; verticalCenter: parent.verticalCenter }
                height: 32
                width: chipRow.implicitWidth + 22
                radius: 16
                color: chipArea.containsMouse ? Theme.surface2 : Theme.alpha(Theme.accent, 0.1)
                Row {
                    id: chipRow
                    anchors.centerIn: parent
                    spacing: 8
                    Icon { code: 0xf060; font.pixelSize: 11; color: Theme.fgDim; anchors.verticalCenter: parent.verticalCenter }
                    Icon { code: root.source?.id === "apt" ? 0xf329 : 0xf324; color: Theme.accent; anchors.verticalCenter: parent.verticalCenter }
                    Label { text: root.source?.name ?? ""; font.weight: Font.DemiBold; anchors.verticalCenter: parent.verticalCenter }
                }
                MouseArea { id: chipArea; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: root.back() }
            }

            TextInput {
                id: search
                anchors { left: chip.right; leftMargin: 16; right: filterPill.left; rightMargin: 12; verticalCenter: parent.verticalCenter }
                font.family: Theme.fontSans
                font.pixelSize: 16
                color: Theme.fg
                selectionColor: Theme.alpha(Theme.accent, 0.35)
                clip: true
                onTextChanged: filterTimer.restart()

                Label {
                    anchors.verticalCenter: parent.verticalCenter
                    visible: !search.text
                    text: root.loading ? "Cargando el catalogo..." : "Buscar en " + root.fmt(root.items.length) + " paquetes"
                    color: Theme.fgDim
                    font.pixelSize: 16
                }

                Keys.onPressed: e => {
                    list.mouseSel = false;
                    if (e.key === Qt.Key_Escape) { search.text ? search.text = "" : root.back(); }
                    else if (e.key === Qt.Key_Down) list.incrementCurrentIndex();
                    else if (e.key === Qt.Key_Up) list.decrementCurrentIndex();
                    else if (e.key === Qt.Key_PageDown) list.currentIndex = Math.min(list.count - 1, list.currentIndex + 8);
                    else if (e.key === Qt.Key_PageUp) list.currentIndex = Math.max(0, list.currentIndex - 8);
                    else if (e.key === Qt.Key_Tab) { root.onlyInstalled = !root.onlyInstalled; root.compute(); }
                    else if (e.key === Qt.Key_Return || e.key === Qt.Key_Enter) root.act(false);
                    else if (e.key === Qt.Key_Delete) root.act(true);
                    else return;
                    e.accepted = true;
                }
            }

            Rectangle {
                id: filterPill
                anchors { right: parent.right; rightMargin: 14; verticalCenter: parent.verticalCenter }
                height: 28
                width: fRow.implicitWidth + 20
                radius: 14
                color: root.onlyInstalled ? Theme.alpha(Theme.accent, 0.16) : "transparent"
                border.width: 1
                border.color: root.onlyInstalled ? Theme.alpha(Theme.accent, 0.6) : Theme.alpha(Theme.overlay, 0.8)
                Row {
                    id: fRow
                    anchors.centerIn: parent
                    spacing: 6
                    Icon { code: 0xf058; font.pixelSize: 11; color: root.onlyInstalled ? Theme.accent : Theme.fgDim; anchors.verticalCenter: parent.verticalCenter }
                    Label { text: "Instalados"; font.pixelSize: Theme.fontSizeSmall; color: root.onlyInstalled ? Theme.fg : Theme.fgDim; anchors.verticalCenter: parent.verticalCenter }
                }
                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: { root.onlyInstalled = !root.onlyInstalled; root.compute(); search.forceActiveFocus(); } }
            }
        }

        Rectangle { id: div1; anchors { top: header.bottom; left: parent.left; right: parent.right } height: 1; color: Theme.alpha(Theme.overlay, 0.6) }

        // Resultados
        ListView {
            id: list
            anchors { top: div1.bottom; bottom: preview.top; left: parent.left; right: parent.right; margins: 8 }
            clip: true
            model: root.results
            spacing: 2
            boundsBehavior: Flickable.StopAtBounds
            highlightMoveDuration: Theme.durFast
        // La lista se desplaza con suavidad antes de que la seleccion toque el borde
        // Teclado: se desplaza suave antes del borde. Raton: no se desplaza solo (evita tirones)
        property bool mouseSel: false
        property point lastMouse: Qt.point(-1, -1)
        highlightRangeMode: mouseSel ? ListView.NoHighlightRange : ListView.ApplyRange
        preferredHighlightBegin: 56
        preferredHighlightEnd: height - 56
            highlightResizeDuration: 0
            onCurrentIndexChanged: infoTimer.restart()

            highlight: Rectangle {
                radius: Theme.radiusSmall
                color: Theme.alpha(Theme.accent, 0.12)
                Rectangle { anchors { left: parent.left; verticalCenter: parent.verticalCenter } width: 3; height: parent.height * 0.5; radius: 2; color: Theme.accent }
            }

            delegate: Item {
                id: row
                required property var modelData
                required property int index
                readonly property bool cur: ListView.isCurrentItem
                width: ListView.view.width
                height: 44

                Icon {
                    id: rowIcon
                    anchors { left: parent.left; leftMargin: 16; verticalCenter: parent.verticalCenter }
                    code: row.modelData.i ? 0xf058 : (root.source?.id === "apt" ? 0xf487 : 0xf1b2)
                    color: row.modelData.i ? Theme.accent : (row.cur ? Theme.fgMuted : Theme.fgDim)
                    font.pixelSize: 14
                }
                Label {
                    id: rowName
                    anchors { left: rowIcon.right; leftMargin: 14; verticalCenter: parent.verticalCenter }
                    width: Math.min(implicitWidth, 260)
                    elide: Text.ElideRight
                    text: row.modelData.n
                    color: row.cur ? Theme.fg : Theme.fgMuted
                    font.weight: row.cur ? Font.DemiBold : Font.Normal
                }
                Label {
                    anchors { left: rowName.right; leftMargin: 14; right: rowRight.left; rightMargin: 12; verticalCenter: parent.verticalCenter }
                    elide: Text.ElideRight
                    text: row.modelData.d
                    color: Theme.fgDim
                    font.pixelSize: Theme.fontSizeSmall
                }
                Row {
                    id: rowRight
                    anchors { right: parent.right; rightMargin: 16; verticalCenter: parent.verticalCenter }
                    spacing: 10
                    Label { visible: row.modelData.v.length > 0; text: row.modelData.v; mono: true; font.pixelSize: Theme.fontSizeSmall - 1; color: Theme.fgDim; anchors.verticalCenter: parent.verticalCenter }
                    Rectangle {
                        visible: row.modelData.i
                        anchors.verticalCenter: parent.verticalCenter
                        height: 20; width: instLbl.implicitWidth + 14; radius: 10
                        color: Theme.alpha(Theme.accent, 0.14)
                        Label { id: instLbl; anchors.centerIn: parent; text: "instalado"; font.pixelSize: Theme.fontSizeSmall - 1; color: Theme.accent }
                    }
                }
                // Solo selecciona al MOVER el raton (si la lista cambia bajo un cursor quieto, no salta)
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onPositionChanged: e => {
                    const g = mapToItem(null, e.x, e.y);
                    if (g.x === list.lastMouse.x && g.y === list.lastMouse.y) return;
                    list.lastMouse = g;
                    list.mouseSel = true;
                    list.currentIndex = row.index;
                }
                    onClicked: list.currentIndex = row.index
                    onDoubleClicked: root.act(row.modelData.i)
                }
            }

            // Estados vacios
            Column {
                anchors.centerIn: parent
                visible: list.count === 0
                spacing: 8
                Icon { anchors.horizontalCenter: parent.horizontalCenter; code: root.loading ? 0xf110 : 0xf002; font.pixelSize: 26; color: Theme.fgDim }
                Label {
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: Theme.fgDim
                    text: root.loading ? "Cargando..."
                        : search.text ? "Sin resultados para «" + search.text + "»"
                        : "Escribe para buscar · Tab muestra los instalados"
                }
            }
        }

        // Vista previa del paquete seleccionado
        Rectangle {
            id: preview
            anchors { left: parent.left; right: parent.right; bottom: footer.top }
            height: 200
            color: Theme.alpha(Theme.surface, 0.7)
            Rectangle { anchors { top: parent.top; left: parent.left; right: parent.right } height: 1; color: Theme.alpha(Theme.overlay, 0.6) }

            readonly property var d: root.info && root.current && root.info.id === root.current.id ? root.info : null
            visible: root.current !== null
            opacity: d ? 1 : 0.55
            Behavior on opacity { NumberAnimation { duration: Theme.durFast } }

            Item {
                id: bigIcon
                anchors { left: parent.left; top: parent.top; margins: 22 }
                width: 56; height: 56
                IconImage {
                    anchors.fill: parent
                    visible: (preview.d?.icon ?? "").length > 0
                    source: preview.d?.icon ? "file://" + preview.d.icon : ""
                    asynchronous: true
                }
                Rectangle {
                    anchors.fill: parent
                    visible: !(preview.d?.icon)
                    radius: Theme.radius
                    color: Theme.surface2
                    Icon { anchors.centerIn: parent; code: root.source?.id === "apt" ? 0xf487 : 0xf1b2; font.pixelSize: 22; color: Theme.accent }
                }
            }

            Column {
                anchors { left: bigIcon.right; leftMargin: 18; right: parent.right; rightMargin: 22; top: parent.top; topMargin: 18 }
                spacing: 6

                Row {
                    spacing: 10
                    Label { text: preview.d?.name ?? root.current?.n ?? ""; font.pixelSize: 17; font.weight: Font.DemiBold }
                    Label { anchors.baseline: parent.children[0].baseline; text: preview.d?.version ?? ""; mono: true; color: Theme.fgDim; font.pixelSize: Theme.fontSizeSmall }
                }
                Label { width: parent.width; elide: Text.ElideRight; text: preview.d?.summary || root.current?.d || ""; color: Theme.fgMuted }

                // Datos: tamano, seccion, desarrollador, web
                Row {
                    spacing: 16
                    component Meta: Row {
                        property int code
                        property string text
                        visible: text.length > 0
                        spacing: 6
                        Icon { code: parent.code; font.pixelSize: 11; color: Theme.fgDim; anchors.verticalCenter: parent.verticalCenter }
                        Label { text: parent.text; font.pixelSize: Theme.fontSizeSmall; color: Theme.fgDim; anchors.verticalCenter: parent.verticalCenter }
                    }
                    Meta { code: 0xf0a0; text: preview.d?.size ?? "" }
                    Meta { code: 0xf02b; text: preview.d?.section ?? "" }
                    Meta { code: 0xf007; text: preview.d?.developer ?? "" }
                    Meta { code: 0xf0ac; text: (preview.d?.homepage ?? "").replace(/^https?:\/\//, "").replace(/\/$/, "") }
                }

                Label {
                    width: parent.width
                    text: preview.d?.description ?? ""
                    wrapMode: Text.WordWrap
                    maximumLineCount: 4
                    elide: Text.ElideRight
                    color: Theme.fgDim
                    font.pixelSize: Theme.fontSizeSmall
                    lineHeight: 1.15
                }
            }
        }

        // Pie: accion disponible
        Item {
            id: footer
            anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
            height: 40
            Rectangle { anchors { top: parent.top; left: parent.left; right: parent.right } height: 1; color: Theme.alpha(Theme.overlay, 0.6) }
            Label {
                anchors { left: parent.left; leftMargin: 20; verticalCenter: parent.verticalCenter }
                text: root.results.length ? root.fmt(root.results.length) + (root.results.length >= 300 ? "+" : "") + " resultados" : ""
                color: Theme.fgDim
                font.pixelSize: Theme.fontSizeSmall
            }
            Row {
                anchors { right: parent.right; rightMargin: 20; verticalCenter: parent.verticalCenter }
                spacing: 18
                component Hint: Row {
                    property string k
                    property string t
                    property color c: Theme.fgMuted
                    spacing: 6
                    Rectangle {
                        anchors.verticalCenter: parent.verticalCenter
                        height: 18; width: kl.implicitWidth + 10; radius: 4
                        color: Theme.surface2
                        Label { id: kl; anchors.centerIn: parent; text: parent.parent.k; mono: true; font.pixelSize: Theme.fontSizeSmall - 1; color: Theme.fgMuted }
                    }
                    Label { anchors.verticalCenter: parent.verticalCenter; text: parent.t; font.pixelSize: Theme.fontSizeSmall; color: parent.c }
                }
                Hint { visible: !!root.current && !root.current.i; k: "Enter"; t: "instalar"; c: Theme.accent }
                Hint { visible: !!root.current && root.current.i; k: "Supr"; t: "desinstalar"; c: Theme.red }
                Hint { k: "Tab"; t: root.onlyInstalled ? "todos" : "instalados" }
                Hint { k: "Esc"; t: "volver" }
            }
        }
    }

    // qs ipc call packages open flatpak   ·   qs ipc call packages query steam
    IpcHandler {
        target: "packages"
        function open(source: string): void {
            if (Ui.panel !== "packages") Ui.toggle("packages");
            const i = root.srcs.findIndex(s => s.id === source);
            if (i >= 0) root.openSource(i);
        }
        function query(text: string): void {
            if (root.stage !== "search") return;
            search.text = text;
        }
    }
}
