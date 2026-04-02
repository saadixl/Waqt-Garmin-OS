using Toybox.Graphics;
using Toybox.Math;
using Toybox.Sensor;
using Toybox.Timer;
using Toybox.WatchUi;

class WaqtQiblaPlaceholderView extends WatchUi.View {

    var _service;
    var _timer = null;

    function initialize(service) {
        View.initialize();
        _service = service;
    }

    function onShow() {
        _timer = new Timer.Timer();
        _timer.start(method(:onTick), 500, true);
    }

    function onHide() {
        if (_timer != null) {
            _timer.stop();
            _timer = null;
        }
    }

    function onTick() as Void {
        WatchUi.requestUpdate();
    }

    function normalizeHeadingDeg(deg) {
        while (deg < 0.0) {
            deg += 360.0;
        }
        while (deg >= 360.0) {
            deg -= 360.0;
        }
        return deg;
    }

    function onUpdate(dc) {
        var width = dc.getWidth();
        var height = dc.getHeight();
        var cx = width / 2;
        var cy = height / 2;
        var cityIdx = _service.getCityIndex();
        var cityName = CityData.getCityName(cityIdx);
        var qiblaBearing = CityData.calculateQibla(cityIdx).toFloat();

        dc.setColor(Constants.COLOR_BG, Constants.COLOR_BG);
        dc.clear();

        // Compass palette — brass housing, deep bowl face, maritime ticks
        var cFaceOuter = 0x1A2430;
        var cFaceMid = 0x232F3C;
        var cFaceHub = 0x2D3C4C;
        var cBrassInner = 0x5A4C38;
        var cBrassOuter = Constants.COLOR_ACTIVE_MID;
        var cRail = 0x121820;
        var cVoid = 0x080D14;
        var cTickMaj = 0xC8BCAC;
        var cTickMin = 0x5E5852;
        var cNorth = 0x8E2A3C; // maroon — north cardinal
        var cCardIvory = 0xDCD8D0;
        var cDegText = 0xA8B8C4;
        var cCityText = 0xD4A84A;
        var cNeedleSh = Constants.COLOR_PRIMARY_DARK;
        var cNeedleBody = Constants.COLOR_PRIMARY;
        var cNeedleEdge = Constants.COLOR_PRIMARY_LIGHT;
        var cHubRim = 0x7A6848;
        var cHubCore = 0x2A2420;
        var cKaabaWall = 0x141820;
        var cKaabaBand = 0xC49A28;

        // Live heading in degrees (0 = north, clockwise). Used to rotate the rose + hand.
        var headingDeg = 0.0;
        var info = Sensor.getInfo();
        if (info != null && info.heading != null) {
            headingDeg = normalizeHeadingDeg(info.heading.toFloat() * 180.0 / Math.PI);
        }

        // Two thick metal rings: outer edge ~90% screenR; wide bands (not 2× diameter).
        var compassCy = cy;
        var screenR = width < height ? width / 2 : height / 2;
        var edgeInset = 3;
        var ring90Outer = (screenR * 90) / 100;
        if (ring90Outer > screenR - edgeInset) {
            ring90Outer = screenR - edgeInset;
        }
        var bandOuter = (screenR * 14) / 100;
        if (bandOuter < 10) {
            bandOuter = 10;
        }
        if (bandOuter > 32) {
            bandOuter = 32;
        }
        var ring90Inner = ring90Outer - bandOuter;
        var ringMidGap = (screenR * 2) / 100;
        if (ringMidGap < 2) {
            ringMidGap = 2;
        }
        if (ringMidGap > 6) {
            ringMidGap = 6;
        }
        var ring80 = ring90Inner - ringMidGap;
        if (ring80 < 36) {
            ring80 = 36;
        }
        var bandInner = (screenR * 12) / 100;
        if (bandInner < 8) {
            bandInner = 8;
        }
        if (bandInner > 26) {
            bandInner = 26;
        }
        var ring80Inner = ring80 - bandInner;
        if (ring80Inner < 20) {
            ring80Inner = 20;
            ring80 = ring80Inner + bandInner;
            if (ring80 >= ring90Inner) {
                ring90Inner = ring80 + ringMidGap;
                ring90Outer = ring90Inner + bandOuter;
                if (ring90Outer > screenR - edgeInset) {
                    ring90Outer = screenR - edgeInset;
                }
            }
        }

        var innerPad = (ring80Inner * 12) / 100;
        if (innerPad < 10) {
            innerPad = 10;
        }
        var hubR = (ring80Inner * 15) / 100;
        if (hubR < 14) {
            hubR = 14;
        }
        if (hubR > 26) {
            hubR = 26;
        }

        // Inner compass face — deep “bowl” (inside inner brass ring)
        dc.setColor(cFaceOuter, cFaceOuter);
        dc.fillCircle(cx, compassCy, ring80Inner - 2);
        dc.setColor(cFaceMid, cFaceMid);
        dc.fillCircle(cx, compassCy, ring80Inner - innerPad);
        dc.setColor(cFaceHub, cFaceHub);
        dc.fillCircle(cx, compassCy, hubR);

        // Inner brass ring
        dc.setColor(cBrassInner, cBrassInner);
        dc.fillCircle(cx, compassCy, ring80);
        dc.setColor(cFaceOuter, cFaceOuter);
        dc.fillCircle(cx, compassCy, ring80Inner - 2);
        dc.setColor(cFaceMid, cFaceMid);
        dc.fillCircle(cx, compassCy, ring80Inner - innerPad);
        dc.setColor(cFaceHub, cFaceHub);
        dc.fillCircle(cx, compassCy, hubR);

        // Outer brass ring, then restore interior
        dc.setColor(cBrassOuter, cBrassOuter);
        dc.fillCircle(cx, compassCy, ring90Outer);
        dc.setColor(cVoid, cVoid);
        dc.fillCircle(cx, compassCy, ring90Inner - 1);
        dc.setColor(cBrassInner, cBrassInner);
        dc.fillCircle(cx, compassCy, ring80);
        dc.setColor(cFaceOuter, cFaceOuter);
        dc.fillCircle(cx, compassCy, ring80Inner - 2);
        dc.setColor(cFaceMid, cFaceMid);
        dc.fillCircle(cx, compassCy, ring80Inner - innerPad);
        dc.setColor(cFaceHub, cFaceHub);
        dc.fillCircle(cx, compassCy, hubR);

        // Dark rails (brass bezel edges)
        dc.setColor(cRail, Graphics.COLOR_TRANSPARENT);
        dc.drawCircle(cx, compassCy, ring80Inner);
        dc.drawCircle(cx, compassCy, ring80);
        dc.drawCircle(cx, compassCy, ring90Inner);
        dc.drawCircle(cx, compassCy, ring90Outer);

        // Tick marks — outer edge at 90% ring
        for (var d = 0; d < 360; d += 15) {
            var a = ((d - headingDeg) - 90.0) * Math.PI / 180.0;
            var outer = ring90Outer;
            var tickLen = 4;
            if ((d % 45) == 0) {
                tickLen = 8;
            }
            dc.setColor((d % 45) == 0 ? cTickMaj : cTickMin, Graphics.COLOR_TRANSPARENT);
            var ix = cx + ((outer - tickLen) * Math.cos(a)).toNumber();
            var iy = compassCy + ((outer - tickLen) * Math.sin(a)).toNumber();
            var ox = cx + (outer * Math.cos(a)).toNumber();
            var oy = compassCy + (outer * Math.sin(a)).toNumber();
            dc.drawLine(ix, iy, ox, oy);
        }

        // N/E/S/W centered on outer black circle (ring90Outer — yellow vs outer black)
        var labelR = ring90Outer;
        if (labelR > screenR - 4) {
            labelR = screenR - 4;
        }
        var cardJust = Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER;
        var cardFont = Graphics.FONT_SYSTEM_TINY;
        dc.setColor(cNorth, Graphics.COLOR_TRANSPARENT);
        var aN = ((0.0 - headingDeg) - 90.0) * Math.PI / 180.0;
        var nX = cx + (labelR * Math.cos(aN)).toNumber();
        var nY = compassCy + (labelR * Math.sin(aN)).toNumber();
        dc.drawText(nX, nY, cardFont, "N", cardJust);
        dc.drawText(nX + 1, nY, cardFont, "N", cardJust);
        dc.setColor(cCardIvory, Graphics.COLOR_TRANSPARENT);
        var aE = ((90.0 - headingDeg) - 90.0) * Math.PI / 180.0;
        var eX = cx + (labelR * Math.cos(aE)).toNumber();
        var eY = compassCy + (labelR * Math.sin(aE)).toNumber();
        dc.drawText(eX, eY, cardFont, "E", cardJust);
        dc.drawText(eX + 1, eY, cardFont, "E", cardJust);
        var aS = ((180.0 - headingDeg) - 90.0) * Math.PI / 180.0;
        var sX = cx + (labelR * Math.cos(aS)).toNumber();
        var sY = compassCy + (labelR * Math.sin(aS)).toNumber();
        dc.drawText(sX, sY, cardFont, "S", cardJust);
        dc.drawText(sX + 1, sY, cardFont, "S", cardJust);
        var aW = ((270.0 - headingDeg) - 90.0) * Math.PI / 180.0;
        var wX = cx + (labelR * Math.cos(aW)).toNumber();
        var wY = compassCy + (labelR * Math.sin(aW)).toNumber();
        dc.drawText(wX, wY, cardFont, "W", cardJust);
        dc.drawText(wX + 1, wY, cardFont, "W", cardJust);

        // Bearing above, city below — each on midpoint from center to inner black border (ring80Inner)
        var radialMid = ring80Inner / 2;
        if (radialMid < hubR + 12) {
            radialMid = hubR + 12;
        }
        if (radialMid > ring80Inner - 8) {
            radialMid = ring80Inner - 8;
        }
        var labelDistFromCenter = radialMid;
        var cityY = compassCy + labelDistFromCenter;
        var degY = compassCy - (cityY - compassCy);
        var textJust = Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER;
        dc.setColor(cDegText, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, degY, Graphics.FONT_XTINY, qiblaBearing.toNumber() + "\u00B0", textJust);
        dc.setColor(cCityText, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, cityY, Graphics.FONT_XTINY, cityName, textJust);

        // Kaaba first so the Qibla hand draws on top when it aligns toward Mecca.
        var kw = (ring90Outer * 32) / 100;
        if (kw < 34) {
            kw = 34;
        }
        if (kw > 58) {
            kw = 58;
        }
        var kh = (kw * 28) / 24;
        // 25% smaller than previous sizing
        kw = (kw * 75) / 100;
        kh = (kh * 75) / 100;
        if (kw < 1) {
            kw = 1;
        }
        if (kh < 1) {
            kh = 1;
        }
        var kx = cx;
        var gapAboveKaaba = (screenR * 10) / 100;
        var ky = compassCy - screenR + gapAboveKaaba + (kh / 2);
        dc.setColor(cKaabaWall, cKaabaWall);
        dc.fillRectangle(kx - (kw / 2), ky - (kh / 2), kw, kh);
        dc.setColor(cKaabaBand, cKaabaBand);
        var goldY = ky - (kh / 2) + (kh / 5);
        var goldH = (kh / 4);
        if (goldH < 4) {
            goldH = 4;
        }
        dc.fillRectangle(kx - (kw / 2), goldY, kw, goldH);
        dc.setColor(cCardIvory, Graphics.COLOR_TRANSPARENT);
        dc.drawRectangle(kx - (kw / 2), ky - (kh / 2), kw, kh);

        // Cyan Qibla hand (matches app accent) toward Mecca on the rotating rose.
        var deltaQ = normalizeHeadingDeg(qiblaBearing - headingDeg);
        var rad = (deltaQ - 90.0) * Math.PI / 180.0;
        var tipMargin = (ring90Outer * 12) / 100;
        if (tipMargin < 14) {
            tipMargin = 14;
        }
        var tipR = ring90Outer - tipMargin;
        var baseR = (ring90Outer * 15) / 100;
        if (baseR < 18) {
            baseR = 18;
        }
        if (baseR > 32) {
            baseR = 32;
        }
        var halfW = ring90Outer / 20.0;
        if (halfW < 7.0) {
            halfW = 7.0;
        }
        if (halfW > 11.0) {
            halfW = 11.0;
        }
        var tx = cx + (tipR * Math.cos(rad)).toNumber();
        var ty = compassCy + (tipR * Math.sin(rad)).toNumber();
        var bx = cx + (baseR * Math.cos(rad)).toNumber();
        var by = compassCy + (baseR * Math.sin(rad)).toNumber();
        var px = Math.cos(rad + (Math.PI / 2.0));
        var py = Math.sin(rad + (Math.PI / 2.0));
        var lx = bx + (halfW * px).toNumber();
        var ly = by + (halfW * py).toNumber();
        var rx = bx - (halfW * px).toNumber();
        var ry = by - (halfW * py).toNumber();

        var halfWOuter = halfW + 2.0;
        var lx2 = bx + (halfWOuter * px).toNumber();
        var ly2 = by + (halfWOuter * py).toNumber();
        var rx2 = bx - (halfWOuter * px).toNumber();
        var ry2 = by - (halfWOuter * py).toNumber();
        var sh = 2;
        dc.setColor(cNeedleSh, cNeedleSh);
        dc.fillPolygon([
            [tx + sh, ty + sh],
            [lx2 + sh, ly2 + sh],
            [rx2 + sh, ry2 + sh]
        ]);
        dc.setColor(cNeedleEdge, cNeedleEdge);
        dc.fillPolygon([
            [tx, ty],
            [lx2, ly2],
            [rx2, ry2]
        ]);
        dc.setColor(cNeedleBody, cNeedleBody);
        dc.fillPolygon([
            [tx, ty],
            [lx, ly],
            [rx, ry]
        ]);
        dc.setColor(cHubRim, cHubRim);
        dc.fillCircle(cx, compassCy, 6);
        dc.setColor(cHubCore, cHubCore);
        dc.fillCircle(cx, compassCy, 4);
        dc.setColor(cTickMaj, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(cx, compassCy, 1);

        // Back cue near physical BACK button (lower-right).
        var backX = width - 35;
        var backY = cy + 106;
        dc.setColor(cBrassOuter, Graphics.COLOR_TRANSPARENT);
        dc.drawLine(backX + 4, backY - 5, backX - 3, backY);
        dc.drawLine(backX - 3, backY, backX + 4, backY + 5);
    }
}
