using Toybox.Graphics;
using Toybox.WatchUi;
using Toybox.Timer;

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
            var hint = _service.getLastFetchError();
            if (hint != null) {
                _errorMessage = hint;
            } else {
                _errorMessage = "Failed to load";
            }
        }
        WatchUi.requestUpdate();
    }

    function onTimerTick() as Void {
        if (CityData.isAutoDetect(_service.getCityIndex())) {
            _service.sampleGpsFromPosition();
        }
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
            dc.setColor(Constants.COLOR_GRAY, Graphics.COLOR_TRANSPARENT);
            dc.drawText(cx, cy - 10, Graphics.FONT_XTINY, "Loading...", Graphics.TEXT_JUSTIFY_CENTER);
            return;
        }

        if (_errorMessage != null) {
            dc.setColor(Constants.COLOR_ERROR, Graphics.COLOR_TRANSPARENT);
            var nl = _errorMessage.find("\n");
            if (nl == null) {
                dc.drawText(cx, cy - 10, Graphics.FONT_XTINY, _errorMessage, Graphics.TEXT_JUSTIFY_CENTER);
            } else {
                var lineA = _errorMessage.substring(0, nl);
                var lineB = _errorMessage.substring(nl + 1, _errorMessage.length());
                dc.drawText(cx, cy - 24, Graphics.FONT_XTINY, lineA, Graphics.TEXT_JUSTIFY_CENTER);
                dc.drawText(cx, cy - 6, Graphics.FONT_XTINY, lineB, Graphics.TEXT_JUSTIFY_CENTER);
            }
            return;
        }

        if (!_dataLoaded) {
            return;
        }

        // Header: coordinates when auto-detect, else city name (brass accent)
        var headerLoc = _service.getPrayerHeaderLocationLabel();
        var idx = _service.getCityIndex();
        var qiblaStr;
        if (CityData.isAutoDetect(idx)) {
            if (_service.hasGpsFix()) {
                qiblaStr = CityData.bearingFromLatLonDegrees(_service.getAutoLat(), _service.getAutoLon()).toString();
            } else {
                qiblaStr = "--";
            }
        } else {
            qiblaStr = CityData.calculateQibla(idx).toString();
        }

        dc.setColor(Constants.COLOR_ACTIVE_BORDER, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, 20, Graphics.FONT_XTINY, headerLoc, Graphics.TEXT_JUSTIFY_CENTER);

        dc.setColor(Constants.COLOR_PRIMARY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, 50, Graphics.FONT_XTINY, "Qibla " + qiblaStr + "\u00B0", Graphics.TEXT_JUSTIFY_CENTER);

        // 3 prayer items
        var nextPrayerIdx = _service.getNextPrayerIndex();
        var itemHeight = 92;
        var gap = 8;
        var startY = 94;

        // Text margins - inset from circle edge
        var textLeft = 64;
        var textRight = width - 64;

        var highlightedHeight = 104;

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

            // Highlighted item: brass bar with angled left edge
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

                ListSelectionChrome.fillSlantedSelectionBar(
                    dc,
                    bgLeft,
                    bgRight,
                    slant,
                    itemY,
                    currentHeight
                );

                var bw = 5;
                ListSelectionChrome.fillSlantedLeftAccent(dc, bgLeft, itemY, currentHeight, slant, bw);
            }

            // Color for prayer name + time
            var nameColor;
            if (isCentered) {
                nameColor = Graphics.COLOR_WHITE;
            } else if (isNextPrayer) {
                nameColor = Constants.COLOR_PRIMARY;
            } else {
                nameColor = Constants.COLOR_TEXT;
            }

            var timeColor;
            if (isCentered) {
                timeColor = Graphics.COLOR_WHITE;
            } else if (isNextPrayer) {
                timeColor = Constants.COLOR_PRIMARY;
            } else {
                timeColor = Constants.COLOR_GRAY;
            }

            // Row 1: Prayer name (left) + Time (right)
            var rowFont = Graphics.FONT_TINY;
            var subFont = Graphics.FONT_XTINY;
            if (isCentered) {
                // Use heavier system fonts for the selected prayer row.
                rowFont = Graphics.FONT_SYSTEM_TINY;
                subFont = Graphics.FONT_SYSTEM_XTINY;
            }

            dc.setColor(nameColor, Graphics.COLOR_TRANSPARENT);
            dc.drawText(textLeft, itemY + contentOffset, rowFont, Constants.PRAYER_NAMES[prayerIdx], Graphics.TEXT_JUSTIFY_LEFT);
            if (isCentered) {
                // Overdraw selected row text for a stronger bold look.
                dc.drawText(textLeft + 1, itemY + contentOffset, rowFont, Constants.PRAYER_NAMES[prayerIdx], Graphics.TEXT_JUSTIFY_LEFT);
            }

            var timeStr = _service.getFormattedTime(prayerIdx);
            dc.setColor(timeColor, Graphics.COLOR_TRANSPARENT);
            dc.drawText(textRight, itemY + contentOffset, rowFont, timeStr, Graphics.TEXT_JUSTIFY_RIGHT);
            if (isCentered) {
                dc.drawText(textRight + 1, itemY + contentOffset, rowFont, timeStr, Graphics.TEXT_JUSTIFY_RIGHT);
            }

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
                remainColor = Graphics.COLOR_WHITE;
            } else if (isNextPrayer) {
                remainColor = Constants.COLOR_PRIMARY;
            } else {
                remainColor = Constants.COLOR_GRAY;
            }

            dc.setColor(remainColor, Graphics.COLOR_TRANSPARENT);
            dc.drawText(textLeft, itemY + contentOffset + 48, subFont, remainStr, Graphics.TEXT_JUSTIFY_LEFT);
        }

        // Settings cue aligned with physical START button on FR970.
        var gearX = width - 33;
        var gearY = cy - 86;
        dc.setColor(Constants.COLOR_ACTIVE_BORDER, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(gearX, gearY, 5);
        // Inner cutout for gear ring.
        dc.setColor(Constants.COLOR_BG, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(gearX, gearY, 2);
        // Small teeth around the ring.
        dc.setColor(Constants.COLOR_ACTIVE_BORDER, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(gearX, gearY - 7, 1);
        dc.fillCircle(gearX, gearY + 7, 1);
        dc.fillCircle(gearX - 7, gearY, 1);
        dc.fillCircle(gearX + 7, gearY, 1);
        dc.fillCircle(gearX - 5, gearY - 5, 1);
        dc.fillCircle(gearX + 5, gearY - 5, 1);
        dc.fillCircle(gearX - 5, gearY + 5, 1);
        dc.fillCircle(gearX + 5, gearY + 5, 1);

        // Up/Down cues at bottom-center, close together, brass.
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
