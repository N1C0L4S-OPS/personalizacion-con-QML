import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import qs.config

// Barra superior flotante, una por monitor.
//   Principal (izquierdo): contexto de trabajo -> reloj, objetivo HTB, VPN, volumen, avisos, energia
//   Secundario (derecho): telemetria -> reproductor/fecha, red, CPU, GPU, memoria, disco, uptime
Variants {
    model: Quickshell.screens

    PanelWindow {
        id: bar

        required property var modelData
        screen: modelData
        readonly property var monitor: Hyprland.monitorFor(modelData)
        readonly property bool primary: modelData.name === Theme.primaryMonitor

        WlrLayershell.namespace: "hyprshell-bar"
        anchors { top: true; left: true; right: true }
        implicitHeight: Theme.barHeight + Theme.gap
        color: "transparent"

        Rectangle {
            id: island
            anchors {
                fill: parent
                topMargin: Theme.gap
                leftMargin: Theme.gap + 4
                rightMargin: Theme.gap + 4
            }
            radius: Theme.radius
            color: Theme.alpha(Theme.bg, 0.82)
            border.width: 1
            border.color: Theme.alpha(Theme.overlay, 0.6)

            RowLayout {
                id: leftSide
                anchors { left: parent.left; leftMargin: 14; verticalCenter: parent.verticalCenter }
                spacing: 14
                Loader { active: bar.primary; visible: active; sourceComponent: Prompt {} }
                Loader {
                    active: bar.primary; visible: active
                    sourceComponent: Rectangle { implicitWidth: 1; implicitHeight: 14; color: Theme.overlay }
                }
                Workspaces { monitor: bar.monitor }
                WindowTitle { monitor: bar.monitor }
            }

            Loader {
                anchors.centerIn: parent
                sourceComponent: bar.primary ? primaryCenter : secondaryCenter
            }

            Loader {
                id: rightSide
                anchors { right: parent.right; rightMargin: 14; verticalCenter: parent.verticalCenter }
                sourceComponent: bar.primary ? primaryRight : secondaryRight
            }
        }

        Component {
            id: primaryCenter
            Clock { screen: bar.modelData }
        }

        Component {
            id: primaryRight
            RowLayout {
                spacing: 16
                HtbTarget {}
                Htb {}
                ListenersButton { screen: bar.modelData }
                RevShellButton { screen: bar.modelData }
                Separator {}
                AnonButton {}
                Separator {}
                AudioControl {}
                AudioControl { input: true }
                Separator {}
                ControlButton {}
                NotifButton {}
                PowerButton {}
            }
        }

        Component {
            id: secondaryCenter
            Row {
                id: centerRow
                spacing: 10
                // Ancho maximo del bloque central: lo que queda libre al lado mas ocupado,
                // por duplicado (va centrado) y con aire a cada lado. Nunca pisa la telemetria.
                readonly property real avail: island.width
                    - 2 * (Math.max(leftSide.width, rightSide.width) + 14 + 28)
                Spectrum { id: spectrum; anchors.verticalCenter: parent.verticalCenter }
                Media {
                    screen: bar.modelData
                    anchors.verticalCenter: parent.verticalCenter
                    maxWidth: Math.min(520, centerRow.avail - spectrum.width - (spectrum.width > 0 ? centerRow.spacing : 0))
                }
            }
        }

        Component {
            id: secondaryRight
            SysStats { screen: bar.modelData }
        }
    }
}
