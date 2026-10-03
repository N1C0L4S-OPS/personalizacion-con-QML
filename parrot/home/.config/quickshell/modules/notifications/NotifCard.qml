import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.Notifications
import qs.config
import qs.services
import qs.widgets

// Tarjeta de notificacion, compartida por los avisos emergentes y el centro.
// Clic: accion por defecto (o descartar) · Boton x: descartar
Rectangle {
    id: root

    required property var notif
    property bool popup: false
    readonly property bool critical: notif && notif.urgency === NotificationUrgency.Critical
    readonly property var actions: notif ? notif.actions.filter(a => a.identifier !== "default") : []
    readonly property string iconSrc: !notif ? "" : notif.image ? notif.image
        : notif.appIcon ? Quickshell.iconPath(notif.appIcon, true) : ""

    implicitHeight: layout.implicitHeight + 28
    radius: Theme.radius
    color: popup ? Theme.alpha(Theme.bg, 0.92) : Theme.alpha(Theme.surface, 0.7)
    border.width: 1
    border.color: critical ? Theme.alpha(Theme.red, 0.6) : Theme.alpha(Theme.overlay, popup ? 0.7 : 0.4)

    function dismiss() {
        if (notif)
            notif.dismiss();
    }

    HoverHandler { id: hover }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            const def = root.notif ? root.notif.actions.find(a => a.identifier === "default") : null;
            if (def) def.invoke();
            else root.dismiss();
        }
    }

    // Franja lateral para notificaciones criticas
    Rectangle {
        visible: root.critical
        anchors { left: parent.left; top: parent.top; bottom: parent.bottom; margins: 10 }
        width: 3
        radius: 2
        color: Theme.red
    }

    RowLayout {
        id: layout
        anchors { left: parent.left; right: parent.right; top: parent.top; margins: 14; leftMargin: root.critical ? 22 : 14 }
        spacing: 12

        // Icono / imagen de la app
        Item {
            Layout.alignment: Qt.AlignTop
            Layout.preferredWidth: 36
            Layout.preferredHeight: 36

            ClippingRectangle {
                anchors.fill: parent
                visible: root.iconSrc.length > 0
                radius: Theme.radiusSmall
                color: "transparent"
                IconImage {
                    anchors.fill: parent
                    source: root.iconSrc
                    asynchronous: true
                }
            }
            Rectangle {
                anchors.fill: parent
                visible: root.iconSrc.length === 0
                radius: Theme.radiusSmall
                color: Theme.surface2
                Icon {
                    anchors.centerIn: parent
                    code: 0xf0f3
                    font.pixelSize: 15
                    color: root.critical ? Theme.red : Theme.accent
                }
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 3

            RowLayout {
                Layout.fillWidth: true
                spacing: 6
                Label {
                    Layout.fillWidth: true
                    text: root.notif ? root.notif.appName || "Sistema" : ""
                    color: Theme.fgDim
                    font.pixelSize: Theme.fontSizeSmall
                    elide: Text.ElideRight
                }
                Label {
                    text: root.notif ? Notifs.ago(root.notif) : ""
                    color: Theme.fgDim
                    font.pixelSize: Theme.fontSizeSmall
                    visible: !hover.hovered
                }
                Icon {
                    visible: hover.hovered
                    code: 0xf00d
                    font.pixelSize: 12
                    color: closeArea.containsMouse ? Theme.fg : Theme.fgDim
                    MouseArea {
                        id: closeArea
                        anchors.fill: parent
                        anchors.margins: -6
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.dismiss()
                    }
                }
            }

            Label {
                Layout.fillWidth: true
                text: root.notif ? root.notif.summary : ""
                font.weight: Font.DemiBold
                wrapMode: Text.Wrap
                maximumLineCount: 2
                elide: Text.ElideRight
            }

            Label {
                Layout.fillWidth: true
                visible: text.length > 0
                text: root.notif ? root.notif.body : ""
                textFormat: Text.StyledText
                color: Theme.fgMuted
                wrapMode: Text.Wrap
                maximumLineCount: root.popup ? 3 : 6
                elide: Text.ElideRight
                linkColor: Theme.accent
                onLinkActivated: link => Qt.openUrlExternally(link)
            }

            Row {
                visible: root.actions.length > 0
                Layout.topMargin: 6
                spacing: 6

                Repeater {
                    model: root.actions

                    Rectangle {
                        id: btn
                        required property var modelData
                        width: actLabel.implicitWidth + 20
                        height: 26
                        radius: Theme.radiusSmall
                        color: actArea.containsMouse ? Theme.alpha(Theme.accent, 0.18) : Theme.surface2
                        Behavior on color { ColorAnimation { duration: Theme.durFast } }

                        Label {
                            id: actLabel
                            anchors.centerIn: parent
                            text: btn.modelData.text
                            font.pixelSize: Theme.fontSizeSmall
                            color: actArea.containsMouse ? Theme.accent : Theme.fgMuted
                        }
                        MouseArea {
                            id: actArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: btn.modelData.invoke()
                        }
                    }
                }
            }
        }
    }
}
