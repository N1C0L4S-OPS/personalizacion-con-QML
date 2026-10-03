import QtQuick
import qs.config

// Icono de Nerd Font. `code` es el punto de codigo, p. ej. 0xf05b.
Text {
    property int code: 0
    text: String.fromCodePoint(code)
    font.family: Theme.fontMono
    font.pixelSize: Theme.fontSize + 2
    color: Theme.fgMuted
    verticalAlignment: Text.AlignVCenter
    Behavior on color { ColorAnimation { duration: Theme.durNormal } }
}
