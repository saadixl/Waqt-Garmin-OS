# Waqt - Garmin OS

A prayer times watch app for Garmin devices, built with Connect IQ (Monkey C). The UI uses a **brass and cyan** theme aligned with the Qibla compass: warm brass bezels and accents, soft cyan for “next” cues and the live needle, and ivory/white typography on deep black.


## Features

### Prayer times view
- Center-focused list: the **selected** prayer sits in a **solid brass** bar (same tone as the Qibla outer ring) with a **light brass accent** on the slanted leading edge.
- **Outer** rows use subtle, round-aware inset panels; the **next** prayer (when not in the center slot) gets a slightly lifted panel and a **cyan pip** beside the name.
- **Header**: city title with light/deep brass emboss, **Qibla bearing** in cyan with a soft lift, and a **double hairline** separating the header from the list.
- Countdown behaviour unchanged: full countdown for the next prayer (and for the centered row); shorter remaining-time hints on other rows. Colours are tuned so the center row reads crisply on brass, with teal-muted lines elsewhere.
- **Up / Down** scrolls the list. **Select/Start** opens Settings.
- **Chrome**: brass **scroll chevrons** (beveled shadow + highlight) and a **settings** cue (brass bezel ring, cyan center jewel) near the physical control cluster on supported models.
- **Loading** shows brass primary copy with a subtle teal ellipsis; **errors** show a clear system-style message.

<img width="480" height="auto" alt="1" src="https://github.com/user-attachments/assets/5624fc49-6e45-4799-981e-8036a55af475" />

### Settings view
- Press Select/Start on the prayer view to open Settings.
- Rotating **center-selected** menu with the **same brass bar + slanted accent** treatment as the prayer and city lists.
- Menu items:
  - Select location
  - Find Qibla
  - About

<img width="480" height="auto" alt="2" src="https://github.com/user-attachments/assets/7a7634e2-8cb8-4a39-8802-d764425547e5" />

### Find Qibla view
- Live **compass** for the current city; **heading** comes from the device sensor when available.
- **Kaaba** marker on the outer ring; city name and bearing inside the face.
- **Qibla hand**: cyan **lancet-style** needle (tip toward Mecca, counterweight toward the hub), with depth **shadow**, **rim/body** layers, a small **glint**, **tip highlight**, and a **hub** stack (brass rim, dark core, cyan collar, bright pin).

<img width="480" height="auto" alt="4" src="https://github.com/user-attachments/assets/30207621-3b22-4882-80ef-98e8e2c64eb9" />

### City selection view
- Open from **Settings → Select location**.
- **20 cities** with qibla direction shown per row; **Up / Down** moves selection; **Select** confirms and refreshes prayer times for that city.
- Selection uses the **same brass highlight** pattern as the prayer screen.
- Selected city is persisted across app launches.

<img width="480" height="auto" alt="3" src="https://github.com/user-attachments/assets/aa015add-c03b-441e-a5dc-fd4f07dd9cee" />

## Supported Cities
Singapore, Sydney, Tokyo, Kuala Lumpur, Jakarta, Dhaka, New Delhi, Karachi, Dubai, Tehran, Doha, Moscow, Makkah, Istanbul, Paris, London, Toronto, New York, Austin, San Francisco

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

## Note
- https://api.aladhan.com/v1 API is used to fetch prayer times.
- The app requires a phone with the Garmin Connect Mobile app for API requests (Garmin watches route HTTP requests through the phone via Bluetooth).
- The app uses the Sensor permission for live heading on the Find Qibla compass page.
