import QtQuick
import QtQuick.Layouts
import qs.config
import qs.widgets

// Barra de proporcion con etiqueta a la izquierda y texto a la derecha.
ColumnLayout {
    id: root

    property string label
    property string detail
    property real fraction: 0
    readonly property color tone: fraction > 0.9 ? Theme.red : fraction > 0.75 ? Theme.yellow : Theme.accent

    Layout.fillWidth: true
    spacing: 5

    RowLayout {
        Layout.fillWidth: true
        Label { Layout.fillWidth: true; text: root.label; color: Theme.fgMuted }
        Label { mono: true; text: root.detail; color: Theme.fgDim; font.pixelSize: Theme.fontSizeSmall }
    }
    Rectangle {
        Layout.fillWidth: true
        height: 5
        radius: 3
        color: Theme.overlay
        Rectangle {
            width: parent.width * Math.max(0, Math.min(1, root.fraction))
            height: parent.height
            radius: 3
            color: root.tone
            Behavior on width { NumberAnimation { duration: Theme.durNormal } }
        }
    }
}
