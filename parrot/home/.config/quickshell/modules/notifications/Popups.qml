import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import Quickshell.Services.Notifications
import qs.config
import qs.services

// Avisos emergentes, arriba a la derecha del monitor enfocado.
// Se ocultan solos (5 s por defecto, pausa al pasar el raton); siguen en el centro.
PanelWindow {
    id: root

    screen: {
        const fm = Hyprland.focusedMonitor;
        return Quickshell.screens.find(s => fm && s.name === fm.name) ?? Quickshell.screens[0];
    }

    visible: Notifs.popups.length > 0 || list.count > 0
    color: "transparent"
    anchors { top: true; right: true }
    margins { top: Theme.barHeight + Theme.gap * 2; right: Theme.gap + 4 }
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "hyprshell-notifications"
    implicitWidth: 380
    implicitHeight: Math.max(1, list.contentHeight)

    ListView {
        id: list
        anchors.fill: parent
        interactive: false
        spacing: Theme.gap
        model: ScriptModel { values: Notifs.popups }

        add: Transition {
            ParallelAnimation {
                NumberAnimation { property: "x"; from: 80; to: 0; duration: Theme.durNormal; easing.type: Easing.BezierSpline; easing.bezierCurve: Theme.curve }
                NumberAnimation { property: "opacity"; from: 0; to: 1; duration: Theme.durNormal }
            }
        }
        remove: Transition {
            ParallelAnimation {
                NumberAnimation { property: "x"; to: 80; duration: Theme.durFast }
                NumberAnimation { property: "opacity"; to: 0; duration: Theme.durFast }
            }
        }
        displaced: Transition {
            NumberAnimation { property: "y"; duration: Theme.durNormal; easing.type: Easing.BezierSpline; easing.bezierCurve: Theme.curve }
        }

        delegate: NotifCard {
            id: card

            required property var modelData
            notif: modelData
            popup: true
            width: ListView.view.width

            HoverHandler { id: cardHover }

            // La notificacion puede destruirse (notif = null) mientras la tarjeta anima su salida.
            Timer {
                readonly property int timeout: !card.notif ? 0
                    : card.notif.expireTimeout > 0 ? card.notif.expireTimeout
                    : card.critical ? 0 : 5000
                interval: Math.max(1, timeout)
                running: timeout > 0 && !cardHover.hovered
                onTriggered: {
                    const n = card.notif;
                    if (!n)
                        return;
                    Notifs.hidePopup(n);
                    if (n.transient)
                        n.expire();
                }
            }
        }
    }
}
