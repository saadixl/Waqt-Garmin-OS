# Waqt - Garmin OS

A prayer times watch app for Garmin devices, built with Connect IQ (Monkey C). The UI uses a **brass and green** theme aligned with the Qibla compass: warm brass bezels and accents, soft **green** for “next” prayer cues and the live needle on the prayer screen, and ivory/white typography on deep black. **Auto location detection (GPS)** is available alongside **50 named cities** (listed east to west) for prayer times and Qibla.


## Features

### Prayer times view
- Main screen: a **scrollable list** of the six daily times. The **center** row is the focus (brass highlight); the **next upcoming** prayer is marked in **green**. Countdowns show time until each prayer.
- **Top**: your **location** (city name, or coordinates in **Auto detect** when GPS has a fix) and **Qibla** direction in degrees.
- **Controls**: **Up / Down** move the list; **Start** opens **Settings**.
- Times come from the [Aladhan](https://aladhan.com/prayer-times-api) API over the phone (**Garmin Connect Mobile**). **Auto detect** uses **live GPS** only—if loading fails, try **Settings → Refresh GPS**.

<img width="480" height="auto" alt="1" src="https://github.com/user-attachments/assets/5624fc49-6e45-4799-981e-8036a55af475" />

### Settings view
- Press Select/Start on the prayer view to open Settings.
- Rotating **center-selected** menu with the **same brass bar + slanted accent** treatment as the prayer and city lists. **Find Qibla** is the default highlighted row when you open Settings.
- Menu items (in order):
  - **Find Qibla** — opens the compass (back returns to Settings).
  - **Set Location** — opens the location list: Auto detect + 50 cities (back returns to Settings).
  - **Refresh GPS** — samples GPS again; if **Auto detect** is selected, **refetches prayer times** and then **returns to the prayer screen** (pops Settings).
  - **About** — version and last-updated info.

<img width="480" height="auto" alt="1" src="https://github.com/user-attachments/assets/267db731-37d1-4f6b-8f2b-6a4c8ad805ba" />


### Find Qibla view
- Live **compass**; **heading** comes from the device sensor when available.
- **Fixed city**: bearing and label use that city’s coordinates.
- **Auto detect**: uses **live GPS** only (same as prayer times); no position without a current fix.
- **Kaaba** marker on the outer ring; **green-night** face, brass rings, and a **lancet-style** needle (green tones on this screen) with shadow, rim, glint, and hub stack.

<img width="480" height="auto" alt="4" src="https://github.com/user-attachments/assets/30207621-3b22-4882-80ef-98e8e2c64eb9" />

### City selection view
- Open from **Settings → Set Location**.
- **Auto detect** (GPS) is the **first** row, then **50 cities** sorted **east to west** by longitude. Each row shows **qibla direction** (`--°` for Auto until a live GPS fix). **Up / Down** moves selection; **Select** confirms and refreshes prayer times.
- Selection uses the **same brass highlight** pattern as the prayer screen.
- Selected location (including Auto detect) is **persisted** in app storage across launches (with a one-time migration when the list layout changed).

<img width="480" height="auto" alt="3" src="https://github.com/user-attachments/assets/aa015add-c03b-441e-a5dc-fd4f07dd9cee" />

## Supported locations
- **Auto detect** — prayer times and Qibla from **live GPS** only. Listed first in the app. Use **Refresh GPS** in Settings if you need a new sample.
- **50 cities** (east → west): Brisbane, Sydney, Melbourne, Tokyo, Jakarta, Singapore, Kuala Lumpur, Dhaka, New Delhi, Mumbai, Tashkent, Karachi, Dubai, Abu Dhabi, Tehran, Doha, Kuwait City, Riyadh, Baghdad, Makkah, Medina, Moscow, Nairobi, Amman, Beirut, Khartoum, Cairo, Istanbul, Cape Town, Berlin, Rome, Tunis, Amsterdam, Lagos, Algiers, Paris, Barcelona, London, Birmingham, Madrid, Casablanca, New York, Toronto, Miami, Chicago, Houston, Austin, Los Angeles, San Francisco, Vancouver

## Supported Devices
- Garmin Forerunner 165
- Garmin Forerunner 165 Music
- Garmin Forerunner 255S Music
- Garmin Forerunner 265
- Garmin Forerunner 265S
- Garmin Forerunner 570 (42mm)
- Garmin Forerunner 570 (47mm)
- Garmin Forerunner 965
- Garmin Forerunner 970

## Building
1. Install the [Connect IQ SDK](https://developer.garmin.com/connect-iq/sdk/) and Java 8+ (use a SDK version compatible with your `manifest.xml` **minSdkVersion**).
2. Install the [Monkey C VS Code Extension](https://marketplace.visualstudio.com/items?itemName=garmin.monkey-c).
3. Generate a developer key: `openssl genrsa 4096 | openssl pkcs8 -topk8 -nocrypt -outform DER -out developer_key.der`
4. **Debug / simulator build** (`.prg`):
   - `monkeyc -f monkey.jungle -o bin/app.prg -y developer_key.der`
5. **Release package** (signed `.iq` for store or sideload):
   - `monkeyc -e -r -f monkey.jungle -o Waqt-Garmin-OS.iq -y developer_key.der`
   - Optional optimisation: add `-O p` (performance) or `-O z` (code size); see `monkeyc --help`.
6. Run in simulator (adjust path to your SDK and device id, e.g. `fr970`):
   - `"/path/to/connectiq-sdk/.../bin/monkeydo" bin/app.prg fr970`

## Installing on Watch
- **Simulator / dev**: copy `bin/app.prg` to the watch `GARMIN/APPS/` folder over USB, or use the Connect IQ app.
- **Release**: install or publish the generated `.iq` package.

## Promo image
The Connect IQ–style landscape banner `media/waqt-promo.png` (**1440×720**) is generated from `media/source-prayer-screen.png` so store art matches the current prayer UI. The left-hand feature list uses **green** accents (same family as the in-app Qibla line) and calls out **FIFTY CITIES** and **auto location (GPS)**.

1. Replace `media/source-prayer-screen.png` with a current export or photo (same aspect as your reference frame is fine; the script scales it).
2. Install [Pillow](https://pypi.org/project/pillow/) if needed: `pip install pillow`
3. Run: `python3 media/build_promo.py`

This overwrites `media/waqt-promo.png`. Typography uses macOS **Georgia** and **Arial** from `/System/Library/Fonts/Supplemental/`; on Linux adjust the font paths in `media/build_promo.py` if you regenerate there.

## Note
- https://api.aladhan.com/v1 API is used to fetch prayer times.
- The app requires a phone with the Garmin Connect Mobile app for API requests (Garmin watches route HTTP requests through the phone via Bluetooth).
- **Sensor** permission: live heading on the Find Qibla compass page.
- **Positioning** permission: GPS for **Auto detect** (prayer times and Qibla) and **Refresh GPS**.
- **Simulator**: GPS and phone-routed HTTP are often unreliable; use a **named city** to verify API behaviour, or test on a paired watch and phone.
