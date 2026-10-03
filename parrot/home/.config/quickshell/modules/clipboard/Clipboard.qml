import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import qs.config
import qs.services
import qs.widgets

// Historial del portapapeles (Super+V). Datos en RAM: $XDG_RUNTIME_DIR/hyprshell-clip (hyprshell-clip).
// Escribir filtra · ↑↓ elegir · Enter pegar · Shift+Enter solo copiar · Supr borrar · Ctrl+Supr vaciar · Esc cerrar
Overlay {
    id: root

    name: "clipboard"
    cardWidth: 720
    cardHeight: 620

    readonly property string helper: Quickshell.env("HOME") + "/.local/bin/hyprshell-clip"
    readonly property string dir: (Quickshell.env("XDG_RUNTIME_DIR") || "/tmp") + "/hyprshell-clip"
    property var entries: []
    readonly property string query: search.text.trim().toLowerCase()
    readonly property var results: query ? entries.filter(e => e.type === "text"
        ? (e.text.toLowerCase().includes(query) || (e.kind || "").toLowerCase().includes(query))
        : "imagen".includes(query)) : entries
    readonly property var current: results[list.currentIndex] ?? null
    property string targetClass: ""      // ventana donde se pegara

    FileView {
        id: index
        path: root.dir + "/index.json"
        watchChanges: true
        onFileChanged: reload()
        onLoaded: { try { root.entries = JSON.parse(text()); } catch (e) { root.entries = []; } }
        onLoadFailed: root.entries = []
    }

    onOpenChanged: if (open) {
        targetClass = Hyprland.activeToplevel && Hyprland.activeToplevel.lastIpcObject ? Hyprland.activeToplevel.lastIpcObject.class || "" : "";
        index.reload();
        search.text = "";
        list.currentIndex = 0;
        search.forceActiveFocus();
    }

    function ago(t) {
        const s = Math.max(0, Date.now() / 1000 - t);
        if (s < 60) return "ahora";
        if (s < 3600) return Math.floor(s / 60) + " min";
        if (s < 86400) return Math.floor(s / 3600) + " h";
        return Math.floor(s / 86400) + " d";
    }

    function use(e, paste) {
        if (!e) return;
        Quickshell.execDetached([helper, "copy", e.id]);
        Ui.close();
        if (paste) pasteTimer.restart();
    }
    // Pega en la ventana anterior: en terminales Ctrl+Shift+V, en el resto Ctrl+V
    Timer {
        id: pasteTimer
        interval: 180
        onTriggered: {
            const term = /kitty|alacritty|foot|wezterm|konsole|terminal/i.test(root.targetClass);
            Hyprland.dispatch(term ? "sendshortcut CTRL SHIFT, V, activewindow" : "sendshortcut CTRL, V, activewindow");
        }
    }
    function remove(e) { if (e) Quickshell.execDetached([helper, "delete", e.id]); }

    // ---- Buscador ----
    Item {
        id: header
        anchors { top: parent.top; left: parent.left; right: parent.right }
        height: 60
        Icon { id: sIcon; code: 0xf0ea; color: Theme.accent; anchors { left: parent.left; leftMargin: 22; verticalCenter: parent.verticalCenter } }
        TextInput {
            id: search
            anchors { left: sIcon.right; leftMargin: 14; right: count.left; rightMargin: 12; verticalCenter: parent.verticalCenter }
            font.family: Theme.fontSans
            font.pixelSize: 16
            color: Theme.fg
            selectionColor: Theme.alpha(Theme.accent, 0.35)
            clip: true
            onTextChanged: list.currentIndex = 0
            Label {
                anchors.verticalCenter: parent.verticalCenter
                visible: !search.text
                text: "Buscar en lo copiado"
                color: Theme.fgDim
                font.pixelSize: 16
            }
            Keys.onPressed: e => {
                list.mouseSel = false;
                if (e.key === Qt.Key_Escape) Ui.close();
                else if (e.key === Qt.Key_Down || e.key === Qt.Key_Tab) list.incrementCurrentIndex();
                else if (e.key === Qt.Key_Up || e.key === Qt.Key_Backtab) list.decrementCurrentIndex();
                else if (e.key === Qt.Key_Return || e.key === Qt.Key_Enter) root.use(root.current, !(e.modifiers & Qt.ShiftModifier));
                else if (e.key === Qt.Key_Delete) {
                    if (e.modifiers & Qt.ControlModifier) Quickshell.execDetached([root.helper, "clear"]);
                    else root.remove(root.current);
                }
                else return;
                e.accepted = true;
            }
        }
        Label {
            id: count
            anchors { right: parent.right; rightMargin: 22; verticalCenter: parent.verticalCenter }
            text: root.entries.length ? root.results.length + " / " + root.entries.length : ""
            color: Theme.fgDim
            font.pixelSize: Theme.fontSizeSmall
        }
    }
    Rectangle { id: div; anchors { top: header.bottom; left: parent.left; right: parent.right } height: 1; color: Theme.alpha(Theme.overlay, 0.6) }

    // ---- Lista ----
    ListView {
        id: list
        anchors { top: div.bottom; bottom: preview.top; left: parent.left; right: parent.right; margins: 8 }
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
        highlightResizeDuration: Theme.durFast
        keyNavigationWraps: true

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
            readonly property bool img: modelData.type === "image"
            width: ListView.view.width
            height: img ? 76 : 40

            Icon {
                id: rIcon
                anchors { left: parent.left; leftMargin: 16; verticalCenter: parent.verticalCenter }
                code: row.img ? 0xf03e : 0xf0f6
                font.pixelSize: 13
                color: row.cur ? Theme.accent : Theme.fgDim
            }
            // Imagen
            Image {
                visible: row.img
                anchors { left: rIcon.right; leftMargin: 14; verticalCenter: parent.verticalCenter }
                height: 64
                width: 240
                fillMode: Image.PreserveAspectFit
                horizontalAlignment: Image.AlignLeft
                source: row.img ? "file://" + row.modelData.file : ""
                asynchronous: true
                sourceSize.height: 128
            }
            // Texto (primera linea, monoespaciada)
            Label {
                visible: !row.img
                anchors { left: rIcon.right; leftMargin: 14; right: tags.left; rightMargin: 12; verticalCenter: parent.verticalCenter }
                text: row.img ? "" : row.modelData.text.trim().split("\n")[0]
                mono: true
                elide: Text.ElideRight
                color: row.cur ? Theme.fg : Theme.fgMuted
            }
            Row {
                id: tags
                anchors { right: parent.right; rightMargin: 16; verticalCenter: parent.verticalCenter }
                spacing: 10
                Rectangle {
                    visible: (row.modelData.kind || "").length > 0
                    anchors.verticalCenter: parent.verticalCenter
                    height: 20; width: kLbl.implicitWidth + 14; radius: 10
                    color: Theme.alpha(Theme.accent, 0.14)
                    Label { id: kLbl; anchors.centerIn: parent; text: row.modelData.kind || ""; font.pixelSize: Theme.fontSizeSmall - 1; color: Theme.accent }
                }
                Label { anchors.verticalCenter: parent.verticalCenter; text: root.ago(row.modelData.time); color: Theme.fgDim; font.pixelSize: Theme.fontSizeSmall }
            }
            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                acceptedButtons: Qt.LeftButton | Qt.MiddleButton
                onPositionChanged: e => {
                    const g = mapToItem(null, e.x, e.y);
                    if (g.x === list.lastMouse.x && g.y === list.lastMouse.y) return;
                    list.lastMouse = g;
                    list.mouseSel = true;
                    list.currentIndex = row.index;
                }
                onClicked: e => e.button === Qt.MiddleButton ? root.remove(row.modelData) : root.use(row.modelData, true)
            }
        }

        Column {
            anchors.centerIn: parent
            visible: list.count === 0
            spacing: 8
            Icon { anchors.horizontalCenter: parent.horizontalCenter; code: 0xf0ea; font.pixelSize: 26; color: Theme.fgDim }
            Label {
                anchors.horizontalCenter: parent.horizontalCenter
                text: root.entries.length ? "Nada coincide con «" + search.text + "»" : "Todavia no has copiado nada"
                color: Theme.fgDim
            }
        }
    }

    // ---- Vista previa ----
    Rectangle {
        id: preview
        anchors { left: parent.left; right: parent.right; bottom: footer.top }
        height: 190
        color: Theme.alpha(Theme.surface, 0.7)
        visible: root.current !== null
        Rectangle { anchors { top: parent.top; left: parent.left; right: parent.right } height: 1; color: Theme.alpha(Theme.overlay, 0.6) }

        Flickable {
            anchors { fill: parent; margins: 18 }
            visible: root.current && root.current.type === "text"
            clip: true
            contentHeight: full.implicitHeight
            Text {
                id: full
                width: parent.width
                text: root.current && root.current.type === "text" ? root.current.text : ""
                wrapMode: Text.WrapAnywhere
                font.family: Theme.fontMono
                font.pixelSize: Theme.fontSizeSmall + 1
                color: Theme.fg
                textFormat: Text.PlainText
            }
        }
        Image {
            anchors { fill: parent; margins: 14 }
            visible: root.current && root.current.type === "image"
            source: root.current && root.current.type === "image" ? "file://" + root.current.file : ""
            fillMode: Image.PreserveAspectFit
            asynchronous: true
        }
    }

    // ---- Pie ----
    Item {
        id: footer
        anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
        height: 40
        Rectangle { anchors { top: parent.top; left: parent.left; right: parent.right } height: 1; color: Theme.alpha(Theme.overlay, 0.6) }
        Row {
            anchors { left: parent.left; leftMargin: 18; verticalCenter: parent.verticalCenter }
            spacing: 6
            Icon { code: 0xf023; font.pixelSize: 10; color: Theme.fgDim; anchors.verticalCenter: parent.verticalCenter }
            Label { text: "solo en memoria · se borra al reiniciar"; color: Theme.fgDim; font.pixelSize: Theme.fontSizeSmall; anchors.verticalCenter: parent.verticalCenter }
        }
        Row {
            anchors { right: parent.right; rightMargin: 18; verticalCenter: parent.verticalCenter }
            spacing: 16
            component Hint: Row {
                property string k
                property string t
                spacing: 6
                Rectangle {
                    anchors.verticalCenter: parent.verticalCenter
                    height: 18; width: kl.implicitWidth + 10; radius: 4; color: Theme.surface2
                    Label { id: kl; anchors.centerIn: parent; text: parent.parent.k; mono: true; font.pixelSize: Theme.fontSizeSmall - 1; color: Theme.fgMuted }
                }
                Label { anchors.verticalCenter: parent.verticalCenter; text: parent.t; font.pixelSize: Theme.fontSizeSmall; color: Theme.fgMuted }
            }
            Hint { k: "Enter"; t: "pegar" }
            Hint { k: "⇧ Enter"; t: "copiar" }
            Hint { k: "Supr"; t: "borrar" }
            Hint { k: "Esc"; t: "cerrar" }
        }
    }
}
