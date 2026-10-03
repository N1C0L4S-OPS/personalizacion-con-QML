import QtQuick
import QtQuick.Layouts
import qs.config
import qs.widgets

// Cabecera de desplegable: icono + titulo + subtitulo opcional a la derecha.
RowLayout {
    property int code
    property string title
    property string subtitle

    Layout.fillWidth: true
    spacing: 10

    Icon { code: parent.code; color: Theme.accent }
    Label { text: parent.title; font.weight: Font.DemiBold; font.pixelSize: 14 }
    Label {
        Layout.fillWidth: true
        horizontalAlignment: Text.AlignRight
        text: parent.subtitle
        color: Theme.fgDim
        font.pixelSize: Theme.fontSizeSmall
        elide: Text.ElideLeft
    }
}
