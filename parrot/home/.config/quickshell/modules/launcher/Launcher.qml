import QtQuick
import Quickshell
import Quickshell.Widgets
import qs.config
import qs.services
import qs.widgets

// Lanzador de aplicaciones. Escribir filtra · Flechas/Tab navegan · Enter abre · Esc cierra
Overlay {
    id: root

    name: "launcher"
    cardWidth: 600
    cardHeight: 468

    readonly property string query: search.text.trim().toLowerCase()
    readonly property var results: {
        const seen = new Set();
        return DesktopEntries.applications.values
            .filter(e => !e.noDisplay && !seen.has(e.name) && seen.add(e.name))
            .map(e => ({ e, s: score(e, query) }))
            .filter(x => x.s > 0)
            .sort((a, b) => b.s - a.s || a.e.name.localeCompare(b.e.name))
            .map(x => x.e);
    }

    // Puntuacion: prefijo del nombre > prefijo de palabra > contiene > metadatos > subsecuencia
    function score(e, q) {
        if (!q)
            return 1;
        const n = e.name.toLowerCase();
        if (n.startsWith(q))
            return 100;
        if (n.split(/[\s\-_.]+/).some(w => w.startsWith(q)))
            return 80;
        if (n.includes(q))
            return 60;
        const meta = [e.genericName, e.comment, (e.keywords || []).join(" ")].join(" ").toLowerCase();
        if (meta.includes(q))
            return 40;
        let i = 0;
        for (const c of n)
            if (c === q[i]) i++;
        return i === q.length ? 20 : 0;
    }

    function launch(entry) {
        if (!entry)
            return;
        entry.execute();
        Ui.close();
    }

    onOpenChanged: if (open) {
        search.text = "";
        list.currentIndex = 0;
        search.forceActiveFocus();
    }

    // Buscador
    Item {
        id: header
        anchors { top: parent.top; left: parent.left; right: parent.right }
        height: 60

        Icon {
            id: searchIcon
            code: 0xf002
            color: Theme.accent
            anchors { left: parent.left; leftMargin: 22; verticalCenter: parent.verticalCenter }
        }

        TextInput {
            id: search
            anchors { left: searchIcon.right; leftMargin: 14; right: parent.right; rightMargin: 22; verticalCenter: parent.verticalCenter }
            font.family: Theme.fontSans
            font.pixelSize: 16
            color: Theme.fg
            selectionColor: Theme.alpha(Theme.accent, 0.35)
            selectedTextColor: Theme.fg
            clip: true
            onTextChanged: list.currentIndex = 0

            Label {
                anchors.verticalCenter: parent.verticalCenter
                visible: !search.text
                text: "Buscar aplicaciones"
                color: Theme.fgDim
                font.pixelSize: 16
            }

            Keys.onPressed: e => {
                list.mouseSel = false;
                if (e.key === Qt.Key_Escape) Ui.close();
                else if (e.key === Qt.Key_Down || e.key === Qt.Key_Tab) list.incrementCurrentIndex();
                else if (e.key === Qt.Key_Up || e.key === Qt.Key_Backtab) list.decrementCurrentIndex();
                else if (e.key === Qt.Key_Return || e.key === Qt.Key_Enter) root.launch(root.results[list.currentIndex]);
                else return;
                e.accepted = true;
            }
        }
    }

    Rectangle {
        id: divider
        anchors { top: header.bottom; left: parent.left; right: parent.right }
        height: 1
        color: Theme.alpha(Theme.overlay, 0.6)
    }

    ListView {
        id: list
        anchors { top: divider.bottom; bottom: parent.bottom; left: parent.left; right: parent.right; margins: 8 }
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
        keyNavigationWraps: true

        highlight: Rectangle {
            radius: Theme.radiusSmall
            color: Theme.alpha(Theme.accent, 0.12)
            Rectangle {
                anchors { left: parent.left; verticalCenter: parent.verticalCenter }
                width: 3
                height: parent.height * 0.5
                radius: 2
                color: Theme.accent
            }
        }

        delegate: Item {
            id: row

            required property var modelData
            required property int index
            readonly property bool current: ListView.isCurrentItem

            width: ListView.view.width
            height: 48

            // Icono del tema; las herramientas CLI (Icon=xterm, ~300 en Parrot) o apps
            // sin icono usan un glifo de terminal sobrio
            Item {
                id: appIcon
                readonly property string src: row.modelData.icon === "xterm" ? "" : Quickshell.iconPath(row.modelData.icon, true)
                anchors { left: parent.left; leftMargin: 16; verticalCenter: parent.verticalCenter }
                width: 28
                height: 28

                IconImage {
                    anchors.fill: parent
                    visible: appIcon.src.length > 0
                    source: appIcon.src
                    asynchronous: true
                }
                Rectangle {
                    anchors.fill: parent
                    visible: appIcon.src.length === 0
                    radius: Theme.radiusSmall
                    color: Theme.surface2
                    Icon {
                        anchors.centerIn: parent
                        code: 0xf120
                        font.pixelSize: 14
                        color: row.current ? Theme.accent : Theme.fgDim
                    }
                }
            }

            Column {
                anchors { left: appIcon.right; leftMargin: 14; right: parent.right; rightMargin: 16; verticalCenter: parent.verticalCenter }
                spacing: 1
                Label {
                    width: parent.width
                    text: row.modelData.name
                    color: row.current ? Theme.fg : Theme.fgMuted
                    elide: Text.ElideRight
                }
                Label {
                    width: parent.width
                    visible: text.length > 0
                    text: row.modelData.genericName || row.modelData.comment || ""
                    color: Theme.fgDim
                    font.pixelSize: Theme.fontSizeSmall
                    elide: Text.ElideRight
                }
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                // Solo al MOVER el raton: si la lista se desplaza bajo un cursor quieto, no salta
                onPositionChanged: e => {
                    const g = mapToItem(null, e.x, e.y);
                    if (g.x === list.lastMouse.x && g.y === list.lastMouse.y) return;
                    list.lastMouse = g;
                    list.mouseSel = true;
                    list.currentIndex = row.index;
                }
                onClicked: root.launch(row.modelData)
            }
        }

        Label {
            anchors.centerIn: parent
            visible: list.count === 0
            text: "Sin resultados"
            color: Theme.fgDim
        }
    }
}
