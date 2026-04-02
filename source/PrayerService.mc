using Toybox.Communications;
using Toybox.System;
using Toybox.Time;
using Toybox.Time.Gregorian;
using Toybox.Application.Storage;
using Toybox.Position;

class PrayerService {

    var _callback = null;
    var _cityIndex = 0;

    var _prayerTimes24h = null;
    var _prayerTimesFormatted = null;
    var _cityTimezoneOffset = 0;
    var _lastFetchError = null;

    var _autoLat = 0.0;
    var _autoLon = 0.0;
    var _autoElevMeters = 0.0;
    var _gpsHasFix = false;

    function initialize() {
        //! cityListV3: Auto at 0; cities 1..50 east→west. Remaps v2 (Auto=50) and v1 (Auto=20).
        var saved = Storage.getValue("cityIndex");
        var v3 = Storage.getValue("cityListV3");
        if (v3 == null) {
            var v2 = Storage.getValue("cityListV2");
            _cityIndex = CityData.migrateLegacyCityIndex(saved, v2);
            Storage.setValue("cityListV3", 1);
            Storage.setValue("cityIndex", _cityIndex);
        } else if (saved != null && saved >= 0 && saved < CityData.LOCATION_COUNT) {
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

    function getLastFetchError() {
        return _lastFetchError;
    }

    function hasGpsFix() {
        return _gpsHasFix;
    }

    function getAutoLat() {
        return _autoLat;
    }

    function getAutoLon() {
        return _autoLon;
    }

    //! Refresh GPS sample (call before fetch or Qibla when using auto location).
    function sampleGpsFromPosition() {
        _gpsHasFix = false;
        var info = Position.getInfo();
        if (info != null && info has :position && info.position != null) {
            var deg = info.position.toDegrees();
            if (deg != null && deg.size() >= 2) {
                _autoLat = deg[0].toFloat();
                _autoLon = deg[1].toFloat();
                _gpsHasFix = true;
                if (info has :altitude && info.altitude != null) {
                    _autoElevMeters = info.altitude.toFloat();
                } else {
                    _autoElevMeters = 0.0;
                }
            }
        }
    }

    //! Short coordinate line for prayer header when auto detect is on.
    function formatCoordsShort(lat, lon) {
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

    function getPrayerHeaderLocationLabel() {
        if (CityData.isAutoDetect(_cityIndex)) {
            if (_gpsHasFix) {
                return formatCoordsShort(_autoLat, _autoLon);
            }
            return "Acquiring GPS...";
        }
        return CityData.getCityName(_cityIndex);
    }

    //! Qibla degrees for city list row when highlighting Auto detect (needs GPS).
    function getAutoMenuQiblaDegrees() {
        if (!_gpsHasFix) {
            return null;
        }
        return CityData.bearingFromLatLonDegrees(_autoLat, _autoLon);
    }

    function fetchPrayerTimes(callback) {
        _callback = callback;
        _lastFetchError = null;

        var lat;
        var lon;

        if (CityData.isAutoDetect(_cityIndex)) {
            sampleGpsFromPosition();
            if (!_gpsHasFix) {
                _lastFetchError = "Need GPS fix";
                if (_callback != null) {
                    _callback.invoke(false);
                }
                return;
            }
            lat = _autoLat;
            lon = _autoLon;
            var watchOffsetSec = System.getClockTime().timeZoneOffset;
            _cityTimezoneOffset = (watchOffsetSec * 10) / 3600;
        } else {
            _cityTimezoneOffset = CityData.getCityUtcOffset(_cityIndex);
            lat = CityData.getCityLat(_cityIndex).toFloat() / 10000.0;
            lon = CityData.getCityLon(_cityIndex).toFloat() / 10000.0;
        }

        var now = Time.now();
        var timestamp = now.value();

        var url = "https://api.aladhan.com/v1/timings/" + timestamp + "?latitude=" + lat + "&longitude=" + lon;
        if (CityData.isAutoDetect(_cityIndex) && _autoElevMeters != 0.0) {
            var el = _autoElevMeters.toNumber();
            if (el < 0) {
                el = -el;
            }
            url = url + "&elevation=" + el;
        }

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
            _lastFetchError = "Failed to load";
            if (_callback != null) {
                _callback.invoke(false);
            }
        }
    }

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

    function formatCountdown(seconds) {
        var h = seconds / 3600;
        var m = (seconds % 3600) / 60;
        var s = seconds % 60;

        return h.format("%02d") + ":" + m.format("%02d") + ":" + s.format("%02d");
    }

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
