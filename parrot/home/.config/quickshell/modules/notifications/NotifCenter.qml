import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import qs.config
import qs.services
import qs.widgets

// Centro de notificaciones: panel lateral derecho (Super+N o campana de la barra).
// Esc o clic fuera cierra.
PanelWindow {
    id: root

    readonly property bool open: Ui.panel === "notifications"

    property var targetScreen: Quickshell.screens[0]
    screen: targetScreen
    onOpenChanged: if (open) {
        const fm = Hyprland.focusedMonitor;
        targetScreen = Quickshell.screens.find(s => fm && s.name === fm.name) ?? Quickshell.screens[0];
        Notifs.unread = 0;
        drawer.forceActiveFocus();
    }

    visible: open || slide.x < drawer.width + 40
    color: "transparent"
    anchors { top: true; bottom: true; left: true; right: true }
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "hyprshell-center"
    WlrLayershell.keyboardFocus: open ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    MouseArea {
        anchors.fill: parent
        onClicked: Ui.close()
    }

    Rectangle {
        id: drawer
        anchors { top: parent.top; bottom: parent.bottom; right: parent.right
                  topMargin: Theme.barHeight + Theme.gap * 2; bottomMargin: Theme.gap + 4; rightMargin: Theme.gap + 4 }
        width: 400
        radius: Theme.radius + 4
        color: Theme.alpha(Theme.bg, 0.9)
        border.width: 1
        border.color: Theme.alpha(Theme.overlay, 0.7)
        focus: true

        transform: Translate {
            id: slide
            x: root.open ? 0 : drawer.width + 40
            Behavior on x { NumberAnimation { duration: Theme.durNormal + 60; easing.type: Easing.BezierSpline; easing.bezierCurve: Theme.curve } }
        }

        Keys.onEscapePressed: Ui.close()
        MouseArea { anchors.fill: parent }

        component HeaderButton: Rectangle {
            id: hb
            property int code
            property bool active: false
            property string tip
            signal clicked()
            width: 30
            height: 30
            radius: Theme.radiusSmall
            color: hbArea.containsMouse ? Theme.surface2 : active ? Theme.alpha(Theme.accent, 0.14) : "transparent"
            Behavior on color { ColorAnimation { duration: Theme.durFast } }
            Icon {
                anchors.centerIn: parent
                code: hb.code
                font.pixelSize: 14
                color: hb.active ? Theme.accent : hbArea.containsMouse ? Theme.fg : Theme.fgMuted
            }
            MouseArea {
                id: hbArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: hb.clicked()
            }
        }

        ColumnLayout {
            anchors { fill: parent; margins: 16 }
            spacing: 14

            RowLayout {
                Layout.fillWidth: true
                spacing: 8
                Label {
                    text: "Notificaciones"
                    font.pixelSize: 15
                    font.weight: Font.DemiBold
                }
                Label {
                    Layout.fillWidth: true
                    text: Notifs.count > 0 ? Notifs.count : ""
                    color: Theme.fgDim
                    mono: true
                }
                HeaderButton {
                    code: Notifs.dnd ? 0xf1f6 : 0xf0f3
                    active: Notifs.dnd
                    onClicked: Notifs.dnd = !Notifs.dnd
                }
                HeaderButton {
                    code: 0xf1f8
                    onClicked: Notifs.clearAll()
                }
            }

            Label {
                visible: Notifs.dnd
                text: "No molestar activo: solo se muestran avisos criticos"
                color: Theme.fgDim
                font.pixelSize: Theme.fontSizeSmall
            }

            ListView {
                id: list
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                spacing: Theme.gap
                boundsBehavior: Flickable.StopAtBounds
                model: ScriptModel { values: Notifs.history }

                add: Transition {
                    NumberAnimation { property: "opacity"; from: 0; to: 1; duration: Theme.durNormal }
                }
                remove: Transition {
                    ParallelAnimation {
                        NumberAnimation { property: "x"; to: 60; duration: Theme.durFast }
                        NumberAnimation { property: "opacity"; to: 0; duration: Theme.durFast }
                    }
                }
                displaced: Transition {
                    NumberAnimation { property: "y"; duration: Theme.durNormal; easing.type: Easing.BezierSpline; easing.bezierCurve: Theme.curve }
                }

                delegate: NotifCard {
                    required property var modelData
                    notif: modelData
                    width: ListView.view.width
                }

                Column {
                    anchors.centerIn: parent
                    visible: list.count === 0
                    spacing: 10
                    Icon {
                        anchors.horizontalCenter: parent.horizontalCenter
                        code: 0xf0f3
                        font.pixelSize: 28
                        color: Theme.overlay
                    }
                    Label {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "Sin notificaciones"
                        color: Theme.fgDim
                    }
                }
            }
        }
    }
}
