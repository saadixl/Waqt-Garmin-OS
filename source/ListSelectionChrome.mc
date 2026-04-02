using Toybox.Graphics;

module ListSelectionChrome {
    function blendRgb(c0, c1, t) {
        var r0 = (c0 >> 16) & 0xFF;
        var g0 = (c0 >> 8) & 0xFF;
        var b0 = c0 & 0xFF;
        var r1 = (c1 >> 16) & 0xFF;
        var g1 = (c1 >> 8) & 0xFF;
        var b1 = c1 & 0xFF;
        var om = 1.0 - t;
        var r = (r0.toFloat() * om + r1.toFloat() * t).toNumber();
        var g = (g0.toFloat() * om + g1.toFloat() * t).toNumber();
        var b = (b0.toFloat() * om + b1.toFloat() * t).toNumber();
        return (r << 16) | (g << 8) | b;
    }

    // Vertical gradient: light brass (top) → black (bottom); brass frame + hairlines.
    function drawCenterPanel(dc, width, itemY, rowH) {
        var margin = 14;
        var insetY = 2;
        var x = margin;
        var y = itemY + insetY;
        var w = width - 2 * margin;
        var h = rowH - 2 * insetY;
        var cTop = Constants.COLOR_ACTIVE_BORDER;
        var cBot = Constants.COLOR_BG;
        if (h < 1) {
            return;
        }
        var yy = 0;
        while (yy < h) {
            var t = (h <= 1) ? 0.0 : yy.toFloat() / (h - 1).toFloat();
            var rgb = blendRgb(cTop, cBot, t);
            dc.setColor(rgb, rgb);
            dc.fillRectangle(x, y + yy, w, 1);
            yy++;
        }

        dc.setColor(Constants.COLOR_SELECTION_OUTLINE, Graphics.COLOR_TRANSPARENT);
        dc.drawRectangle(x, y, w, h);
        dc.setColor(Constants.COLOR_ACTIVE_BORDER, Graphics.COLOR_TRANSPARENT);
        dc.drawLine(x + 2, y + 1, x + w - 3, y + 1);
        dc.setColor(Constants.COLOR_SELECTION_OUTLINE, Graphics.COLOR_TRANSPARENT);
        dc.drawLine(x + 2, y + h - 2, x + w - 3, y + h - 2);
    }
}
