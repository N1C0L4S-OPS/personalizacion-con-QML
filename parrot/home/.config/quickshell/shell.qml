//@ pragma IconTheme breeze-dark
import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import qs.config
import qs.services
import qs.modules.background
import qs.modules.clipboard
import qs.modules.control
import qs.modules.bar
import qs.modules.launcher
import qs.modules.lock
import qs.modules.notifications
import qs.modules.osd
import qs.modules.overview
import qs.modules.packages
import qs.modules.popouts
import qs.modules.power
import qs.modules.wallpaper

ShellRoot {
    Background {}
    Bar {}
    Launcher {}
    WallpaperPicker {}
    PowerMenu {}
    Popups {}
    NotifCenter {}
    VolumeOsd {}
    Popouts {}
    Lock {}
    Packages {}
    Overview {}
    Clipboard {}
    ControlCenter {}

    // Atajos: en hyprland.conf -> bind = SUPER, R, global, hyprshell:launcher
    GlobalShortcut { appid: "hyprshell"; name: "launcher"; onPressed: Ui.toggle("launcher") }
    GlobalShortcut { appid: "hyprshell"; name: "wallpaper"; onPressed: Ui.toggle("wallpaper") }
    GlobalShortcut { appid: "hyprshell"; name: "power"; onPressed: Ui.toggle("power") }
    GlobalShortcut { appid: "hyprshell"; name: "notifications"; onPressed: Ui.toggle("notifications") }
    GlobalShortcut { appid: "hyprshell"; name: "packages"; onPressed: Ui.toggle("packages") }
    GlobalShortcut { appid: "hyprshell"; name: "overview"; onPressed: Ui.toggle("overview") }
    GlobalShortcut { appid: "hyprshell"; name: "clipboard"; onPressed: Ui.toggle("clipboard") }
    GlobalShortcut { appid: "hyprshell"; name: "control"; onPressed: Ui.toggle("control") }

    // qs ipc call ui toggle launcher|wallpaper|power
    IpcHandler {
        target: "ui"
        function toggle(panel: string): void { Ui.toggle(panel); }
        function close(): void { Ui.close(); }
        // qs ipc call ui pop cpu 1400  -> desplegable en el monitor secundario
        function pop(name: string, x: real): void {
            const onPrimary = name === "revshell" || name === "listeners" || name === "calendar";
            const scr = Quickshell.screens.find(s => onPrimary ? s.name === Theme.primaryMonitor : s.name !== Theme.primaryMonitor);
            Ui.togglePopout(name, scr ?? Quickshell.screens[0], x);
        }
    }

    // qs ipc call wallpaper set <ruta>
    IpcHandler {
        target: "wallpaper"
        function set(path: string): void { Wallpapers.set(path); }
        function get(): string { return Wallpapers.current; }
    }
}
