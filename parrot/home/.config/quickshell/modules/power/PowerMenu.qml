import QtQuick
import Quickshell
import qs.config
import qs.services
import qs.widgets

// Menu de energia. Flechas navegan · Enter ejecuta · Esc cierra
Overlay {
    id: root

    name: "power"
    cardWidth: 5 * 96 + 4 * 12 + 48
    cardHeight: 176

    readonly property var actions: [
        { icon: 0xf023, label: "Bloquear",   danger: false, cmd: ["loginctl", "lock-session"] },
        { icon: 0xf08b, label: "Salir",      danger: false, cmd: [Quickshell.env("HOME") + "/.config/hypr/scripts/logout.sh"] },
        { icon: 0xf186, label: "Suspender",  danger: false, cmd: ["systemctl", "suspend"] },
        { icon: 0xf021, label: "Reiniciar",  danger: true,  cmd: ["systemctl", "reboot"] },
        { icon: 0xf011, label: "Apagar",     danger: true,  cmd: ["systemctl", "poweroff"] },
    ]
    property int current: 0

    function run(i) {
        Ui.close();
        Quickshell.execDetached(actions[i].cmd);
    }

    onOpenChanged: if (open) {
        current = 0;
        row.forceActiveFocus();
    }

    Row {
        id: row
        anchors.centerIn: parent
        spacing: 12
        focus: true

        Keys.onPressed: e => {
            if (e.key === Qt.Key_Escape) Ui.close();
            else if (e.key === Qt.Key_Right || e.key === Qt.Key_Tab) root.current = (root.current + 1) % root.actions.length;
            else if (e.key === Qt.Key_Left || e.key === Qt.Key_Backtab) root.current = (root.current + root.actions.length - 1) % root.actions.length;
            else if (e.key === Qt.Key_Return || e.key === Qt.Key_Enter) root.run(root.current);
            else return;
            e.accepted = true;
        }

        Repeater {
            model: root.actions

            Rectangle {
                id: btn

                required property var modelData
                required property int index
                readonly property bool selected: root.current === index
                readonly property color tone: modelData.danger ? Theme.red : Theme.accent

                width: 96
                height: 112
                radius: Theme.radius
                color: selected ? Theme.alpha(tone, 0.14) : Theme.alpha(Theme.surface, 0.6)
                border.width: 1
                border.color: selected ? Theme.alpha(tone, 0.6) : "transparent"
                Behavior on color { ColorAnimation { duration: Theme.durFast } }

                Column {
                    anchors.centerIn: parent
                    spacing: 12
                    Icon {
                        anchors.horizontalCenter: parent.horizontalCenter
                        code: btn.modelData.icon
                        font.pixelSize: 26
                        color: btn.selected ? btn.tone : Theme.fgMuted
                    }
                    Label {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: btn.modelData.label
                        color: btn.selected ? Theme.fg : Theme.fgDim
                        font.pixelSize: Theme.fontSizeSmall
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onEntered: root.current = btn.index
                    onClicked: root.run(btn.index)
                }
            }
        }
    }
}
