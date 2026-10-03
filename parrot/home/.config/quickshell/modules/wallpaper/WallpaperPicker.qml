import QtQuick
import Quickshell.Widgets
import qs.config
import qs.services
import qs.widgets

// Selector de fondos. Flechas/rueda navegan · Enter aplica · Esc cierra
Overlay {
    id: root

    name: "wallpaper"
    cardWidth: 1040
    cardHeight: 300

    onOpenChanged: if (open) {
        Wallpapers.refresh();
        const i = Wallpapers.files.indexOf(Wallpapers.current);
        carousel.currentIndex = i >= 0 ? i : 0;
        carousel.positionViewAtIndex(carousel.currentIndex, ListView.Center);
        carousel.forceActiveFocus();
    }

    function apply(path) {
        if (!path)
            return;
        Wallpapers.set(path);
        Ui.close();
    }

    ListView {
        id: carousel
        anchors { top: parent.top; left: parent.left; right: parent.right; topMargin: 28 }
        height: 180
        orientation: ListView.Horizontal
        spacing: 14
        clip: true
        model: Wallpapers.files
        focus: true
        keyNavigationWraps: true
        highlightRangeMode: ListView.StrictlyEnforceRange
        preferredHighlightBegin: width / 2 - 128
        preferredHighlightEnd: width / 2 + 128
        highlightMoveDuration: Theme.durNormal
        boundsBehavior: Flickable.StopAtBounds

        Keys.onPressed: e => {
            if (e.key === Qt.Key_Escape) Ui.close();
            else if (e.key === Qt.Key_Return || e.key === Qt.Key_Enter) root.apply(Wallpapers.files[currentIndex]);
            else return;
            e.accepted = true;
        }

        WheelHandler {
            onWheel: e => e.angleDelta.y < 0 ? carousel.incrementCurrentIndex() : carousel.decrementCurrentIndex()
        }

        delegate: Item {
            id: slot

            required property string modelData
            required property int index
            readonly property bool current: ListView.isCurrentItem
            readonly property bool applied: modelData === Wallpapers.current

            width: 256
            height: 180

            ClippingRectangle {
                anchors.centerIn: parent
                width: 256
                height: 144
                radius: Theme.radius
                color: Theme.surface
                scale: slot.current ? 1.12 : 0.88
                opacity: slot.current ? 1 : 0.5
                border.width: slot.current ? 2 : 0
                border.color: Theme.accent

                Behavior on scale { NumberAnimation { duration: Theme.durNormal; easing.type: Easing.BezierSpline; easing.bezierCurve: Theme.curve } }
                Behavior on opacity { NumberAnimation { duration: Theme.durNormal } }

                Image {
                    anchors.fill: parent
                    source: Wallpapers.thumb(slot.modelData)
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true
                    sourceSize.width: 480
                    sourceSize.height: 270
                }

                // Marca del fondo aplicado actualmente
                Rectangle {
                    visible: slot.applied
                    anchors { right: parent.right; top: parent.top; margins: 8 }
                    width: 8
                    height: 8
                    radius: 4
                    color: Theme.accent
                    border.width: 1
                    border.color: Theme.bg
                }
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: slot.current ? root.apply(slot.modelData) : carousel.currentIndex = slot.index
            }
        }
    }

    Label {
        anchors { horizontalCenter: parent.horizontalCenter; top: carousel.bottom; topMargin: 22 }
        text: (Wallpapers.files[carousel.currentIndex] || "").split("/").pop()
        color: Theme.fgMuted
        mono: true
    }

    Label {
        anchors { horizontalCenter: parent.horizontalCenter; bottom: parent.bottom; bottomMargin: 18 }
        text: (carousel.currentIndex + 1) + " / " + carousel.count + "   ·   enter aplica   ·   esc cierra"
        color: Theme.fgDim
        font.pixelSize: Theme.fontSizeSmall
    }
}
