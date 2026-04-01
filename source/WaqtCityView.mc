using Toybox.Graphics;
using Toybox.WatchUi;

class WaqtCityView extends WatchUi.View {

    var _service;
    var _selectionOffset = 0;

    function initialize(service) {
        View.initialize();
        _service = service;
        _selectionOffset = service.getCityIndex();
    }

    function getSelectedIndex() {
        return _selectionOffset;
    }

    function scrollUp() {
        _selectionOffset = (_selectionOffset - 1 + CityData.CITY_COUNT) % CityData.CITY_COUNT;
        WatchUi.requestUpdate();
    }

    function scrollDown() {
        _selectionOffset = (_selectionOffset + 1) % CityData.CITY_COUNT;
        WatchUi.requestUpdate();
    }

    function onUpdate(dc) {
        var width = dc.getWidth();
        var height = dc.getHeight();
        var cx = width / 2;
        var cy = height / 2;
        var radius = width / 2;

        dc.setColor(Constants.COLOR_BG, Constants.COLOR_BG);
        dc.clear();

        // Header
        dc.setColor(Constants.COLOR_ACTIVE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, 24, Graphics.FONT_XTINY, "Select City", Graphics.TEXT_JUSTIFY_CENTER);

        var currentCityIdx = _service.getCityIndex();
        var itemHeight = 92;
        var highlightedHeight = 104;
        var gap = 8;
        var startY = 74;
        var textLeft = 64;
        var textRight = width - 64;

        for (var i = 0; i < 3; i++) {
            var cityIdx = (_selectionOffset - 1 + i + CityData.CITY_COUNT) % CityData.CITY_COUNT;
            var isCentered = (i == 1);
            var isCurrentCity = (cityIdx == currentCityIdx);

            // Calculate itemY accounting for taller center item
            var itemY;
            var currentHeight;
            if (i == 0) {
                itemY = startY;
                currentHeight = itemHeight;
            } else if (i == 1) {
                itemY = startY + itemHeight + gap;
                currentHeight = highlightedHeight;
            } else {
                itemY = startY + itemHeight + gap + highlightedHeight + gap;
                currentHeight = itemHeight;
            }

            // Content vertical offset to center within item
            var contentOffset = (currentHeight - 90) / 2;

            // Background - orange bar with angled left edge
            if (isCentered) {
                var topDy = itemY - cy;
                var botDy = itemY + currentHeight - cy;
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
                var bgWidth = bgRight - bgLeft;
                var slant = 20;

                // Main orange fill with angled left edge
                dc.setColor(Constants.COLOR_ACTIVE, Constants.COLOR_ACTIVE);
                dc.fillPolygon([
                    [bgLeft + slant, itemY],
                    [bgRight, itemY],
                    [bgRight, itemY + currentHeight],
                    [bgLeft, itemY + currentHeight]
                ]);


                // Diagonal border along angled edge (as polygon to stay within bounds)
                var bw = 5;
                dc.setColor(Constants.COLOR_ACTIVE_BORDER, Constants.COLOR_ACTIVE_BORDER);
                dc.fillPolygon([
                    [bgLeft + slant, itemY],
                    [bgLeft + slant + bw, itemY],
                    [bgLeft + bw, itemY + currentHeight],
                    [bgLeft, itemY + currentHeight]
                ]);
            }

            // City name (left) - large font
            var nameColor = Constants.COLOR_TEXT;
            if (isCentered) {
                nameColor = Constants.COLOR_BG;
            } else if (isCurrentCity) {
                nameColor = Constants.COLOR_ACTIVE;
            }

            dc.setColor(nameColor, Graphics.COLOR_TRANSPARENT);
            dc.drawText(textLeft, itemY + contentOffset, Graphics.FONT_TINY, CityData.getCityName(cityIdx), Graphics.TEXT_JUSTIFY_LEFT);
            if (isCentered) {
                // Overdraw selected row text for stronger boldness.
                dc.drawText(textLeft + 1, itemY + contentOffset, Graphics.FONT_TINY, CityData.getCityName(cityIdx), Graphics.TEXT_JUSTIFY_LEFT);
            }

            // Qibla degree (right)
            var qibla = CityData.calculateQibla(cityIdx);
            var qiblaColor = Constants.COLOR_GRAY;
            if (isCentered) {
                qiblaColor = Constants.COLOR_BG;
            }
            dc.setColor(qiblaColor, Graphics.COLOR_TRANSPARENT);
            dc.drawText(textRight, itemY + contentOffset + 4, Graphics.FONT_XTINY, qibla + "\u00B0", Graphics.TEXT_JUSTIFY_RIGHT);
            if (isCentered) {
                dc.drawText(textRight + 1, itemY + contentOffset + 4, Graphics.FONT_XTINY, qibla + "\u00B0", Graphics.TEXT_JUSTIFY_RIGHT);
            }

            // Country name below city - with clear gap
            var countryColor = Constants.COLOR_GRAY;
            if (isCentered) {
                countryColor = Constants.COLOR_TEXT;
            }
            dc.setColor(countryColor, Graphics.COLOR_TRANSPARENT);
            dc.drawText(textLeft, itemY + contentOffset + 48, Graphics.FONT_XTINY, CityData.getCityCountry(cityIdx), Graphics.TEXT_JUSTIFY_LEFT);
        }

        // Tick cue (city list): indicates selection/confirmation action.
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

        // Up/Down cues at bottom-center, close together, in orange.
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
