using Toybox.Communications;
using Toybox.System;
using Toybox.Time;
using Toybox.Time.Gregorian;
using Toybox.Application.Storage;

class PrayerService {

    var _callback = null;
    var _cityIndex = 0;

    // Cached prayer times as array of strings in 24h format ["HH:MM", ...]
    var _prayerTimes24h = null;
    // Cached prayer times formatted for display ["h:mm AM/PM", ...]
    var _prayerTimesFormatted = null;
    // City timezone offset * 10
    var _cityTimezoneOffset = 0;

    function initialize() {
        var saved = Storage.getValue("cityIndex");
        if (saved != null) {
            _cityIndex = saved;
        }
    }

    function getCityIndex() {
        return _cityIndex;
    }

    function setCityIndex(index) {
        _cityIndex = index;
        Storage.setValue("cityIndex", index);
    }

    function fetchPrayerTimes(callback) {
        _callback = callback;
        _cityTimezoneOffset = CityData.getCityUtcOffset(_cityIndex);

        var lat = CityData.getCityLat(_cityIndex).toFloat() / 10000.0;
        var lon = CityData.getCityLon(_cityIndex).toFloat() / 10000.0;

        var now = Time.now();
        var timestamp = now.value();

        var url = "https://api.aladhan.com/v1/timings/" + timestamp + "?latitude=" + lat + "&longitude=" + lon;

        Communications.makeWebRequest(
            url,
            null,
            {
                :method => Communications.HTTP_REQUEST_METHOD_GET,
                :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON
            },
            method(:onReceive)
        );
    }

    function onReceive(responseCode as Toybox.Lang.Number, data as Toybox.Lang.Dictionary or Toybox.Lang.String or Null) as Void {
        if (responseCode == 200 && data != null) {
            var apiData = data["data"];
            var timings = apiData["timings"];

            _prayerTimes24h = [
                timings["Fajr"],
                timings["Sunrise"],
                timings["Dhuhr"],
                timings["Asr"],
                timings["Maghrib"],
                timings["Isha"]
            ];

            _prayerTimesFormatted = new [6];
            for (var i = 0; i < 6; i++) {
                _prayerTimesFormatted[i] = formatTo12h(_prayerTimes24h[i]);
            }

            if (_callback != null) {
                _callback.invoke(true);
            }
        } else {
            if (_callback != null) {
                _callback.invoke(false);
            }
        }
    }

    // Convert "HH:MM" or "HH:MM (TZ)" to "h:mm AM/PM"
    function formatTo12h(time24) {
        var spaceIdx = time24.find(" ");
        var timeStr = time24;
        if (spaceIdx != null) {
            timeStr = time24.substring(0, spaceIdx);
        }

        var colonIdx = timeStr.find(":");
        var hourStr = timeStr.substring(0, colonIdx);
        var minStr = timeStr.substring(colonIdx + 1, colonIdx + 3);

        var hour = hourStr.toNumber();
        var suffix = "AM";

        if (hour == 0) {
            hour = 12;
        } else if (hour == 12) {
            suffix = "PM";
        } else if (hour > 12) {
            hour = hour - 12;
            suffix = "PM";
        }

        return hour.toString() + ":" + minStr + " " + suffix;
    }

    // Get the index of the next upcoming prayer (0-5)
    function getNextPrayerIndex() {
        if (_prayerTimes24h == null) {
            return 0;
        }

        var now = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
        var watchOffsetSec = System.getClockTime().timeZoneOffset;
        var watchOffsetHours10 = (watchOffsetSec * 10) / 3600;
        var cityOffset10 = _cityTimezoneOffset;
        var diffHours10 = cityOffset10 - watchOffsetHours10;

        var currentMinutes = now.hour * 60 + now.min;
        currentMinutes = currentMinutes + (diffHours10 * 6);

        if (currentMinutes < 0) {
            currentMinutes += 1440;
        } else if (currentMinutes >= 1440) {
            currentMinutes -= 1440;
        }

        for (var i = 0; i < 6; i++) {
            var prayerMinutes = parseTimeToMinutes(_prayerTimes24h[i]);
            if (prayerMinutes > currentMinutes) {
                return i;
            }
        }

        return 0;
    }

    // Parse "HH:MM" or "HH:MM (TZ)" to minutes since midnight
    function parseTimeToMinutes(time24) {
        var spaceIdx = time24.find(" ");
        var timeStr = time24;
        if (spaceIdx != null) {
            timeStr = time24.substring(0, spaceIdx);
        }

        var colonIdx = timeStr.find(":");
        var hour = timeStr.substring(0, colonIdx).toNumber();
        var min = timeStr.substring(colonIdx + 1, colonIdx + 3).toNumber();

        return hour * 60 + min;
    }

    // Calculate seconds remaining until a prayer
    function getSecondsUntilPrayer(prayerIndex) {
        if (_prayerTimes24h == null) {
            return 0;
        }

        var now = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
        var watchOffsetSec = System.getClockTime().timeZoneOffset;
        var watchOffsetHours10 = (watchOffsetSec * 10) / 3600;
        var cityOffset10 = _cityTimezoneOffset;
        var diffHours10 = cityOffset10 - watchOffsetHours10;

        var currentSeconds = now.hour * 3600 + now.min * 60 + now.sec;
        currentSeconds = currentSeconds + (diffHours10 * 360);

        if (currentSeconds < 0) {
            currentSeconds += 86400;
        } else if (currentSeconds >= 86400) {
            currentSeconds -= 86400;
        }

        var prayerMinutes = parseTimeToMinutes(_prayerTimes24h[prayerIndex]);
        var prayerSeconds = prayerMinutes * 60;

        var diff = prayerSeconds - currentSeconds;
        if (diff < 0) {
            diff += 86400;
        }

        return diff;
    }

    // Format seconds as "hh:mm:ss" countdown
    function formatCountdown(seconds) {
        var h = seconds / 3600;
        var m = (seconds % 3600) / 60;
        var s = seconds % 60;

        return h.format("%02d") + ":" + m.format("%02d") + ":" + s.format("%02d");
    }

    // Format seconds as "Xh Ym" short format
    function formatShortTime(seconds) {
        var h = seconds / 3600;
        var m = (seconds % 3600) / 60;

        if (h > 0) {
            return h.toString() + "h " + m.toString() + "m";
        }
        return m.toString() + "m";
    }

    function getFormattedTime(index) {
        if (_prayerTimesFormatted != null) {
            return _prayerTimesFormatted[index];
        }
        return "--:--";
    }
}
