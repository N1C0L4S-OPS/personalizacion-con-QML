import QtQuick
import qs.config

// Grafica de linea con relleno suave. `values` = lista de numeros; `max` = 0 para autoescala.
// `values2` dibuja una segunda serie (p. ej. subida de red) en `color2`.
Canvas {
    id: root

    property var values: []
    property var values2: []
    property real max: 0
    property color color: Theme.accent
    property color color2: Theme.accent2
    property int slots: 60

    onValuesChanged: requestPaint()
    onValues2Changed: requestPaint()
    onColorChanged: requestPaint()
    onWidthChanged: requestPaint()

    function series(ctx, vals, col, top) {
        if (!vals || vals.length < 2)
            return;
        const step = width / (slots - 1);
        const x0 = width - (vals.length - 1) * step;
        const y = v => height - 2 - (height - 4) * Math.min(1, v / top);

        ctx.beginPath();
        ctx.moveTo(x0, height);
        for (let i = 0; i < vals.length; i++)
            ctx.lineTo(x0 + i * step, y(vals[i]));
        ctx.lineTo(width, height);
        ctx.closePath();
        ctx.fillStyle = Qt.rgba(col.r, col.g, col.b, 0.12);
        ctx.fill();

        ctx.beginPath();
        for (let i = 0; i < vals.length; i++) {
            const px = x0 + i * step, py = y(vals[i]);
            i === 0 ? ctx.moveTo(px, py) : ctx.lineTo(px, py);
        }
        ctx.strokeStyle = col;
        ctx.lineWidth = 1.5;
        ctx.stroke();
    }

    onPaint: {
        const ctx = getContext("2d");
        ctx.reset();
        const all = (values || []).concat(values2 || []);
        const top = max > 0 ? max : Math.max(1, ...all) * 1.15;
        series(ctx, values2, color2, top);
        series(ctx, values, color, top);
    }
}
