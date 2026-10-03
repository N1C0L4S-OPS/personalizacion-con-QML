import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.config
import qs.widgets

// Calendario: hora en 12 h con segundos, mes navegable (flechas o rueda), hoy resaltado.
// Clic en el nombre del mes vuelve al mes actual.
ColumnLayout {
    id: root

    spacing: 14

    SystemClock {
        id: clock
        precision: SystemClock.Seconds
    }

    readonly property var today: clock.date
    property int year: today.getFullYear()
    property int month: today.getMonth()
    readonly property bool onCurrent: year === today.getFullYear() && month === today.getMonth()
    readonly property var locale: Qt.locale("es_ES")

    function shift(delta) {
        const d = new Date(year, month + delta, 1);
        year = d.getFullYear();
        month = d.getMonth();
    }
    function goToday() {
        year = today.getFullYear();
        month = today.getMonth();
    }

    // Celdas: 6 semanas empezando en lunes
    readonly property var cells: {
        const first = new Date(year, month, 1);
        const offset = (first.getDay() + 6) % 7;
        const out = [];
        for (let i = 0; i < 42; i++) {
            const d = new Date(year, month, 1 - offset + i);
            out.push({
                day: d.getDate(),
                inMonth: d.getMonth() === month,
                isToday: d.toDateString() === today.toDateString(),
                weekend: i % 7 >= 5
            });
        }
        return out;
    }

    // ---- Hora grande ----
    ColumnLayout {
        Layout.fillWidth: true
        spacing: 2

        Item {
            Layout.fillWidth: true
            implicitHeight: timeRow.implicitHeight

        Row {
            id: timeRow
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 6
            Label {
                id: big
                text: (clock.date.getHours() % 12 || 12) + Qt.formatDateTime(clock.date, ":mm")
                font.pixelSize: 40
                font.weight: Font.Light
                font.letterSpacing: -1
            }
            Column {
                anchors.bottom: big.baseline
                spacing: 0
                Label {
                    text: Qt.formatDateTime(clock.date, "ss")
                    mono: true
                    font.pixelSize: 12
                    color: Theme.accent
                }
                Label {
                    text: clock.date.getHours() < 12 ? "am" : "pm"
                    font.pixelSize: 13
                    color: Theme.fgMuted
                }
            }
        }
        }
        Label {
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            text: clock.date.toLocaleDateString(root.locale, "dddd d 'de' MMMM 'de' yyyy")
            color: Theme.fgDim
        }
    }

    Rectangle { Layout.fillWidth: true; implicitHeight: 1; color: Theme.alpha(Theme.overlay, 0.6) }

    // ---- Cabecera del mes ----
    RowLayout {
        Layout.fillWidth: true

        NavButton { code: 0xf053; onClicked: root.shift(-1) }

        Item {
            Layout.fillWidth: true
            implicitHeight: monthLabel.implicitHeight + 8
            Label {
                id: monthLabel
                anchors.centerIn: parent
                text: {
                    const m = root.locale.standaloneMonthName(root.month, Locale.LongFormat);
                    return m.charAt(0).toUpperCase() + m.slice(1) + "  " + root.year;
                }
                font.weight: Font.DemiBold
                font.pixelSize: 14
                color: monthArea.containsMouse && !root.onCurrent ? Theme.accent : Theme.fg
            }
            MouseArea {
                id: monthArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: root.onCurrent ? Qt.ArrowCursor : Qt.PointingHandCursor
                onClicked: root.goToday()
            }
        }

        NavButton { code: 0xf054; onClicked: root.shift(1) }
    }

    // ---- Dias de la semana + rejilla ----
    GridLayout {
        id: grid
        Layout.fillWidth: true
        columns: 7
        rowSpacing: 2
        columnSpacing: 2

        Repeater {
            model: ["L", "M", "X", "J", "V", "S", "D"]
            Label {
                required property string modelData
                required property int index
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                text: modelData
                font.pixelSize: Theme.fontSizeSmall
                font.weight: Font.DemiBold
                color: index >= 5 ? Theme.accent2 : Theme.fgDim
            }
        }

        Repeater {
            model: root.cells

            Item {
                required property var modelData
                Layout.fillWidth: true
                implicitHeight: 34

                Rectangle {
                    anchors.centerIn: parent
                    width: 30
                    height: 30
                    radius: 15
                    color: modelData.isToday ? Theme.accent
                        : cellArea.containsMouse && modelData.inMonth ? Theme.surface2 : "transparent"
                    Behavior on color { ColorAnimation { duration: Theme.durFast } }
                }
                Label {
                    anchors.centerIn: parent
                    text: modelData.day
                    font.weight: modelData.isToday ? Font.Bold : Font.Normal
                    color: modelData.isToday ? Theme.bg
                        : !modelData.inMonth ? Theme.alpha(Theme.fgDim, 0.45)
                        : modelData.weekend ? Theme.accent2 : Theme.fg
                }
                MouseArea { id: cellArea; anchors.fill: parent; hoverEnabled: true }
            }
        }
    }

    // Rueda del raton: cambia de mes
    WheelHandler {
        target: null
        onWheel: event => root.shift(event.angleDelta.y > 0 ? -1 : 1)
    }

    component NavButton: Rectangle {
        id: btn
        property int code
        signal clicked()
        implicitWidth: 28
        implicitHeight: 28
        radius: Theme.radiusSmall
        color: navArea.containsMouse ? Theme.surface2 : "transparent"
        Behavior on color { ColorAnimation { duration: Theme.durFast } }
        Icon {
            anchors.centerIn: parent
            code: btn.code
            color: navArea.containsMouse ? Theme.accent : Theme.fgMuted
            font.pixelSize: Theme.fontSizeSmall
        }
        MouseArea {
            id: navArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: btn.clicked()
        }
    }
}
