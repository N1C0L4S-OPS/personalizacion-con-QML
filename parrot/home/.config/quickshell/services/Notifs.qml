pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.Notifications

// Servidor de notificaciones de la shell (reemplaza a swaync).
// history: todas las notificaciones vivas (centro) · popups: las que se muestran ahora
Singleton {
    id: root

    property bool dnd: false
    property int unread: 0
    property var popups: []
    property var arrived: ({})  // id -> marca de tiempo de llegada

    readonly property var history: server.trackedNotifications.values.slice().reverse()
    readonly property int count: server.trackedNotifications.values.length

    function hidePopup(n) {
        popups = popups.filter(p => p !== n);
    }

    function clearAll() {
        for (const n of server.trackedNotifications.values.slice())
            n.dismiss();
        popups = [];
        unread = 0;
    }

    function ago(n) {
        const t = arrived[n.id];
        if (!t)
            return "";
        const min = Math.floor((Date.now() - t) / 60000);
        if (min < 1) return "ahora";
        if (min < 60) return min + " min";
        const h = Math.floor(min / 60);
        return h < 24 ? h + " h" : Math.floor(h / 24) + " d";
    }

    NotificationServer {
        id: server
        keepOnReload: true
        bodySupported: true
        bodyMarkupSupported: true
        actionsSupported: true
        imageSupported: true
        persistenceSupported: true

        onNotification: n => {
            n.tracked = true;
            root.arrived[n.id] = Date.now();
            root.unread++;
            n.closed.connect(() => root.hidePopup(n));
            if (!root.dnd || n.urgency === NotificationUrgency.Critical)
                root.popups = [n, ...root.popups.filter(p => p !== n)].slice(0, 4);
        }
    }
}
