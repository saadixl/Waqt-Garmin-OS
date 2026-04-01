using Toybox.Graphics;
using Toybox.WatchUi;

class WaqtQiblaPlaceholderView extends WatchUi.View {

    function initialize() {
        View.initialize();
    }

    function onUpdate(dc) {
        var width = dc.getWidth();
        var height = dc.getHeight();
        var cx = width / 2;
        var cy = height / 2;

        dc.setColor(Constants.COLOR_BG, Constants.COLOR_BG);
        dc.clear();

        dc.setColor(Constants.COLOR_ACTIVE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, cy - 42, Graphics.FONT_TINY, "Find Qibla", Graphics.TEXT_JUSTIFY_CENTER);

        dc.setColor(Constants.COLOR_TEXT, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, cy - 2, Graphics.FONT_XTINY, "Placeholder page", Graphics.TEXT_JUSTIFY_CENTER);

        dc.setColor(Constants.COLOR_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, cy + 24, Graphics.FONT_XTINY, "Coming soon", Graphics.TEXT_JUSTIFY_CENTER);

        // Back cue near physical BACK button (lower-right).
        var backX = width - 35;
        var backY = cy + 102;
        dc.setColor(Constants.COLOR_ACTIVE_BORDER, Graphics.COLOR_TRANSPARENT);
        dc.drawLine(backX + 4, backY - 5, backX - 3, backY);
        dc.drawLine(backX - 3, backY, backX + 4, backY + 5);
    }
}
