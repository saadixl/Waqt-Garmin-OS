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

        // Get live heading when available (radians from true north).
        var headingDeg = null;
        var info = Sensor.getInfo();
        if (info != null && info.heading != null) {
            headingDeg = (info.heading.toFloat() * 180.0 / Math.PI);
            while (headingDeg < 0.0) { headingDeg += 360.0; }
            while (headingDeg >= 360.0) { headingDeg -= 360.0; }
        }

        // Compass body
        var compassCy = cy;
        var ringR = 180;
        var innerR = 176;
        // Soft layered background inside compass.
        dc.setColor(0x070707, 0x070707);
        dc.fillCircle(cx, compassCy, innerR - 2);
        dc.setColor(0x0C0C0C, 0x0C0C0C);
        dc.fillCircle(cx, compassCy, innerR - 20);
        dc.setColor(0x121212, 0x121212);
        dc.fillCircle(cx, compassCy, 24);
        var ringColor = 0xCFCFCF;
        dc.setColor(ringColor, Graphics.COLOR_TRANSPARENT);
        // Wider ring thickness using concentric circles.
        for (var rr = innerR; rr <= ringR; rr++) {
            dc.drawCircle(cx, compassCy, rr);
        }

        // Tick marks around compass
        for (var d = 0; d < 360; d += 15) {
            var a = (d - 90.0) * Math.PI / 180.0;
            var outer = ringR;
            var tickLen = 4;
            if ((d % 45) == 0) {
                tickLen = 8;
            }
            var ix = cx + ((outer - tickLen) * Math.cos(a)).toNumber();
            var iy = compassCy + ((outer - tickLen) * Math.sin(a)).toNumber();
            var ox = cx + (outer * Math.cos(a)).toNumber();
            var oy = compassCy + (outer * Math.sin(a)).toNumber();
            dc.drawLine(ix, iy, ox, oy);
        }

        // Cardinal directions
        dc.setColor(Constants.COLOR_ACTIVE_BORDER, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, compassCy - ringR - 46, Graphics.FONT_TINY, "N", Graphics.TEXT_JUSTIFY_CENTER);
        dc.setColor(Constants.COLOR_TEXT, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx + ringR + 22, compassCy - 6, Graphics.FONT_XTINY, "E", Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(cx, compassCy + ringR + 4, Graphics.FONT_XTINY, "S", Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(cx - ringR - 22, compassCy - 6, Graphics.FONT_XTINY, "W", Graphics.TEXT_JUSTIFY_CENTER);

        // Center labels inside compass.
        dc.setColor(Constants.COLOR_ACTIVE_BORDER, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, compassCy - 84, Graphics.FONT_XTINY, cityName, Graphics.TEXT_JUSTIFY_CENTER);
        dc.setColor(Constants.COLOR_TEXT, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, compassCy + 54, Graphics.FONT_XTINY, qiblaBearing.toNumber() + "\u00B0", Graphics.TEXT_JUSTIFY_CENTER);

        // Hand tracks watch heading over a fixed north-up ring.
        var pointerDeg = 0.0;
        if (headingDeg != null) {
            pointerDeg = headingDeg;
        }

        var rad = (pointerDeg - 90.0) * Math.PI / 180.0;
        var tipR = ringR - 22;
        var baseR = 28;
        var halfW = 9.0;
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

        // Pointer border then fill for better contrast.
        var halfWOuter = halfW + 2.0;
        var lx2 = bx + (halfWOuter * px).toNumber();
        var ly2 = by + (halfWOuter * py).toNumber();
        var rx2 = bx - (halfWOuter * px).toNumber();
        var ry2 = by - (halfWOuter * py).toNumber();
        dc.setColor(Constants.COLOR_ACTIVE_BORDER, Constants.COLOR_ACTIVE_BORDER);
        dc.fillPolygon([
            [tx, ty],
            [lx2, ly2],
            [rx2, ry2]
        ]);

        dc.setColor(Constants.COLOR_ACTIVE, Constants.COLOR_ACTIVE);
        dc.fillPolygon([
            [tx, ty],
            [lx, ly],
            [rx, ry]
        ]);
        dc.setColor(Constants.COLOR_ACTIVE_BORDER, Constants.COLOR_ACTIVE_BORDER);
        dc.fillCircle(cx, compassCy, 5);
        dc.setColor(Constants.COLOR_BG, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(cx, compassCy, 2);

        // Kaaba icon fixed at absolute Qibla bearing on the ring.
        var kaabaR = ringR - 10;
        var kaabaRad = (qiblaBearing - 90.0) * Math.PI / 180.0;
        var kx = cx + (kaabaR * Math.cos(kaabaRad)).toNumber();
        var ky = compassCy + (kaabaR * Math.sin(kaabaRad)).toNumber();
        var kw = 24;
        var kh = 24;
        dc.setColor(0x1E1E1E, 0x1E1E1E);
        dc.fillRectangle(kx - (kw / 2), ky - (kh / 2), kw, kh);
        dc.setColor(0xD7AF2A, 0xD7AF2A);
        dc.fillRectangle(kx - (kw / 2), ky - (kh / 2) + 4, kw, 3);
        dc.setColor(Constants.COLOR_TEXT, Graphics.COLOR_TRANSPARENT);
        dc.drawRectangle(kx - (kw / 2), ky - (kh / 2), kw, kh);

        // Back cue near physical BACK button (lower-right).
        var backX = width - 35;
        var backY = cy + 106;
        dc.setColor(Constants.COLOR_ACTIVE_BORDER, Graphics.COLOR_TRANSPARENT);
        dc.drawLine(backX + 4, backY - 5, backX - 3, backY);
        dc.drawLine(backX - 3, backY, backX + 4, backY + 5);
    }
}
