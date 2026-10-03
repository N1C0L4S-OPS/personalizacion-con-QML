pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import qs.config

// Lista los fondos disponibles y aplica uno (themegen regenera la paleta).
Singleton {
    id: root

    readonly property string directory: Quickshell.env("HOME") + "/Pictures/Wallpapers"
    readonly property string current: Theme.wallpaper
    property list<string> files: []
    readonly property string thumbDir: Quickshell.env("HOME") + "/.cache/hyprshell/thumbs"

    function thumb(path) {
        return "file://" + thumbDir + "/" + path.split("/").pop() + ".jpg";
    }

    function set(path) {
        applier.command = [Quickshell.env("HOME") + "/.local/bin/themegen", path];
        applier.running = true;
    }

    // Genera miniaturas que falten y luego lista los fondos
    function refresh() {
        thumbnailer.running = true;
    }

    Process {
        id: thumbnailer
        running: true
        command: [Quickshell.env("HOME") + "/.local/bin/themegen", "--thumbs", root.directory]
        onExited: lister.running = true
    }

    Process {
        id: applier
    }

    Process {
        id: lister
        command: ["find", root.directory, "-maxdepth", "1", "-type", "f",
                  "(", "-iname", "*.jpg", "-o", "-iname", "*.jpeg", "-o", "-iname", "*.png",
                  "-o", "-iname", "*.webp", ")"]
        stdout: StdioCollector {
            onStreamFinished: root.files = text.trim().split("\n").filter(f => f.length > 0).sort()
        }
    }
}
