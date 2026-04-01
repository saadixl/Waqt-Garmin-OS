using Toybox.WatchUi;
using Toybox.System;

class WaqtPrayerDelegate extends WatchUi.BehaviorDelegate {

    var _view;

    function initialize(view) {
        BehaviorDelegate.initialize();
        _view = view;
    }

    function onNextPage() {
        _view.scrollDown();
        return true;
    }

    function onPreviousPage() {
        _view.scrollUp();
        return true;
    }

    function onSelect() {
        var settingsView = new WaqtSettingsView();
        var settingsDelegate = new WaqtSettingsDelegate(settingsView, _view);
        WatchUi.pushView(settingsView, settingsDelegate, WatchUi.SLIDE_UP);
        return true;
    }

    function onBack() {
        System.exit();
        return true;
    }
}
