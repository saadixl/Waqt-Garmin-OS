using Toybox.Attention;
using Toybox.Graphics;
using Toybox.Math;
using Toybox.Sensor;
using Toybox.Timer;
using Toybox.WatchUi;

class WaqtQiblaView extends WatchUi.View {

    var _service;
    var _timer = null;
    var _lat = 0.0;
    var _lon = 0.0;
    var _hasFix = false;
    var _qiblaAlignLatched = false;

    function initialize(service) {
        View.initialize();
        _service = service;
    }

    function onShow() {
        _timer = new Timer.Timer();
        _timer.start(method(:onTick), 500, true);
        applyLocation();
    }

    function onHide() {
        if (_timer != null) {
            _timer.stop();
            _timer = null;
        }
        _qiblaAlignLatched = false;
    }

    //! Auto: GPS poll. Fixed city: coordinates from CityData.
    function applyLocation() {
        var cityIdx = _service.getCityIndex();
        if (CityData.isAutoDetect(cityIdx)) {
            _service.sampleGpsFromPosition();
            if (_service.hasGpsFix()) {
                _lat = _service.getAutoLat();
                _lon = _service.getAutoLon();
                _hasFix = true;
            } else {
                _hasFix = false;
            }
        } else {
            _lat = CityData.getCityLat(cityIdx).toFloat() / 10000.0;
            _lon = CityData.getCityLon(cityIdx).toFloat() / 10000.0;
            _hasFix = true;
        }
    }

    function onTick() as Void {
        applyLocation();
        WatchUi.requestUpdate();
    }

