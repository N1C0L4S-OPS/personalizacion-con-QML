pragma Singleton
import QtQuick
import Quickshell

// Estado compartido de la interfaz: un solo panel o desplegable abierto a la vez.
Singleton {
    id: root

    property string panel: ""   // "", "launcher", "wallpaper", "power", "notifications"

    // Desplegables de la barra (cpu, gpu, mem, disk, net, uptime, media)
    property string popout: ""
    property var popoutScreen: null
    property real popoutX: 0    // centro horizontal del modulo, relativo a su pantalla

    function toggle(name) {
        popout = "";
        panel = panel === name ? "" : name;
    }

    function togglePopout(name, screen, x) {
        panel = "";
        if (popout === name) {
            popout = "";
            return;
        }
        popoutScreen = screen;
        popoutX = x;
        popout = name;
    }

    function close() {
        panel = "";
        popout = "";
    }
}
