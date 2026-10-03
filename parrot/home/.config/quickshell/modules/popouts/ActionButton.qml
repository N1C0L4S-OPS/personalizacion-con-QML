import QtQuick
import QtQuick.Layouts
import qs.config
import qs.widgets

// Boton de accion de los desplegables.
Rectangle {
    id: root

    property int code: 0
    property string text
    signal clicked()

    Layout.fillWidth: true
    implicitHeight: 32
    radius: Theme.radiusSmall
    color: area.containsMouse ? Theme.alpha(Theme.accent, 0.16) : Theme.surface2
    Behavior on color { ColorAnimation { duration: Theme.durFast } }

    Row {
        anchors.centerIn: parent
        spacing: 8
        Icon {
            visible: root.code !== 0
            code: root.code
            font.pixelSize: Theme.fontSize
            color: area.containsMouse ? Theme.accent : Theme.fgMuted
        }
        Label {
            text: root.text
            color: area.containsMouse ? Theme.accent : Theme.fgMuted
        }
    }

    MouseArea {
        id: area
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
