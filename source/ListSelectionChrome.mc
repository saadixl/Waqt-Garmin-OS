using Toybox.Graphics;

module ListSelectionChrome {
    // Solid Qibla outer-ring brass (Constants.COLOR_ACTIVE_MID); slanted bar, one fill per scanline.
    function fillSlantedSelectionBar(dc, bgLeft, bgRight, slant, topY, barH) {
        if (barH < 1) {
            return;
        }
        var fill = Constants.COLOR_ACTIVE_MID;
        var yy = 0;
        while (yy < barH) {
            var xL = bgLeft;
            if (barH > 1) {
                xL = bgLeft + (slant * (barH - 1 - yy)) / (barH - 1);
            } else {
                xL = bgLeft + slant;
            }
            var rowW = bgRight - xL;
            if (rowW > 0) {
                dc.setColor(fill, fill);
                dc.fillRectangle(xL, topY + yy, rowW, 1);
            }
            yy++;
        }
    }

    // Light brass strip on the slanted edge; bottom Y must match fillSlantedSelectionBar (last row = topY + barH - 1).
    function fillSlantedLeftAccent(dc, bgLeft, topY, barH, slant, bw) {
        if (barH < 1 || bw < 1) {
            return;
        }
        var yBot = topY + barH - 1;
        dc.setColor(Constants.COLOR_ACTIVE_BORDER, Constants.COLOR_ACTIVE_BORDER);
        dc.fillPolygon([
            [bgLeft + slant, topY],
            [bgLeft + slant + bw, topY],
            [bgLeft + bw, yBot],
            [bgLeft, yBot]
        ]);
    }
}
