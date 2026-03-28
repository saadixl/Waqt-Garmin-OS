using Toybox.WatchUi;

class WaqtCityDelegate extends WatchUi.BehaviorDelegate {

    var _cityView;
    var _prayerView;

    function initialize(cityView, prayerView) {
        BehaviorDelegate.initialize();
        _cityView = cityView;
        _prayerView = prayerView;
    }

    function onNextPage() {
        _cityView.scrollDown();
        return true;
    }

    function onPreviousPage() {
        _cityView.scrollUp();
        return true;
    }

    function onSelect() {
        var selectedIdx = _cityView.getSelectedIndex();
        _prayerView._service.setCityIndex(selectedIdx);
        _prayerView.refreshData();
        WatchUi.popView(WatchUi.SLIDE_DOWN);
        return true;
    }

    function onBack() {
        WatchUi.popView(WatchUi.SLIDE_DOWN);
        return true;
    }
}
