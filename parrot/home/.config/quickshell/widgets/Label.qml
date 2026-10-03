import QtQuick
import qs.config

Text {
    property bool mono: false
    font.family: mono ? Theme.fontMono : Theme.fontSans
    font.pixelSize: Theme.fontSize
    color: Theme.fg
    verticalAlignment: Text.AlignVCenter
    Behavior on color { ColorAnimation { duration: Theme.durNormal } }
}
