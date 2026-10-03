import QtQuick
import Quickshell
import Quickshell.Io
import qs.config
import qs.widgets

// Prompt estilo terminal al inicio de la barra principal: usuario@host.
Row {
    id: root

    property string user: Quickshell.env("USER") || "user"
    property string host: "parrot"
    spacing: 0

    FileView {
        path: "/etc/hostname"
        onLoaded: root.host = text().trim() || "parrot"
    }

    Label { mono: true; text: root.user; color: Theme.accent; font.weight: Font.DemiBold; anchors.verticalCenter: parent.verticalCenter }
    Label { mono: true; text: "@"; color: Theme.fgDim; anchors.verticalCenter: parent.verticalCenter }
    Label { mono: true; text: root.host; color: Theme.accent2; anchors.verticalCenter: parent.verticalCenter }
    Label { mono: true; text: ":~"; color: Theme.fgDim; anchors.verticalCenter: parent.verticalCenter }
}
