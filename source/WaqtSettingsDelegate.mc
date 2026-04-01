using Toybox.WatchUi;

class WaqtSettingsDelegate extends WatchUi.BehaviorDelegate {

    var _settingsView;
    var _prayerView;

    function initialize(settingsView, prayerView) {
        BehaviorDelegate.initialize();
        _settingsView = settingsView;
        _prayerView = prayerView;
    }

    function onNextPage() {
        _settingsView.scrollDown();
        return true;
    }

    function onPreviousPage() {
        _settingsView.scrollUp();
        return true;
    }

    function onSelect() {
        var idx = _settingsView.getSelectedIndex();

        if (idx == 0) {
            // Push city list so back returns to settings.
            var cityView = new WaqtCityView(_prayerView._service);
            var cityDelegate = new WaqtCityDelegate(cityView, _prayerView);
            WatchUi.pushView(cityView, cityDelegate, WatchUi.SLIDE_LEFT);
        } else if (idx == 1) {
            // Placeholder page for future Qibla compass workflow.
            var qiblaView = new WaqtQiblaPlaceholderView();
            var qiblaDelegate = new WaqtQiblaPlaceholderDelegate();
            WatchUi.pushView(qiblaView, qiblaDelegate, WatchUi.SLIDE_LEFT);
        } else {
            var aboutView = new WaqtAboutView();
            var aboutDelegate = new WaqtAboutDelegate();
            WatchUi.pushView(aboutView, aboutDelegate, WatchUi.SLIDE_LEFT);
        }

        return true;
    }

    function onBack() {
        WatchUi.popView(WatchUi.SLIDE_DOWN);
        return true;
    }
}
