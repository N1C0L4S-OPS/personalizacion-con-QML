import QtQuick
import qs.config
import qs.services
import qs.widgets

// Telemetria de la barra secundaria. Cada dato abre su desplegable al pulsarlo.
Row {
    id: root

    required property var screen
    spacing: 6

    component Stat: Rectangle {
        id: stat

        property string pop
        property var codes: []      // uno o dos iconos
        property var values: []
        property bool warn: false
        readonly property bool open: Ui.popout === pop && Ui.popoutScreen === root.screen

        anchors.verticalCenter: parent.verticalCenter
        implicitWidth: inner.implicitWidth + 16
        implicitHeight: 26
        radius: Theme.radiusSmall
        color: open ? Theme.alpha(Theme.accent, 0.14) : area.containsMouse ? Theme.surface2 : "transparent"
        Behavior on color { ColorAnimation { duration: Theme.durFast } }

        Row {
            id: inner
            anchors.centerIn: parent
            spacing: 10
            Repeater {
                model: stat.codes.length
                Row {
                    required property int index
                    spacing: 5
                    Icon {
                        code: stat.codes[index]
                        font.pixelSize: Theme.fontSize
                        color: stat.warn ? Theme.yellow : stat.open || area.containsMouse ? Theme.accent : Theme.fgDim
                    }
                    Label {
                        mono: true
                        text: stat.values[index] ?? ""
                        color: stat.warn ? Theme.yellow : stat.open || area.containsMouse ? Theme.fg : Theme.fgMuted
                    }
                }
            }
        }

        MouseArea {
            id: area
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: Ui.togglePopout(stat.pop, root.screen, stat.mapToItem(null, stat.width / 2, 0).x)
        }
    }

    Stat { pop: "net"; codes: [0xf0e8, 0xf063, 0xf062]
           values: [SysInfo.lanIp || "sin red", SysInfo.rate(SysInfo.netDown), SysInfo.rate(SysInfo.netUp)] }
    Separator { anchors.verticalCenter: parent.verticalCenter }
    Stat { pop: "cpu"; codes: [0xf4bc]; values: [SysInfo.cpu + "%  " + SysInfo.cpuTemp + "°"]; warn: SysInfo.cpu > 85 || SysInfo.cpuTemp > 85 }
    Stat { pop: "gpu"; codes: [0xf108]; values: [SysInfo.gpuBusy + "%  " + SysInfo.gpuTemp + "°"]; warn: SysInfo.gpuTemp > 85 }
    Stat { pop: "mem"; codes: [0xf2db]; values: [SysInfo.mem + "%"]; warn: SysInfo.mem > 85 }
    Stat { pop: "disk"; codes: [0xf0a0]; values: [SysInfo.disk + "%"]; warn: SysInfo.disk > 90 }
    Separator { anchors.verticalCenter: parent.verticalCenter }
    Stat { pop: "sys"; codes: [0xf017]; values: [SysInfo.uptime] }
}
