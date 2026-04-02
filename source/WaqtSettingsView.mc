using Toybox.Graphics;
using Toybox.WatchUi;

class WaqtSettingsView extends WatchUi.View {

    var _selected = 1;
    const _items = ["Select location", "Find Qibla", "About"];

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

                dc.setColor(Constants.COLOR_ACTIVE, Constants.COLOR_ACTIVE);
                dc.fillPolygon([
                    [bgLeft + slant, selY],
                    [bgRight, selY],
                    [bgRight, selY + selH],
                    [bgLeft, selY + selH]
                ]);

                var bw = 5;
                dc.setColor(Constants.COLOR_ACTIVE_BORDER, Constants.COLOR_ACTIVE_BORDER);
                dc.fillPolygon([
                    [bgLeft + slant, selY],
                    [bgLeft + slant + bw, selY],
                    [bgLeft + bw, selY + selH],
                    [bgLeft, selY + selH]
                ]);

                dc.setColor(Constants.COLOR_BG, Graphics.COLOR_TRANSPARENT);
            } else {
                dc.setColor(Constants.COLOR_GRAY, Graphics.COLOR_TRANSPARENT);
            }

            var textY = y + ((rowH - 60) / 2) + 16;
            if (isCentered) {
                // Slightly raise selected text to create a touch more bottom padding.
                textY = textY - 7;
            }
            dc.drawText(cx, textY, Graphics.FONT_TINY, _items[itemIdx], Graphics.TEXT_JUSTIFY_CENTER);
            if (isCentered) {
                // Overdraw selected settings text for stronger boldness.
                dc.drawText(cx + 1, textY, Graphics.FONT_TINY, _items[itemIdx], Graphics.TEXT_JUSTIFY_CENTER);
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
