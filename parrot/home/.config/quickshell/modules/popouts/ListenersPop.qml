import QtQuick
import QtQuick.Layouts
import qs.config
import qs.services
import qs.widgets

// Puertos en escucha. Los handlers (nc, socat, pwncat...) se resaltan arriba.
ColumnLayout {
    id: root
    spacing: 12

    PopHeader {
        code: 0xf09e
        title: "A la escucha"
        subtitle: Listeners.count + (Listeners.count === 1 ? " puerto" : " puertos")
    }

    Label {
        visible: Listeners.handlerActive
        text: "Handler activo esperando conexion"
        color: Theme.htbGreen
        font.pixelSize: Theme.fontSizeSmall
    }

    ColumnLayout {
        Layout.fillWidth: true
        spacing: 4

        Repeater {
            model: Listeners.all

            RowLayout {
                required property var modelData
                Layout.fillWidth: true
                spacing: 10

                Rectangle {
                    width: 6; height: 6; radius: 3
                    Layout.alignment: Qt.AlignVCenter
                    color: modelData.handler ? Theme.htbGreen : Theme.overlay
                }
                Label {
                    mono: true
                    text: modelData.port
                    color: modelData.handler ? Theme.htbGreen : Theme.fg
                    Layout.preferredWidth: 54
                }
                Label {
                    Layout.fillWidth: true
                    text: modelData.proc || "—"
                    color: Theme.fgMuted
                    elide: Text.ElideRight
                }
                Label {
                    mono: true
                    text: modelData.addr
                    color: Theme.fgDim
                    font.pixelSize: Theme.fontSizeSmall
                }
            }
        }

        Label {
            visible: Listeners.count === 0
            text: "Ningun puerto en escucha"
            color: Theme.fgDim
        }
    }
}
