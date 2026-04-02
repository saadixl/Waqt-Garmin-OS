using Toybox.Graphics;
using Toybox.System;
using Toybox.WatchUi;

class WaqtAboutView extends WatchUi.View {

    function initialize() {
        View.initialize();
    }

    function onUpdate(dc) {
        var width = dc.getWidth();
        var height = dc.getHeight();
        var cx = width / 2;
        var cy = height / 2;
        var deviceSettings = System.getDeviceSettings();
        var deviceModel = "Unknown";
        if (deviceSettings != null) {
            if ((deviceSettings has :deviceType) && (deviceSettings.deviceType != null)) {
                deviceModel = deviceSettings.deviceType.toString();
            } else if (deviceSettings.partNumber != null) {
                deviceModel = deviceSettings.partNumber.toString();
            }
        }

        dc.setColor(Constants.COLOR_BG, Constants.COLOR_BG);
        dc.clear();

        dc.setColor(Constants.COLOR_ACTIVE_BORDER, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, 34, Graphics.FONT_TINY, "About", Graphics.TEXT_JUSTIFY_CENTER);

        dc.setColor(Constants.COLOR_TEXT, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, 106, Graphics.FONT_XTINY, "Version", Graphics.TEXT_JUSTIFY_CENTER);
        dc.setColor(Constants.COLOR_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, 142, Graphics.FONT_SYSTEM_XTINY, Constants.APP_VERSION, Graphics.TEXT_JUSTIFY_CENTER);

        dc.setColor(Constants.COLOR_TEXT, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, 186, Graphics.FONT_XTINY, "Last updated", Graphics.TEXT_JUSTIFY_CENTER);
        dc.setColor(Constants.COLOR_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, 222, Graphics.FONT_SYSTEM_XTINY, Constants.LAST_UPDATED, Graphics.TEXT_JUSTIFY_CENTER);

        dc.setColor(Constants.COLOR_TEXT, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, 266, Graphics.FONT_XTINY, "Device model", Graphics.TEXT_JUSTIFY_CENTER);
        dc.setColor(Constants.COLOR_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, 302, Graphics.FONT_SYSTEM_XTINY, deviceModel, Graphics.TEXT_JUSTIFY_CENTER);

        // Back cue near physical BACK button (lower-right).
        var backX = width - 35;
        var backY = cy + 102;
        dc.setColor(Constants.COLOR_ACTIVE_BORDER, Graphics.COLOR_TRANSPARENT);
        dc.drawLine(backX + 4, backY - 5, backX - 3, backY);
        dc.drawLine(backX - 3, backY, backX + 4, backY + 5);
    }
}
