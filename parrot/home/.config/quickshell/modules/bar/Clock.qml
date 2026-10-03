import QtQuick
import Quickshell
import qs.config
import qs.services
import qs.widgets

// Reloj de la barra principal en formato 12 h. Clic: calendario.
Rectangle {
    id: root

    required property var screen
    readonly property bool open: Ui.popout === "calendar" && Ui.popoutScreen === screen

    implicitWidth: content.implicitWidth + 20
    implicitHeight: 26
    radius: Theme.radiusSmall
    color: open ? Theme.alpha(Theme.accent, 0.14) : area.containsMouse ? Theme.surface2 : "transparent"
    Behavior on color { ColorAnimation { duration: Theme.durFast } }

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    Row {
        id: content
        anchors.centerIn: parent
        spacing: 10

        Row {
            spacing: 4
            anchors.verticalCenter: parent.verticalCenter
            Label {
                text: (clock.date.getHours() % 12 || 12) + Qt.formatDateTime(clock.date, ":mm")
                font.weight: Font.DemiBold
                font.letterSpacing: 0.5
                color: root.open ? Theme.accent : Theme.fg
            }
            Label {
                anchors.baseline: parent.children[0].baseline
                text: clock.date.getHours() < 12 ? "am" : "pm"
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.fgMuted
            }
        }
        Label {
            anchors.verticalCenter: parent.verticalCenter
            text: clock.date.toLocaleDateString(Qt.locale("es_ES"), "ddd d MMM")
            color: Theme.fgDim
        }
    }

    MouseArea {
        id: area
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: Ui.togglePopout("calendar", root.screen, root.mapToItem(null, root.width / 2, 0).x)
    }
}
