using Toybox.Math;

module CityData {

    // Mecca coordinates (scaled by 10000)
    const MECCA_LAT = 214225;  // 21.4225
    const MECCA_LON = 398262;  // 39.8262

    const CITY_COUNT = 50;
    //! First list row — GPS (same lat/lon as prayer times when active).
    const AUTO_DETECT_INDEX = 0;
    //! Auto (0) + 50 cities (1..50), east → west by longitude.
    const LOCATION_COUNT = 51;

    //! Maps pre–v3 storage index (0..49, v2 city order) → new location slot 1..50.
    const LEGACY_V2_TO_SLOT = [
        6, 2, 4, 7, 5, 8, 9, 12, 13, 15, 16, 22, 20, 28, 36, 38, 43, 42, 47, 49,
        27, 10, 34, 41, 18, 14, 17, 24, 25, 19, 21, 39, 30, 33, 40, 31, 37, 45, 48, 44,
        46, 50, 3, 1, 29, 23, 26, 32, 35, 11
    ];

    const CITY_NAMES = [
        "Brisbane",
        "Sydney",
        "Melbourne",
        "Tokyo",
        "Jakarta",
        "Singapore",
        "Kuala Lumpur",
        "Dhaka",
        "New Delhi",
        "Mumbai",
        "Tashkent",
        "Karachi",
        "Dubai",
        "Abu Dhabi",
        "Tehran",
        "Doha",
        "Kuwait City",
        "Riyadh",
        "Baghdad",
        "Makkah",
        "Medina",
        "Moscow",
        "Nairobi",
        "Amman",
        "Beirut",
        "Khartoum",
        "Cairo",
        "Istanbul",
        "Cape Town",
        "Berlin",
        "Rome",
        "Tunis",
        "Amsterdam",
        "Lagos",
        "Algiers",
        "Paris",
        "Barcelona",
        "London",
        "Birmingham",
        "Madrid",
        "Casablanca",
        "New York",
        "Toronto",
        "Miami",
        "Chicago",
        "Houston",
        "Austin",
        "Los Angeles",
        "San Francisco",
        "Vancouver"
    ];

    const CITY_COUNTRIES = [
        "Australia",
        "Australia",
        "Australia",
        "Japan",
        "Indonesia",
        "Singapore",
        "Malaysia",
        "Bangladesh",
        "India",
        "India",
        "Uzbekistan",
        "Pakistan",
        "UAE",
        "UAE",
        "Iran",
        "Qatar",
        "Kuwait",
        "Saudi Arabia",
        "Iraq",
        "Saudi Arabia",
        "Saudi Arabia",
        "Russia",
        "Kenya",
        "Jordan",
        "Lebanon",
        "Sudan",
        "Egypt",
        "Turkey",
        "South Africa",
        "Germany",
        "Italy",
        "Tunisia",
        "Netherlands",
        "Nigeria",
        "Algeria",
        "France",
        "Spain",
        "UK",
        "UK",
        "Spain",
        "Morocco",
        "USA",
        "Canada",
        "USA",
        "USA",
        "USA",
        "USA",
        "USA",
        "USA",
        "Canada"
    ];

    const CITY_UTC_OFFSETS = [
        100,  // Brisbane +10
        110,  // Sydney +11
        110,  // Melbourne +11
        90,   // Tokyo +9
        70,   // Jakarta +7
        80,   // Singapore +8
        80,   // Kuala Lumpur +8
        60,   // Dhaka +6
        55,   // New Delhi +5.5
        55,   // Mumbai +5.5
        50,   // Tashkent +5
        50,   // Karachi +5
        40,   // Dubai +4
        40,   // Abu Dhabi +4
        35,   // Tehran +3.5
        30,   // Doha +3
        30,   // Kuwait City +3
        30,   // Riyadh +3
        30,   // Baghdad +3
        30,   // Makkah +3
        30,   // Medina +3
        30,   // Moscow +3
        30,   // Nairobi +3
        30,   // Amman +3
        20,   // Beirut +2
        20,   // Khartoum +2
        20,   // Cairo +2
        30,   // Istanbul +3
        20,   // Cape Town +2
        10,   // Berlin +1
        10,   // Rome +1
        10,   // Tunis +1
        10,   // Amsterdam +1
        10,   // Lagos +1
        10,   // Algiers +1
        10,   // Paris +1
        10,   // Barcelona +1
        0,    // London +0
        0,    // Birmingham +0
        10,   // Madrid +1
        10,   // Casablanca +1
        -50,  // New York -5
        -50,  // Toronto -5
        -50,  // Miami -5
        -60,  // Chicago -6
        -60,  // Houston -6
        -60,  // Austin -6
        -80,  // Los Angeles -8
        -80,  // San Francisco -8
        -80   // Vancouver -8
    ];