    function formatCoords(lat, lon) {
        var ns = "N";
        if (lat < 0.0) {
            ns = "S";
            lat = -lat;
        }
        var ew = "E";
        if (lon < 0.0) {
            ew = "W";
            lon = -lon;
        }
        return lat.format("%.1f") + ns + " " + lon.format("%.1f") + ew;
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

    function shortestHeadingErrorDeg(qiblaDeg, headingDeg) {
        var d = qiblaDeg - headingDeg;
        while (d > 180.0) {
            d -= 360.0;
        }
        while (d < -180.0) {
            d += 360.0;
        }
        if (d < 0.0) {
            return -d;
        }
        return d;
    }

    //! Night-sky backdrop: vertical twilight gradient, soft horizon, subtle stars.
    function drawQiblaBackground(dc, width, height, cx, cy) {
        // Rich vertical gradient: emerald night (top) → deep forest mid → warm black (bottom).
        var bands = 24;
        var bandH = (height / bands) + 2;
        for (var i = 0; i < bands; i++) {
            var f = (i * 1000) / (bands - 1);
            var rr;
            var gg;
            var bb;
            if (f < 400) {
                var t = (f * 100) / 400;
                rr = 14 + (t * 10) / 100;
                gg = 38 + (t * 22) / 100;
                bb = 28 + (t * 10) / 100;
            } else if (f < 700) {
                var t2 = ((f - 400) * 100) / 300;
                rr = 24 + (t2 * 8) / 100;
                gg = 60 - (t2 * 8) / 100;
                bb = 38 - (t2 * 12) / 100;
            } else {
                var t3 = ((f - 700) * 100) / 300;
                rr = 32 - (t3 * 24) / 100;
                gg = 52 - (t3 * 40) / 100;
                bb = 26 - (t3 * 16) / 100;
            }
            if (rr < 2) {
                rr = 2;
            }
            if (gg < 3) {
                gg = 3;
            }
            if (bb < 6) {
                bb = 6;
            }
            var c = (rr << 16) | (gg << 8) | bb;
            dc.setColor(c, c);
            dc.fillRectangle(0, i * bandH, width, bandH + 2);
        }

        // Soft vignette: slightly darken left/right edges (vertical strips).
        var vignW = (width * 8) / 100;
        if (vignW < 8) {
            vignW = 8;
        }
        dc.setColor(0x040A08, 0x040A08);
        dc.fillRectangle(0, 0, vignW, height);
        dc.fillRectangle(width - vignW, 0, vignW, height);

        // Horizon glow — thin green-teal band (distant atmosphere).
        var hzY = (height * 70) / 100;
        dc.setColor(0x1A4838, 0x1A4838);
        dc.fillRectangle(0, hzY, width, 3);
        dc.setColor(0x2A6850, 0x2A6850);
        dc.fillRectangle(0, hzY + 1, width, 2);
        dc.setColor(0x0C1810, 0x0C1810);
        dc.fillRectangle(0, hzY + 3, width, 5);

        // Soft moonlit pool behind compass: many thin rings, green-night → deep edge (no harsh bands).
        var screenR = width < height ? width / 2 : height / 2;
        var glowR = (screenR * 98) / 100;
        var gcy = cy + (screenR / 12);
        var step = 4;
        var gr = glowR;
        while (gr > 6) {
            var u = (gr * 256) / glowR;
            var ar = 6 + (u * 22) / 256;
            var ag = 18 + (u * 48) / 256;
            var ab = 12 + (u * 32) / 256;
            if (u > 180) {
                var lift = (u - 180) / 76;
                ag = ag + (lift * 12) / 100;
                ab = ab + (lift * 6) / 100;
            }
            if (ar > 32) {
                ar = 32;
            }
            if (ag > 72) {
                ag = 72;
            }
            if (ab > 58) {
                ab = 58;
            }
            var gcol = (ar << 16) | (ag << 8) | ab;
            dc.setColor(gcol, gcol);
            dc.fillCircle(cx, gcy, gr);
            gr -= step;
        }

        // Stars — percent positions [x, y] (avoid nested array indexing issues).
        var starX = [12, 88, 25, 72, 8, 92, 18, 80, 45, 55, 30, 70, 50, 65, 38, 15];
        var starY = [8, 6, 18, 14, 35, 38, 52, 48, 58, 62, 72, 78, 10, 25, 28, 44];
        var starBright = 0xC8E8D8;
        var starDim = 0x5A9078;
        for (var si = 0; si < starX.size(); si++) {
            var px = (width * starX[si]) / 100;
            var py = (height * starY[si]) / 100;
            var sc = starDim;
            if ((si % 3) == 0) {
                sc = starBright;
            }
            dc.setColor(sc, sc);
            dc.fillCircle(px, py, 1);
            if ((si % 5) == 1) {
                dc.fillCircle(px + 1, py, 1);
                dc.fillCircle(px, py + 1, 1);
            }
        }
    }

    //! Layered green-night bowl inside the brass ring (smooth gradient, soft luminous core).
    function drawCompassBowlFace(dc, cx, compassCy, ring80Inner, innerPad, hubR) {
        var rOut = ring80Inner - 2;
        var layers = 8;
        for (var li = 0; li < layers; li++) {
            var ri = rOut - (li * (rOut - hubR)) / (layers - 1);
            if (ri < hubR) {
                ri = hubR;
            }
            var col;
            if (li == 0) {
                col = 0x0E1A14;
            } else if (li == 1) {
                col = 0x122418;
            } else if (li == 2) {
                col = 0x172E20;
            } else if (li == 3) {
                col = 0x1D3828;
            } else if (li == 4) {
                col = 0x244830;
            } else if (li == 5) {
                col = 0x2C5838;
            } else if (li == 6) {
                col = 0x356840;
            } else {
                col = 0x3D7848;
            }
            dc.setColor(col, col);
            dc.fillCircle(cx, compassCy, ri);
        }
        dc.setColor(0x4A9070, Graphics.COLOR_TRANSPARENT);
        dc.drawCircle(cx, compassCy, ring80Inner - innerPad + 2);
        dc.setColor(0x2A6048, Graphics.COLOR_TRANSPARENT);
        dc.drawCircle(cx, compassCy, hubR + 4);
    }

    function onUpdate(dc) {
        var width = dc.getWidth();
        var height = dc.getHeight();
        var cx = width / 2;
        var cy = height / 2;
        var qiblaBearing = 0.0;
        var locationLabel = "Acquiring GPS...";
        var degLabel = "---\u00B0";
        var cityIdx = _service.getCityIndex();
        if (_hasFix) {
            qiblaBearing = CityData.bearingFromLatLonDegrees(_lat, _lon).toFloat();
            degLabel = qiblaBearing.toNumber() + "\u00B0";
            if (CityData.isAutoDetect(cityIdx)) {
                locationLabel = formatCoords(_lat, _lon);
            } else {
                locationLabel = CityData.getCityName(cityIdx);
            }
        } else if (!CityData.isAutoDetect(cityIdx)) {
            locationLabel = CityData.getCityName(cityIdx);
        }

        drawQiblaBackground(dc, width, height, cx, cy);

        // Compass palette — brass housing, bowl via drawCompassBowlFace, maritime ticks
        var cBrassInner = 0x5A4C38;
        var cBrassOuter = Constants.COLOR_ACTIVE_MID;
        var cRail = 0x121814;
        var cVoid = 0x080D10;
        var cTickMaj = 0xC8BCAC;
        var cTickMin = 0x5E5852;
        var cNorth = 0x8E2A3C; // maroon — north cardinal
        var cCardIvory = 0xDCD8D0;
        var cDegText = 0xA8C8B4;
        var cCityText = 0xD4A84A;
        var cNeedleSh = 0x2A6B48;
        var cNeedleBody = 0x5CB88A;
        var cNeedleEdge = 0x9DD4B0;
        var cHubRim = 0x7A6848;
        var cHubCore = 0x2A2420;
        var cKaabaWall = 0x141A16;
        var cKaabaBand = 0xC49A28;

        // Live heading in degrees (0 = north, clockwise). Used to rotate the rose + hand.
        var headingDeg = 0.0;
        var info = Sensor.getInfo();
        var headingFromSensor = false;
        if (info != null && info.heading != null) {
            headingDeg = normalizeHeadingDeg(info.heading.toFloat() * 180.0 / Math.PI);
            headingFromSensor = true;
        }

        if (headingFromSensor && _hasFix) {
            var alignErr = shortestHeadingErrorDeg(qiblaBearing, headingDeg);
            var aligned = alignErr <= 4.0;
            if (aligned && !_qiblaAlignLatched) {
                if (Attention has :vibrate) {
                    Attention.vibrate([new Attention.VibeProfile(85, 100)]);
                }
                _qiblaAlignLatched = true;
            } else if (!aligned) {
                _qiblaAlignLatched = false;
            }
        } else {
            _qiblaAlignLatched = false;
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

        // Inner compass face — layered green-night bowl
        drawCompassBowlFace(dc, cx, compassCy, ring80Inner, innerPad, hubR);

        // Inner brass ring
        dc.setColor(cBrassInner, cBrassInner);
        dc.fillCircle(cx, compassCy, ring80);
        drawCompassBowlFace(dc, cx, compassCy, ring80Inner, innerPad, hubR);

        // Outer brass ring, then restore interior
        dc.setColor(cBrassOuter, cBrassOuter);
        dc.fillCircle(cx, compassCy, ring90Outer);
        dc.setColor(cVoid, cVoid);
        dc.fillCircle(cx, compassCy, ring90Inner - 1);
        dc.setColor(cBrassInner, cBrassInner);
        dc.fillCircle(cx, compassCy, ring80);
        drawCompassBowlFace(dc, cx, compassCy, ring80Inner, innerPad, hubR);

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

        // N/E/S/W centered in the outer (first) brass ring — between void and outer edge
        var labelR = (ring90Outer + ring90Inner) / 2;
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
        dc.drawText(cx, degY, Graphics.FONT_XTINY, degLabel, textJust);
        dc.setColor(cCityText, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, cityY, Graphics.FONT_XTINY, locationLabel, textJust);

        if (!_hasFix && CityData.isAutoDetect(cityIdx)) {
            dc.setColor(Constants.COLOR_ERROR, Graphics.COLOR_TRANSPARENT);
            dc.drawText(cx, compassCy - 10, Graphics.FONT_XTINY, "Open sky for GPS", textJust);
            dc.drawText(cx, compassCy + 10, Graphics.FONT_XTINY, "Settings: Refresh GPS", textJust);
            var backX = width - 35;
            var backY = cy + 106;
            dc.setColor(cBrassOuter, Graphics.COLOR_TRANSPARENT);
            dc.drawLine(backX + 4, backY - 5, backX - 3, backY);
            dc.drawLine(backX - 3, backY, backX + 4, backY + 5);
            return;
        }

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

        // Cyan Qibla hand — compass lancet: convex blade + tail, rim/body, tipped shadow, jewel + glint.
        var deltaQ = normalizeHeadingDeg(qiblaBearing - headingDeg);
        var rad = (deltaQ - 90.0) * Math.PI / 180.0;
        var cosR = Math.cos(rad);
        var sinR = Math.sin(rad);
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
        var halfW = ring90Outer / 18.0;
        if (halfW < 7.0) {
            halfW = 7.0;
        }
        if (halfW > 13.0) {
            halfW = 13.0;
        }
        var halfWOuter = halfW + 2.0;

        var tx = cx + (tipR * cosR).toNumber();
        var ty = compassCy + (tipR * sinR).toNumber();
        var bx = cx + (baseR * cosR).toNumber();
        var by = compassCy + (baseR * sinR).toNumber();
        var px = Math.cos(rad + (Math.PI / 2.0));
        var py = Math.sin(rad + (Math.PI / 2.0));
        var lx = bx + (halfW * px).toNumber();
        var ly = by + (halfW * py).toNumber();
        var rx = bx - (halfW * px).toNumber();
        var ry = by - (halfW * py).toNumber();
        var lx2 = bx + (halfWOuter * px).toNumber();
        var ly2 = by + (halfWOuter * py).toNumber();
        var rx2 = bx - (halfWOuter * px).toNumber();
        var ry2 = by - (halfWOuter * py).toNumber();

        var tailLen = 11 + (screenR / 30);
        if (tailLen > 18) {
            tailLen = 18;
        }
        if (tailLen < 9) {
            tailLen = 9;
        }
        var tailTipR = baseR - tailLen;
        var tailMinR = hubR + 5;
        if (tailTipR < tailMinR) {
            tailTipR = tailMinR;
        }
        var ttx = cx + (tailTipR * cosR).toNumber();
        var tty = compassCy + (tailTipR * sinR).toNumber();

        var shMag = 1.5;
        var shx = (shMag * Math.cos(rad + Math.PI / 2.8)).toNumber();
        var shy = (shMag * Math.sin(rad + Math.PI / 2.8)).toNumber();

        dc.setColor(cNeedleSh, cNeedleSh);
        dc.fillPolygon([
            [tx + shx, ty + shy],
            [lx2 + shx, ly2 + shy],
            [ttx + shx, tty + shy],
            [rx2 + shx, ry2 + shy]
        ]);
        dc.setColor(cNeedleEdge, cNeedleEdge);
        dc.fillPolygon([
            [tx, ty],
            [lx2, ly2],
            [ttx, tty],
            [rx2, ry2]
        ]);
        dc.setColor(cNeedleBody, cNeedleBody);
        dc.fillPolygon([
            [tx, ty],
            [lx, ly],
            [ttx, tty],
            [rx, ry]
        ]);

        var glintD = (tipR * 64) / 100 + (baseR * 36) / 100;
        var ggx = cx + (glintD * cosR).toNumber();
        var ggy = compassCy + (glintD * sinR).toNumber();
        var gOff = 0.4;
        dc.setColor(cNeedleEdge, cNeedleEdge);
        dc.fillCircle(ggx + (gOff * px).toNumber(), ggy + (gOff * py).toNumber(), 2);

        dc.setColor(cNeedleEdge, cNeedleEdge);
        dc.fillCircle(tx, ty, 3);
        dc.setColor(cNeedleBody, cNeedleBody);
        dc.fillCircle(tx, ty, 2);
        var tSparkX = tx - cosR.toNumber();
        var tSparkY = ty - sinR.toNumber();
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_WHITE);
        dc.fillCircle(tSparkX, tSparkY, 1);

        dc.setColor(cHubRim, cHubRim);
        dc.fillCircle(cx, compassCy, 6);
        dc.setColor(cHubCore, cHubCore);
        dc.fillCircle(cx, compassCy, 4);
        dc.setColor(cNeedleBody, cNeedleBody);
        dc.fillCircle(cx, compassCy, 2);
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
