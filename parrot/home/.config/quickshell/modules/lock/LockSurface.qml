import QtQuick
import QtQuick.Effects
import Quickshell
import qs.config

// Lo que se ve en cada monitor bloqueado: captura difuminada, reloj y barras.
Item {
    id: root

    required property var ctx
    required property string screenName

    property real reveal: 0    // 0 = escritorio nitido, 1 = todo difuminado
    property real clockIn: 0   // entrada del reloj

    focus: true
    Keys.onPressed: event => root.ctx.key(event)

    Component.onCompleted: {
        forceActiveFocus();
        intro.start();
    }

    readonly property bool unlocking: ctx.phase === "unlocking"
    onUnlockingChanged: if (unlocking) {
        intro.stop();
        outro.start();
    }

    ParallelAnimation {
        id: intro
        NumberAnimation {
            target: root; property: "reveal"; from: 0; to: 1; duration: 1100
            easing.type: Easing.BezierSpline; easing.bezierCurve: Theme.curve
        }
        SequentialAnimation {
            PauseAnimation { duration: 380 }
            NumberAnimation {
                target: root; property: "clockIn"; from: 0; to: 1; duration: 900
                easing.type: Easing.BezierSpline; easing.bezierCurve: Theme.curve
            }
        }
    }

    // Desbloqueo: el reloj se eleva y se va; el desenfoque se disuelve hacia el escritorio real
    ParallelAnimation {
        id: outro
        NumberAnimation { target: root; property: "clockIn"; to: 0; duration: 420; easing.type: Easing.InCubic }
        SequentialAnimation {
            PauseAnimation { duration: 180 }
            NumberAnimation { target: root; property: "reveal"; to: 0; duration: 820; easing.type: Easing.InOutCubic }
        }
    }

    // ---- Fondo: captura del monitor, difuminada ----
    Image {
        id: shot
        anchors.fill: parent
        source: root.screenName ? "file://" + root.ctx.shotPath(root.screenName) : ""
        cache: false
        asynchronous: false
        fillMode: Image.PreserveAspectCrop
        visible: false
    }

    MultiEffect {
        anchors.fill: parent
        source: shot
        autoPaddingEnabled: false
        blurEnabled: true
        blurMax: 64
        blur: root.reveal
        brightness: -0.16 * root.reveal
        saturation: 0.08 * root.reveal
        scale: 1 + 0.035 * root.reveal   // oculta los bordes oscuros del desenfoque
    }

    // Velo con el tono de la paleta para dar contraste al reloj
    Rectangle {
        anchors.fill: parent
        color: Theme.bg
        opacity: 0.32 * root.reveal
    }

    // ---- Reloj ----
    SystemClock {
        id: clock
        precision: SystemClock.Seconds
    }

    Column {
        anchors.centerIn: parent
        anchors.verticalCenterOffset: -70 - 18 * (1 - root.clockIn) * (root.unlocking ? -1 : 1)
        spacing: 4
        opacity: root.clockIn

        // Hora en 12 h (como la barra y el inicio de sesion)
        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 10
            Text {
                id: bigTime
                text: (clock.date.getHours() % 12 || 12) + Qt.formatDateTime(clock.date, ":mm")
                font.family: Theme.fontSans
                font.pixelSize: 136
                font.weight: Font.ExtraLight
                font.letterSpacing: -3 + 10 * (1 - root.clockIn)
                color: Theme.fg
                Behavior on color { ColorAnimation { duration: Theme.durSlow } }
            }
            Text {
                anchors.baseline: bigTime.baseline
                text: clock.date.getHours() < 12 ? "am" : "pm"
                font.family: Theme.fontSans
                font.pixelSize: 28
                font.weight: Font.Light
                color: Theme.fgMuted
            }
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: clock.date.toLocaleDateString(Qt.locale("es_ES"), "dddd d 'de' MMMM").toLowerCase()
            font.family: Theme.fontSans
            font.pixelSize: 17
            font.weight: Font.Light
            font.letterSpacing: 3
            color: Theme.fgMuted
        }
    }

    // ---- Contrasena ----
    PassBars {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 110
        ctx: root.ctx
        opacity: root.clockIn > 0 || root.unlocking ? 1 : 0
    }
}
