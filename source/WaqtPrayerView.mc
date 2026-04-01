using Toybox.Graphics;
using Toybox.WatchUi;
using Toybox.Timer;
using Toybox.System;

class WaqtPrayerView extends WatchUi.View {

    var _service;
    var _timer = null;
    var _rotationOffset = 0;
    var _dataLoaded = false;
    var _isLoading = false;
    var _initialLoad = true;
    var _errorMessage = null;

    function initialize(service) {
        View.initialize();
        _service = service;
    }

    function onLayout(dc) {
    }

    function onShow() {
        if (!_dataLoaded && !_isLoading) {
            _isLoading = true;
            _service.fetchPrayerTimes(method(:onDataReceived));
        }

        _timer = new Timer.Timer();
        var callback = method(:onTimerTick);
        _timer.start(callback, 1000, true);
    }

    function onHide() {
        if (_timer != null) {
            _timer.stop();
            _timer = null;
        }
    }

    function onDataReceived(success) {
        _isLoading = false;
        if (success) {
            _dataLoaded = true;
            _errorMessage = null;

            if (_initialLoad) {
                _rotationOffset = _service.getNextPrayerIndex();
                _rotationOffset = (_rotationOffset - 1 + Constants.PRAYER_COUNT) % Constants.PRAYER_COUNT;
                _initialLoad = false;
            }
        } else {
            _errorMessage = "Failed to load";
        }
        WatchUi.requestUpdate();
    }

    function onTimerTick() as Void {
        if (_dataLoaded) {
            WatchUi.requestUpdate();
        }
    }

    function scrollUp() {
        _rotationOffset = (_rotationOffset - 1 + Constants.PRAYER_COUNT) % Constants.PRAYER_COUNT;
        WatchUi.requestUpdate();
    }

    function scrollDown() {
        _rotationOffset = (_rotationOffset + 1) % Constants.PRAYER_COUNT;
        WatchUi.requestUpdate();
    }

    function refreshData() {
        _isLoading = true;
        _initialLoad = true;
        _service.fetchPrayerTimes(method(:onDataReceived));
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

        if (_isLoading && !_dataLoaded) {
            dc.setColor(Constants.COLOR_TEXT, Graphics.COLOR_TRANSPARENT);
            dc.drawText(cx, cy - 10, Graphics.FONT_XTINY, "Loading...", Graphics.TEXT_JUSTIFY_CENTER);
            return;
        }

        if (_errorMessage != null) {
            dc.setColor(Constants.COLOR_ERROR, Graphics.COLOR_TRANSPARENT);
            dc.drawText(cx, cy - 10, Graphics.FONT_XTINY, _errorMessage, Graphics.TEXT_JUSTIFY_CENTER);
            return;
        }

        if (!_dataLoaded) {
            return;
        }

        // Header: City name (cyan) centered
        var cityName = CityData.getCityName(_service.getCityIndex());
        var qibla = CityData.calculateQibla(_service.getCityIndex());

        dc.setColor(Constants.COLOR_ACTIVE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, 20, Graphics.FONT_XTINY, cityName, Graphics.TEXT_JUSTIFY_CENTER);

        // Qibla (white) centered below city - more space
        dc.setColor(Constants.COLOR_TEXT, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, 50, Graphics.FONT_XTINY, "Qibla " + qibla + "\u00B0", Graphics.TEXT_JUSTIFY_CENTER);

        // 3 prayer items
        var nextPrayerIdx = _service.getNextPrayerIndex();
        var itemHeight = 90;
        var gap = 5;
        var startY = 90;

        // Text margins - inset from circle edge
        var textLeft = 60;
        var textRight = width - 60;

        var highlightedHeight = 110;

        for (var i = 0; i < 3; i++) {
            var prayerIdx = (_rotationOffset + i) % Constants.PRAYER_COUNT;
            var isCentered = (i == 1);
            var isNextPrayer = (prayerIdx == nextPrayerIdx);

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

            // Highlighted item: orange bar with angled left edge
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

            // Color for prayer name + time
            var nameColor;
            if (isCentered) {
                nameColor = Constants.COLOR_BG;
            } else if (isNextPrayer) {
                nameColor = Constants.COLOR_ACTIVE;
            } else {
                nameColor = Constants.COLOR_TEXT;
            }

            // Row 1: Prayer name (left) + Time (right)
            dc.setColor(nameColor, Graphics.COLOR_TRANSPARENT);
            dc.drawText(textLeft, itemY + contentOffset, Graphics.FONT_TINY, Constants.PRAYER_NAMES[prayerIdx], Graphics.TEXT_JUSTIFY_LEFT);

            var timeStr = _service.getFormattedTime(prayerIdx);
            dc.setColor(nameColor, Graphics.COLOR_TRANSPARENT);
            dc.drawText(textRight, itemY + contentOffset, Graphics.FONT_TINY, timeStr, Graphics.TEXT_JUSTIFY_RIGHT);

            // Row 2: Countdown below prayer name
            var seconds = _service.getSecondsUntilPrayer(prayerIdx);
            var remainStr;
            if (isNextPrayer || isCentered) {
                remainStr = _service.formatCountdown(seconds);
            } else {
                remainStr = _service.formatShortTime(seconds);
            }

            var remainColor;
            if (isCentered) {
                remainColor = Constants.COLOR_TEXT;
            } else {
                remainColor = Constants.COLOR_GRAY;
            }

            dc.setColor(remainColor, Graphics.COLOR_TRANSPARENT);
            dc.drawText(textLeft, itemY + contentOffset + 50, Graphics.FONT_XTINY, remainStr, Graphics.TEXT_JUSTIFY_LEFT);
        }

        // Location-pin cue aligned with physical START button on FR970.
        var pinX = width - 35;
        var pinY = cy - 90;
        dc.setColor(Constants.COLOR_ACTIVE_BORDER, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(pinX, pinY, 6);
        dc.fillPolygon([
            [pinX - 4, pinY + 3],
            [pinX + 4, pinY + 3],
            [pinX, pinY + 11]
        ]);
        // Inner cutout so it reads like a map/location pin.
        dc.setColor(Constants.COLOR_BG, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(pinX, pinY, 2);

        // Up/Down cues at bottom-center, close together, in orange.
        var arrowX = cx;
        var upY = height - 34;
        var downY = height - 20;
        dc.setColor(Constants.COLOR_ACTIVE, Graphics.COLOR_TRANSPARENT);
        dc.fillPolygon([
            [arrowX, upY - 6],
            [arrowX - 6, upY + 4],
            [arrowX + 6, upY + 4]
        ]);
        dc.fillPolygon([
            [arrowX, downY + 6],
            [arrowX - 6, downY - 4],
            [arrowX + 6, downY - 4]
        ]);
    }
}
