import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.config
import qs.services
import qs.widgets

ColumnLayout {
    id: root

    property var info: ({})
    spacing: 12

    Process {
        running: true
        command: ["sh", "-c", "echo \"$(whoami)|$(hostname)|$(uname -r)|$(uptime -s)|$(hyprctl version | head -1 | awk '{print $2}')|$(. /etc/os-release; echo $PRETTY_NAME)\""]
        stdout: StdioCollector {
            onStreamFinished: {
                const p = text.trim().split("|");
                root.info = { user: p[0], host: p[1], kernel: p[2], boot: p[3], hypr: p[4], os: p[5] };
            }
        }
    }

    PopHeader { code: 0xf017; title: "Sistema"; subtitle: root.info.os || "" }

    ColumnLayout {
        Layout.fillWidth: true
        spacing: 0
        InfoRow { label: "Usuario"; value: (root.info.user || "") + "@" + (root.info.host || ""); copyable: true }
        InfoRow { label: "Kernel"; value: root.info.kernel || ""; copyable: true }
        InfoRow { label: "Hyprland"; value: root.info.hypr || "" }
        InfoRow { label: "Encendido desde"; value: root.info.boot || "" }
        InfoRow { label: "Tiempo encendido"; value: SysInfo.uptime }
    }
}
