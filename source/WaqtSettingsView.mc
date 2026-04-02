using Toybox.Graphics;
using Toybox.WatchUi;

class WaqtSettingsView extends WatchUi.View {

    var _selected = 1;
    const _items = ["Set Location", "Find Qibla", "About"];

    function initialize() {
        View.initialize();
    }

    function scrollUp() {
        _selected = (_selected - 1 + _items.size()) % _items.size();
        WatchUi.requestUpdate();
    }

    function scrollDown() {
        _selected = (_selected + 1) % _items.size();
        WatchUi.requestUpdate();
    }

    function getSelectedIndex() {
        return _selected;
    }

    function onUpdate(dc) {
        var width = dc.getWidth();
        var height = dc.getHeight();
        var cx = width / 2;
        var cy = height / 2;
        var radius = width / 2;
        var itemHeight = 70;
        var highlightedHeight = 88;
        var rowGap = 8;
        // Force selected (middle) row center to align exactly with screen center.
        var selectedY = cy - (highlightedHeight / 2);
        var startY = selectedY - itemHeight - rowGap;

        dc.setColor(Constants.COLOR_BG, Constants.COLOR_BG);
        dc.clear();

        var listLeft = 64;

        dc.setColor(Constants.COLOR_ACTIVE_BORDER, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, 34, Graphics.FONT_TINY, "Settings", Graphics.TEXT_JUSTIFY_CENTER);

        // Draw 3 visible rows and keep selected item pinned to middle row.
        for (var i = 0; i < 3; i++) {
            var itemIdx = (_selected - 1 + i + _items.size()) % _items.size();
            var isCentered = (i == 1);
            var y;
            var rowH;

            if (i == 0) {
                y = startY;
                rowH = itemHeight;
            } else if (i == 1) {
                y = startY + itemHeight + rowGap;
                rowH = highlightedHeight;
            } else {
                y = startY + itemHeight + rowGap + highlightedHeight + rowGap;
                rowH = itemHeight;
            }

            if (isCentered) {
                // Match prayer/city selection style: angled brass bar with border.
                var selY = y;
                var selH = rowH;

                var topDy = selY - cy;
                var botDy = selY + selH - cy;
                if (topDy < 0) { topDy = -topDy; }
                if (botDy < 0) { botDy = -botDy; }
                var maxDy = topDy;
                if (botDy > maxDy) { maxDy = botDy; }
                var halfW = radius;
                if (maxDy < radius) {
                    var sq = radius * radius - maxDy * maxDy;
                    var s = 1;
                    while (s * s <= sq) { s++; }
                    halfW = s - 1;
                }
                var bgLeft = cx - halfW + 5;
                var bgRight = cx + halfW - 5;
                var slant = 20;

                ListSelectionChrome.fillSlantedSelectionBar(
                    dc,
                    bgLeft,
                    bgRight,
                    slant,
                    selY,
                    selH
                );

                var bw = 5;
                ListSelectionChrome.fillSlantedLeftAccent(dc, bgLeft, selY, selH, slant, bw);

                dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            } else {
                dc.setColor(Constants.COLOR_GRAY, Graphics.COLOR_TRANSPARENT);
            }

            var rowMidY = y + rowH / 2;
            if (isCentered) {
                rowMidY = rowMidY - 7;
            }
            var rowFont = Graphics.FONT_TINY;
            var vjust = Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER;
            dc.drawText(listLeft, rowMidY, rowFont, _items[itemIdx], vjust);
            if (isCentered) {
                dc.drawText(listLeft + 1, rowMidY, rowFont, _items[itemIdx], vjust);
            }
        }

        // Tick cue (settings): same as city list page.
        var tickX = width - 33;
        var tickY = cy - 86;
        dc.setColor(Constants.COLOR_ACTIVE_BORDER, Graphics.COLOR_TRANSPARENT);
        dc.drawLine(tickX - 5, tickY, tickX - 1, tickY + 4);
        dc.drawLine(tickX - 1, tickY + 4, tickX + 6, tickY - 4);

        // Back cue near physical BACK button (lower-right).
        var backX = width - 35;
        var backY = cy + 102;
        dc.setColor(Constants.COLOR_ACTIVE_BORDER, Graphics.COLOR_TRANSPARENT);
        dc.drawLine(backX + 4, backY - 5, backX - 3, backY);
        dc.drawLine(backX - 3, backY, backX + 4, backY + 5);

        // Bottom nav cues (up/down) for settings list.
        var arrowX = cx;
        var upY = height - 32;
        var downY = height - 20;
        dc.setColor(Constants.COLOR_ACTIVE, Graphics.COLOR_TRANSPARENT);
        dc.fillPolygon([
            [arrowX, upY - 5],
            [arrowX - 5, upY + 3],
            [arrowX + 5, upY + 3]
        ]);
        dc.fillPolygon([
            [arrowX, downY + 5],
            [arrowX - 5, downY - 3],
            [arrowX + 5, downY - 3]
        ]);

    }
}