    const CITY_LATS = [
        -274698, // Brisbane
        -338688, // Sydney
        -378136, // Melbourne
        356764,  // Tokyo
        -62088,  // Jakarta
        13523,   // Singapore
        31390,   // Kuala Lumpur
        237610,  // Dhaka
        286139,  // New Delhi
        190760,  // Mumbai
        412995,  // Tashkent
        250718,  // Karachi
        251276,  // Dubai
        244539,  // Abu Dhabi
        356892,  // Tehran
        252854,  // Doha
        293759,  // Kuwait City
        247136,  // Riyadh
        333152,  // Baghdad
        214225,  // Makkah
        245247,  // Medina
        557558,  // Moscow
        -12921,  // Nairobi
        319454,  // Amman
        338938,  // Beirut
        155007,  // Khartoum
        300444,  // Cairo
        410082,  // Istanbul
        -339249, // Cape Town
        525200,  // Berlin
        419028,  // Rome
        368065,  // Tunis
        523676,  // Amsterdam
        65244,   // Lagos
        367538,  // Algiers
        488566,  // Paris
        413851,  // Barcelona
        515074,  // London
        524862,  // Birmingham
        404168,  // Madrid
        335731,  // Casablanca
        407128,  // New York
        436532,  // Toronto
        257617,  // Miami
        418781,  // Chicago
        297604,  // Houston
        302672,  // Austin
        340522,  // Los Angeles
        377749,  // San Francisco
        492827   // Vancouver
    ];

    const CITY_LONS = [
        1530251,  // Brisbane
        1512093,  // Sydney
        1449631,  // Melbourne
        1397700,  // Tokyo
        1068650,  // Jakarta
        1038520,  // Singapore
        1016938,  // Kuala Lumpur
        904125,   // Dhaka
        772209,   // New Delhi
        728777,   // Mumbai
        692401,   // Tashkent
        670689,   // Karachi
        551949,   // Dubai
        543773,   // Abu Dhabi
        512389,   // Tehran
        511838,   // Doha
        479774,   // Kuwait City
        466753,   // Riyadh
        443661,   // Baghdad
        398262,   // Makkah
        395692,   // Medina
        376173,   // Moscow
        368219,   // Nairobi
        359284,   // Amman
        355018,   // Beirut
        325599,   // Khartoum
        312357,   // Cairo
        289784,   // Istanbul
        184241,   // Cape Town
        134050,   // Berlin
        124964,   // Rome
        101815,   // Tunis
        49041,    // Amsterdam
        33792,    // Lagos
        30588,    // Algiers
        23522,    // Paris
        21734,    // Barcelona
        -1278,    // London
        -18904,   // Birmingham
        -37038,   // Madrid
        -75898,   // Casablanca
        -740060,  // New York
        -793898,  // Toronto
        -801918,  // Miami
        -876298,  // Chicago
        -953698,  // Houston
        -977505,  // Austin
        -1182437, // Los Angeles
        -1224194, // San Francisco
        -1231207  // Vancouver
    ];

    //! Remap stored `cityIndex` from apps before Auto-first + E/W sort (see LEGACY_V2_TO_SLOT).
    function migrateLegacyCityIndex(saved, v2Flag) {
        if (saved == null) {
            return LEGACY_V2_TO_SLOT[0];
        }
        if (v2Flag != null && v2Flag == 1) {
            if (saved == 50) {
                return AUTO_DETECT_INDEX;
            }
            if (saved >= 0 && saved < CITY_COUNT) {
                return LEGACY_V2_TO_SLOT[saved];
            }
            return LEGACY_V2_TO_SLOT[0];
        }
        if (saved == 20) {
            return AUTO_DETECT_INDEX;
        }
        if (saved >= 0 && saved < 20) {
            return LEGACY_V2_TO_SLOT[saved];
        }
        return LEGACY_V2_TO_SLOT[0];
    }

    function isAutoDetect(index) {
        return index == AUTO_DETECT_INDEX;
    }

    function getCityName(index) {
        if (index == AUTO_DETECT_INDEX) {
            return "Auto detect";
        }
        return CITY_NAMES[index - 1];
    }

    function getCityCountry(index) {
        if (index == AUTO_DETECT_INDEX) {
            return "GPS";
        }
        return CITY_COUNTRIES[index - 1];
    }

    function getCityUtcOffset(index) {
        if (index == AUTO_DETECT_INDEX) {
            return 0;
        }
        return CITY_UTC_OFFSETS[index - 1];
    }

    function getCityLat(index) {
        if (index == AUTO_DETECT_INDEX) {
            return 0;
        }
        return CITY_LATS[index - 1];
    }

    function getCityLon(index) {
        if (index == AUTO_DETECT_INDEX) {
            return 0;
        }
        return CITY_LONS[index - 1];
    }

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
        var ai = cityIndex - 1;
        return bearingFromLatLonDegrees(
            CITY_LATS[ai].toFloat() / 10000.0,
            CITY_LONS[ai].toFloat() / 10000.0
        );
    }
}
