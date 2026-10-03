import QtQuick
import QtQuick.Effects
import qs.config

// Entrada de contrasena sin texto: una barra por caracter, en el color del fondo.
//  - escribir: la barra crece desde la base y el grupo se recentra
//  - comprobando: las barras laten en ola
//  - error: tiemblan, se tinen de rojo y caen una a una
//  - correcto: convergen en el centro y estallan en una linea de luz
Item {
    id: root

    required property var ctx

    readonly property string phase: ctx.phase
    readonly property color tone: phase === "fail" ? Theme.red
        : phase === "unlocking" ? Qt.lighter(Theme.accent, 1.25) : Theme.accent
    readonly property real step: phase === "unlocking" ? 0 : 14
    property real wave: 0
    property real shakeX: 0
    property real barsFade: 1

    height: 60

    NumberAnimation on wave {
        running: root.phase === "checking"
        from: 0; to: 1; duration: 1100
        loops: Animation.Infinite
    }

    onPhaseChanged: {
        if (phase === "fail")
            shake.restart();
        else if (phase === "unlocking")
            burst.restart();
        else if (phase === "idle")
            barsFade = 1;
    }

    SequentialAnimation {
        id: shake
        NumberAnimation { target: root; property: "shakeX"; to: 16; duration: 45; easing.type: Easing.OutQuad }
        NumberAnimation { target: root; property: "shakeX"; to: -14; duration: 70; easing.type: Easing.InOutQuad }
        NumberAnimation { target: root; property: "shakeX"; to: 10; duration: 65; easing.type: Easing.InOutQuad }
        NumberAnimation { target: root; property: "shakeX"; to: -7; duration: 60; easing.type: Easing.InOutQuad }
        NumberAnimation { target: root; property: "shakeX"; to: 4; duration: 55; easing.type: Easing.InOutQuad }
        NumberAnimation { target: root; property: "shakeX"; to: 0; duration: 50; easing.type: Easing.OutQuad }
    }

    // Grupo de barras (con un leve resplandor del mismo color)
    Item {
        id: group
        anchors.fill: parent
        transform: Translate { x: root.shakeX }

        layer.enabled: true
        layer.effect: MultiEffect {
            shadowEnabled: true
            shadowColor: root.tone
            shadowBlur: 0.7
            shadowOpacity: 0.65
            shadowHorizontalOffset: 0
            shadowVerticalOffset: 0
        }

        Repeater {
            model: root.ctx.bars

            Rectangle {
                id: bar

                required property int index
                required property bool live

                property bool grown: false
                property real dropY: 0
                property real fade: 1

                x: root.width / 2 + (index - (root.ctx.alive - 1) / 2) * root.step - width / 2
                y: (root.height - height) / 2 + dropY
                width: 4
                height: grown && live ? 28 : 0
                radius: 2
                color: root.tone
                opacity: fade * root.barsFade * (live ? 1 : 0)
                    * (root.phase === "checking"
                       ? 0.4 + 0.6 * (0.5 + 0.5 * Math.cos(2 * Math.PI * (root.wave * 1.0 - index * 0.07)))
                       : 1)

                Component.onCompleted: grown = true

                Behavior on x { NumberAnimation { duration: root.phase === "unlocking" ? 300 : 240; easing.type: Easing.BezierSpline; easing.bezierCurve: Theme.curve } }
                Behavior on height { NumberAnimation { duration: 260; easing.type: Easing.OutBack; easing.overshoot: 1.6 } }
                Behavior on opacity { enabled: root.phase === "idle" || root.phase === "fail"; NumberAnimation { duration: 200 } }
                Behavior on color { ColorAnimation { duration: 160 } }

                // Error: cada barra cae y se apaga con un pequeno retraso escalonado
                readonly property bool dropping: root.ctx.dropping
                onDroppingChanged: if (dropping) drop.restart()
                SequentialAnimation {
                    id: drop
                    PauseAnimation { duration: Math.max(0, bar.index) * 38 }
                    ParallelAnimation {
                        NumberAnimation { target: bar; property: "dropY"; to: 26; duration: 340; easing.type: Easing.InCubic }
                        NumberAnimation { target: bar; property: "fade"; to: 0; duration: 300; easing.type: Easing.InQuad }
                    }
                }
            }
        }

        // Desbloqueo: linea de luz que nace del punto de convergencia
        Rectangle {
            id: beam
            anchors.centerIn: parent
            height: 2
            width: 0
            radius: 1
            color: root.tone
            opacity: 0
        }
    }

    SequentialAnimation {
        id: burst
        PauseAnimation { duration: 280 }
        ParallelAnimation {
            NumberAnimation { target: beam; property: "opacity"; from: 0; to: 1; duration: 120 }
            NumberAnimation { target: beam; property: "width"; from: 4; to: root.width * 0.42; duration: 620; easing.type: Easing.OutExpo }
            NumberAnimation { target: root; property: "barsFade"; to: 0; duration: 140; easing.type: Easing.InQuad }
        }
        NumberAnimation { target: beam; property: "opacity"; to: 0; duration: 260; easing.type: Easing.InQuad }
    }

    // Reposo: un punto que respira indica donde escribir
    Rectangle {
        anchors.centerIn: parent
        width: 5
        height: 5
        radius: 2.5
        color: Theme.fgMuted
        opacity: root.ctx.alive === 0 && root.phase === "idle" ? breath : 0
        property real breath: 0.25
        Behavior on opacity { NumberAnimation { duration: 260 } }
        SequentialAnimation on breath {
            loops: Animation.Infinite
            NumberAnimation { to: 0.55; duration: 1400; easing.type: Easing.InOutSine }
            NumberAnimation { to: 0.2; duration: 1400; easing.type: Easing.InOutSine }
        }
    }

    // Aviso puntual (p. ej. demasiados intentos)
    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.bottom
        anchors.topMargin: 6
        text: root.ctx.notice
        visible: text.length > 0
        font.family: Theme.fontSans
        font.pixelSize: 12
        font.letterSpacing: 2
        color: Theme.red
    }
}
