import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.config

// Fondo de pantalla dibujado por la shell, con fundido al cambiarlo.
Variants {
    model: Quickshell.screens

    PanelWindow {
        id: win

        required property var modelData
        screen: modelData

        WlrLayershell.layer: WlrLayer.Background
        WlrLayershell.namespace: "hyprshell-background"
        exclusionMode: ExclusionMode.Ignore
        anchors { top: true; bottom: true; left: true; right: true }
        color: Theme.bg

        property bool frontIsA: true

        function show(path) {
            const next = frontIsA ? imgB : imgA;
            if (next.source == "file://" + path)
                return;
            next.source = "file://" + path;
        }

        Component.onCompleted: if (Theme.wallpaper) show(Theme.wallpaper)

        Connections {
            target: Theme
            function onWallpaperChanged() { win.show(Theme.wallpaper); }
        }

        component Layer: Image {
            anchors.fill: parent
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            cache: false
            sourceSize.width: win.screen.width
            sourceSize.height: win.screen.height
            opacity: 0
            Behavior on opacity {
                NumberAnimation { duration: Theme.durSlow * 1.5; easing.type: Easing.BezierSpline; easing.bezierCurve: Theme.curve }
            }
        }

        Layer {
            id: imgA
            onStatusChanged: if (status === Image.Ready && !win.frontIsA) {
                opacity = 1; imgB.opacity = 0; win.frontIsA = true;
            }
        }
        Layer {
            id: imgB
            onStatusChanged: if (status === Image.Ready && win.frontIsA) {
                opacity = 1; imgA.opacity = 0; win.frontIsA = false;
            }
        }
    }
}
