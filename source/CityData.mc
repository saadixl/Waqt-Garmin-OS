using Toybox.Math;

module CityData {

    // Mecca coordinates (scaled by 10000)
    const MECCA_LAT = 214225;  // 21.4225
    const MECCA_LON = 398262;  // 39.8262

    const CITY_COUNT = 20;
    //! Extra menu row after all cities — uses GPS + same lat/lon as prayer times.
    const AUTO_DETECT_INDEX = 20;
    const LOCATION_COUNT = 21;

    const CITY_NAMES = [
        "Singapore",
        "Sydney",
        "Tokyo",
        "Kuala Lumpur",
        "Jakarta",
        "Dhaka",
        "New Delhi",
        "Karachi",
        "Dubai",
        "Tehran",
        "Doha",
        "Moscow",
        "Makkah",
        "Istanbul",
        "Paris",
        "London",
        "Toronto",
        "New York",
        "Austin",
        "San Francisco"
    ];

    const CITY_COUNTRIES = [
        "Singapore",
        "Australia",
        "Japan",
        "Malaysia",
        "Indonesia",
        "Bangladesh",
        "India",
        "Pakistan",
        "UAE",
        "Iran",
        "Qatar",
        "Russia",
        "Saudi Arabia",
        "Turkey",
        "France",
        "UK",
        "Canada",
        "USA",
        "USA",
        "USA"
    ];

    // UTC offsets * 10 (to handle half-hour offsets as integers)
    const CITY_UTC_OFFSETS = [
        80,   // Singapore +8
        110,  // Sydney +11
        90,   // Tokyo +9
        80,   // Kuala Lumpur +8
        70,   // Jakarta +7
        60,   // Dhaka +6
        55,   // New Delhi +5.5
        50,   // Karachi +5
        40,   // Dubai +4
        35,   // Tehran +3.5
        30,   // Doha +3
        30,   // Moscow +3
        30,   // Makkah +3
        30,   // Istanbul +3
        10,   // Paris +1
        0,    // London +0
        -50,  // Toronto -5
        -50,  // New York -5
        -60,  // Austin -6
        -80   // San Francisco -8
    ];

    // Latitude * 10000
    const CITY_LATS = [
        13523,   // Singapore 1.3523
        -338688, // Sydney -33.8688
        356764,  // Tokyo 35.6764
        31390,   // Kuala Lumpur 3.1390
        -62088,  // Jakarta -6.2088
        237610,  // Dhaka 23.7610
        286139,  // New Delhi 28.6139
        250718,  // Karachi 25.0718
        251276,  // Dubai 25.1276
        356892,  // Tehran 35.6892
        252854,  // Doha 25.2854
        557558,  // Moscow 55.7558
        214225,  // Makkah 21.4225
        410082,  // Istanbul 41.0082
        488566,  // Paris 48.8566
        515074,  // London 51.5074
        436532,  // Toronto 43.6532
        407128,  // New York 40.7128
        302672,  // Austin 30.2672
        377749   // San Francisco 37.7749
    ];

    // Longitude * 10000
    const CITY_LONS = [
        1038520,  // Singapore 103.8520
        1512093,  // Sydney 151.2093
        1397700,  // Tokyo 139.7700
        1016938,  // Kuala Lumpur 101.6938
        1068650,  // Jakarta 106.8650
        904125,   // Dhaka 90.4125
        772209,   // New Delhi 77.2209
        670689,   // Karachi 67.0689
        551949,   // Dubai 55.1949
        512389,   // Tehran 51.2389
        511838,   // Doha 51.1838
        376173,   // Moscow 37.6173
        398262,   // Makkah 39.8262
        289784,   // Istanbul 28.9784
        23522,    // Paris 2.3522
        -1278,    // London -0.1278
        -793898,  // Toronto -79.3898
        -740060,  // New York -74.0060
        -977505,  // Austin -97.7505
        -1224194  // San Francisco -122.4194
    ];

    function isAutoDetect(index) {
        return index == AUTO_DETECT_INDEX;
    }

    function getCityName(index) {
        if (index == AUTO_DETECT_INDEX) {
            return "Auto detect";
        }
        return CITY_NAMES[index];
    }

    function getCityCountry(index) {
        if (index == AUTO_DETECT_INDEX) {
            return "GPS";
        }
        return CITY_COUNTRIES[index];
    }

    function getCityUtcOffset(index) {
        if (index == AUTO_DETECT_INDEX) {
            return 0;
        }
        return CITY_UTC_OFFSETS[index];
    }

    function getCityLat(index) {
        return CITY_LATS[index];
    }

    function getCityLon(index) {
        return CITY_LONS[index];
    }

    //! Great-circle bearing to Kaaba from WGS84 degrees (same math as calculateQibla).
    function bearingFromLatLonDegrees(lat, lon) {
        var lat1 = lat * Math.PI / 180.0;
        var lon1 = lon * Math.PI / 180.0;
        var lat2 = MECCA_LAT.toFloat() / 10000.0 * Math.PI / 180.0;
        var lon2 = MECCA_LON.toFloat() / 10000.0 * Math.PI / 180.0;

        var dLon = lon2 - lon1;

        var y = Math.sin(dLon) * Math.cos(lat2);
        var x = Math.cos(lat1) * Math.sin(lat2) - Math.sin(lat1) * Math.cos(lat2) * Math.cos(dLon);

        var bearing = Math.atan2(y, x) * 180.0 / Math.PI;
        bearing = ((bearing + 360.0).toNumber()) % 360;

        return bearing.toNumber();
    }

    function calculateQibla(cityIndex) {
        if (cityIndex == AUTO_DETECT_INDEX) {
            return 0;
        }
        var lat1 = CITY_LATS[cityIndex].toFloat() / 10000.0;
        var lon1 = CITY_LONS[cityIndex].toFloat() / 10000.0;
        var lat2 = MECCA_LAT.toFloat() / 10000.0;
        var lon2 = MECCA_LON.toFloat() / 10000.0;

        var dLon = (lon2 - lon1) * Math.PI / 180.0;
        lat1 = lat1 * Math.PI / 180.0;
        lat2 = lat2 * Math.PI / 180.0;

        var y = Math.sin(dLon) * Math.cos(lat2);
        var x = Math.cos(lat1) * Math.sin(lat2) - Math.sin(lat1) * Math.cos(lat2) * Math.cos(dLon);

        var bearing = Math.atan2(y, x) * 180.0 / Math.PI;
        bearing = ((bearing + 360.0).toNumber()) % 360;

        return bearing.toNumber();
    }
}
