using Toybox.Application;
using Toybox.WatchUi;

class WaqtApp extends Application.AppBase {

    var prayerService = null;

    function initialize() {
        AppBase.initialize();
    }

    function onStart(state) {
        prayerService = new PrayerService();
    }

    function onStop(state) {
    }

    function getInitialView() {
        var view = new WaqtPrayerView(prayerService);
        var delegate = new WaqtPrayerDelegate(view);
        return [view, delegate];
    }
}
