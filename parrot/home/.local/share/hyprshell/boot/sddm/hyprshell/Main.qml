import QtQuick
import QtQml.Models

// Inicio de sesion: fondo difuminado, reloj, y contrasena con una barra por caracter
// (mismo lenguaje visual que la pantalla de bloqueo de la shell).
Rectangle {
    id: root

    width: 1920
    height: 1080
    color: config.bg

    // ---- Estado ----
    property int userIndex: userModel.lastIndex >= 0 ? userModel.lastIndex : 0
    // Ultima sesion usada; si no hay, Hyprland
    property int sessionIndex: sessionModel.lastIndex >= 0 ? sessionModel.lastIndex
        : Math.max(0, sessions.findIndex(n => n && n.toLowerCase() === "hyprland"))
    // Etapa: "user" (escribir el usuario) -> "pass" (contrasena con barras)
    property string stage: "user"
    property string userText: ""
    property int ualive: 0
    ListModel { id: uchars }
    // Sugerencia para completar el nombre (como zsh): Tab o flecha derecha
    readonly property string suggestion: {
        if (!userText.length) return "";
        const u = users.find(x => x && x.name.startsWith(userText) && x.name !== userText);
        return u ? u.name.slice(userText.length) : "";
    }
    function uAdd(c) {
        while (uchars.count > ualive) uchars.remove(uchars.count - 1);
        userText += c; uchars.append({ ch: c, live: true }); ualive++;
    }
    function uBack() {
        if (!ualive) return;
        userText = userText.slice(0, -1);
        uchars.setProperty(ualive - 1, "live", false); ualive--; upurge.restart();
    }
    function uClear() {
        userText = "";
        for (let i = 0; i < ualive; i++) uchars.setProperty(i, "live", false);
        ualive = 0; upurge.restart();
    }
    function acceptSuggestion() { for (const c of suggestion) uAdd(c); }
    function toPass() { if (userText.length) stage = "pass"; }
    function toUser() { clearInput(); stage = "user"; }
    Timer { id: upurge; interval: 320; onTriggered: { while (uchars.count > root.ualive) uchars.remove(uchars.count - 1); } }

    property string buffer: ""
    property int alive: 0
    property string phase: "idle"      // idle | checking | fail | ok
    property bool dropping: false
    readonly property bool isPrimary: typeof primaryScreen === "undefined" ? true : primaryScreen

    // Datos de los modelos de SDDM (usuarios y sesiones) leidos con Instantiator
    property var users: []
    property var sessions: []
    Instantiator {
        model: userModel
        delegate: QtObject {
            required property int index
            required property string name
            required property string realName
            Component.onCompleted: { const u = root.users.slice(); u[index] = { name: name, realName: realName }; root.users = u; }
        }
    }
    Instantiator {
        model: sessionModel
        delegate: QtObject {
            required property int index
            required property string name
            Component.onCompleted: { const s = root.sessions.slice(); s[index] = name; root.sessions = s; }
        }
    }
    function userName(i) { return root.users[i] ? root.users[i].name : ""; }
    function realName(i) { const u = root.users[i]; return !u ? "" : (u.realName && u.realName.length ? u.realName : u.name); }
    function sessionName(i) { return root.sessions[i] ?? ""; }

    ListModel { id: bars }

    function addChar(c) {
        while (bars.count > alive) bars.remove(bars.count - 1);
        buffer += c; bars.append({ live: true }); alive++;
    }
    function backspace() {
        if (!alive) return;
        buffer = Array.from(buffer).slice(0, -1).join("");
        bars.setProperty(alive - 1, "live", false); alive--; purge.restart();
    }
    function clearInput() {
        buffer = "";
        for (let i = 0; i < alive; i++) bars.setProperty(i, "live", false);
        alive = 0; purge.restart();
    }
    function submit() {
        if (phase !== "idle" || alive === 0) return;
        phase = "checking";
        sddm.login(userText, buffer, sessionIndex);
    }

    Timer { id: purge; interval: 320; onTriggered: { while (bars.count > root.alive) bars.remove(bars.count - 1); } }
    Timer { id: dropTimer; interval: 480; onTriggered: root.dropping = true }
    Timer { id: failDone; interval: 1150; onTriggered: { root.buffer = ""; root.alive = 0; bars.clear(); root.dropping = false; root.phase = "idle"; } }

    Connections {
        target: sddm
        function onLoginFailed() { root.buffer = ""; root.phase = "fail"; shake.restart(); dropTimer.restart(); failDone.restart(); }
        function onLoginSucceeded() { root.buffer = ""; root.phase = "ok"; }
    }

    FontLoader { id: icons; source: "icons.ttf" }

    // ---- Fondo ----
    Image {
        anchors.fill: parent
        source: config.background
        fillMode: Image.PreserveAspectCrop
        opacity: 0
        Component.onCompleted: opacity = 1
        Behavior on opacity { NumberAnimation { duration: 900; easing.type: Easing.OutCubic } }
    }

    // ---- Reloj ----
    property real clockIn: 0
    Component.onCompleted: { clockIn = 1; input.forceActiveFocus(); }
    Behavior on clockIn { NumberAnimation { duration: 1100; easing.type: Easing.OutExpo } }
    property date now: new Date()
    Timer { interval: 1000; running: true; repeat: true; onTriggered: root.now = new Date() }

    Column {
        anchors.centerIn: parent
        anchors.verticalCenterOffset: -70 - 18 * (1 - root.clockIn)
        spacing: 4
        opacity: root.phase === "ok" ? 0 : root.clockIn
        Behavior on opacity { NumberAnimation { duration: 400 } }

        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 10
            Text {
                id: bigTime
                text: (root.now.getHours() % 12 || 12) + Qt.formatTime(root.now, ":mm")
                font.family: "Inter"; font.pixelSize: 136; font.weight: Font.ExtraLight
                font.letterSpacing: -3 + 10 * (1 - root.clockIn)
                color: config.fg
            }
            Text {
                anchors.baseline: bigTime.baseline
                text: root.now.getHours() < 12 ? "am" : "pm"
                font.family: "Inter"; font.pixelSize: 28; font.weight: Font.Light
                color: config.fgMuted
            }
        }
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: root.now.toLocaleDateString(Qt.locale("es_ES"), "dddd d 'de' MMMM").toLowerCase()
            font.family: "Inter"; font.pixelSize: 17; font.weight: Font.Light; font.letterSpacing: 3
            color: config.fgMuted
        }
    }

    // ---- Usuario + contrasena (solo en el monitor principal) ----
    Item {
        id: input
        visible: root.isPrimary
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 110
        height: 150
        focus: true

        Keys.onPressed: event => {
            event.accepted = true;
            if (root.phase !== "idle") return;
            const k = event.key;
            const enter = k === Qt.Key_Return || k === Qt.Key_Enter;
            const printable = event.text.length > 0 && event.text.charCodeAt(0) >= 32;
            if (root.stage === "user") {
                if (enter) root.toPass();
                else if (k === Qt.Key_Tab || k === Qt.Key_Right) root.acceptSuggestion();
                else if (k === Qt.Key_Backspace) (event.modifiers & Qt.ControlModifier) ? root.uClear() : root.uBack();
                else if (k === Qt.Key_Escape) root.uClear();
                else if (printable && event.text !== " ") root.uAdd(event.text);
            } else {
                if (enter) root.submit();
                else if (k === Qt.Key_Backspace) {
                    if (root.alive === 0) root.toUser();
                    else (event.modifiers & Qt.ControlModifier) ? root.clearInput() : root.backspace();
                }
                else if (k === Qt.Key_Escape) root.alive ? root.clearInput() : root.toUser();
                else if (printable) root.addChar(event.text);
            }
        }

        // Usuario: letras sueltas que suben al aparecer, sugerencia en gris y una linea de luz.
        // Al pasar a la contrasena el nombre sube y se encoge; la linea se contrae en el punto.
        Item {
            id: nameBox
            anchors.horizontalCenter: parent.horizontalCenter
            width: nameRow.width + ghost.width
            height: 46
            readonly property bool asLabel: root.stage === "pass"
            y: asLabel ? -6 : (input.height - height) / 2 - 6
            scale: asLabel ? 0.46 : 1
            opacity: root.phase === "ok" ? 0 : root.clockIn
            Behavior on y { NumberAnimation { duration: 520; easing.type: Easing.OutExpo } }
            Behavior on scale { NumberAnimation { duration: 520; easing.type: Easing.OutExpo } }
            Behavior on opacity { NumberAnimation { duration: 300 } }

            Row {
                id: nameRow
                anchors.verticalCenter: parent.verticalCenter
                Repeater {
                    model: uchars
                    Text {
                        id: chr
                        required property string ch
                        required property bool live
                        property bool born: false
                        text: ch
                        width: live ? implicitWidth : 0
                        font.family: "Inter"; font.pixelSize: 34; font.weight: Font.Light; font.letterSpacing: 6
                        color: nameBox.asLabel ? config.fgMuted : config.fg
                        opacity: born && live ? 1 : 0
                        transform: Translate { y: chr.born && chr.live ? 0 : 12 }
                        Component.onCompleted: born = true
                        Behavior on width { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }
                        Behavior on opacity { NumberAnimation { duration: 260 } }
                        Behavior on color { ColorAnimation { duration: 400 } }
                    }
                }
            }
            Text {
                id: ghost
                anchors.left: nameRow.right
                anchors.verticalCenter: parent.verticalCenter
                text: nameBox.asLabel ? "" : root.suggestion
                font.family: "Inter"; font.pixelSize: 34; font.weight: Font.Light; font.letterSpacing: 6
                color: config.fgDim
                opacity: 0.55
            }
        }

        // Linea de luz bajo el nombre (se contrae hasta ser el punto de la contrasena)
        Rectangle {
            // Centrada bajo lo escrito (no bajo la sugerencia): se estira al escribir
            x: nameBox.asLabel ? (input.width - width) / 2 : nameBox.x + nameRow.width / 2 - width / 2
            y: nameBox.asLabel ? input.height - 30 : nameBox.y + nameBox.height + 8
            Behavior on x { NumberAnimation { duration: 420; easing.type: Easing.OutExpo } }
            height: 1
            radius: 0.5
            width: nameBox.asLabel ? 0 : Math.max(36, nameRow.width + 28)
            color: config.accent
            opacity: nameBox.asLabel ? 0 : 0.75 * root.clockIn
            Behavior on width { NumberAnimation { duration: 420; easing.type: Easing.OutExpo } }
            Behavior on y { NumberAnimation { duration: 520; easing.type: Easing.OutExpo } }
            Behavior on opacity { NumberAnimation { duration: 380 } }
        }

        // Pista discreta (solo al escribir el usuario)
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.bottom
            anchors.topMargin: 6
            text: root.suggestion.length ? "tab  completa   ·   intro  continua" : root.userText.length ? "intro  continua" : "usuario"
            font.family: "Inter"; font.pixelSize: 11; font.letterSpacing: 3
            color: config.fgDim
            opacity: root.stage === "user" ? 0.8 * root.clockIn : 0
            Behavior on opacity { NumberAnimation { duration: 300 } }
        }

        // Barras
        Item {
            id: group
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: 60
            opacity: root.stage === "pass" ? 1 : 0
            Behavior on opacity { NumberAnimation { duration: 360 } }
            property real shakeX: 0
            property real wave: 0
            transform: Translate { x: group.shakeX }

            NumberAnimation on wave { running: root.phase === "checking"; from: 0; to: 1; duration: 1100; loops: Animation.Infinite }

            readonly property color tone: root.phase === "fail" ? config.red : config.accent
            readonly property real step: root.phase === "ok" ? 0 : 14

            Repeater {
                model: bars
                Rectangle {
                    id: bar
                    required property int index
                    required property bool live
                    property bool grown: false
                    property real dropY: 0
                    property real fade: 1
                    x: group.width / 2 + (index - (root.alive - 1) / 2) * group.step - width / 2
                    y: (group.height - height) / 2 + dropY
                    width: 4; radius: 2
                    height: grown && live ? 28 : 0
                    color: group.tone
                    opacity: fade * (live ? 1 : 0) * (root.phase === "ok" ? 0 : 1)
                        * (root.phase === "checking" ? 0.4 + 0.6 * (0.5 + 0.5 * Math.cos(2 * Math.PI * (group.wave - index * 0.07))) : 1)
                    Component.onCompleted: grown = true
                    Behavior on x { NumberAnimation { duration: 260; easing.type: Easing.OutCubic } }
                    Behavior on height { NumberAnimation { duration: 260; easing.type: Easing.OutBack; easing.overshoot: 1.6 } }
                    Behavior on color { ColorAnimation { duration: 160 } }
                    Behavior on opacity { enabled: root.phase !== "checking"; NumberAnimation { duration: 260 } }
                    readonly property bool dropping: root.dropping
                    onDroppingChanged: if (dropping) drop.restart()
                    SequentialAnimation {
                        id: drop
                        PauseAnimation { duration: Math.max(0, bar.index) * 38 }
                        ParallelAnimation {
                            NumberAnimation { target: bar; property: "dropY"; to: 26; duration: 340; easing.type: Easing.InCubic }
                            NumberAnimation { target: bar; property: "fade"; to: 0; duration: 300 }
                        }
                    }
                }
            }

            // Acceso concedido: linea de luz
            Rectangle {
                anchors.centerIn: parent
                height: 2; radius: 1
                color: config.accent
                width: root.phase === "ok" ? group.width * 0.42 : 4
                opacity: root.phase === "ok" ? 1 : 0
                Behavior on width { NumberAnimation { duration: 620; easing.type: Easing.OutExpo } }
                Behavior on opacity { NumberAnimation { duration: 200 } }
            }

            // Punto que respira cuando no hay nada escrito
            Rectangle {
                anchors.centerIn: parent
                width: 5; height: 5; radius: 2.5
                color: config.fgMuted
                property real breath: 0.25
                opacity: root.alive === 0 && root.phase === "idle" ? breath : 0
                SequentialAnimation on breath {
                    loops: Animation.Infinite
                    NumberAnimation { to: 0.55; duration: 1400; easing.type: Easing.InOutSine }
                    NumberAnimation { to: 0.2; duration: 1400; easing.type: Easing.InOutSine }
                }
            }
        }

        SequentialAnimation {
            id: shake
            NumberAnimation { target: group; property: "shakeX"; to: 16; duration: 45 }
            NumberAnimation { target: group; property: "shakeX"; to: -14; duration: 70 }
            NumberAnimation { target: group; property: "shakeX"; to: 10; duration: 65 }
            NumberAnimation { target: group; property: "shakeX"; to: -7; duration: 60 }
            NumberAnimation { target: group; property: "shakeX"; to: 4; duration: 55 }
            NumberAnimation { target: group; property: "shakeX"; to: 0; duration: 50 }
        }

        // Bloq Mayus
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.bottom
            anchors.topMargin: 24
            visible: keyboard.capsLock
            text: "bloq mayus activado"
            font.family: "Inter"; font.pixelSize: 12; font.letterSpacing: 2
            color: config.yellow
        }
    }

    // ---- Abajo: sesion (izquierda) y energia (derecha) ----
    component Pill: Rectangle {
        id: pill
        property string label
        property string icon
        property color hover: config.accent
        signal clicked()
        implicitWidth: row.implicitWidth + 24
        implicitHeight: 34
        radius: 17
        color: area.containsMouse ? Qt.rgba(1, 1, 1, 0.07) : "transparent"
        Behavior on color { ColorAnimation { duration: 160 } }
        Row {
            id: row
            anchors.centerIn: parent
            spacing: 8
            Text { visible: pill.icon.length > 0; text: pill.icon; font.family: icons.name; font.pixelSize: 15; color: area.containsMouse ? pill.hover : config.fgMuted; anchors.verticalCenter: parent.verticalCenter }
            Text { visible: pill.label.length > 0; text: pill.label; font.family: "Inter"; font.pixelSize: 13; font.letterSpacing: 1; color: area.containsMouse ? config.fg : config.fgMuted; anchors.verticalCenter: parent.verticalCenter }
        }
        MouseArea { id: area; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: pill.clicked() }
    }

    Pill {
        visible: root.isPrimary
        anchors.left: parent.left; anchors.bottom: parent.bottom; anchors.margins: 28
        icon: ""
        label: root.sessionName(root.sessionIndex)
        onClicked: root.sessionIndex = (root.sessionIndex + 1) % sessionModel.count
        opacity: root.clockIn
    }

    Row {
        visible: root.isPrimary
        anchors.right: parent.right; anchors.bottom: parent.bottom; anchors.margins: 28
        spacing: 4
        opacity: root.clockIn
        Pill { icon: ""; visible: sddm.canSuspend; onClicked: sddm.suspend() }
        Pill { icon: ""; visible: sddm.canReboot; onClicked: sddm.reboot() }
        Pill { icon: ""; hover: config.red; visible: sddm.canPowerOff; onClicked: sddm.powerOff() }
    }
}
