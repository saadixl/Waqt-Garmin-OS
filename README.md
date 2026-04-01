# Waqt - Garmin OS

A prayer times watch app for Garmin devices, built with Connect IQ (Monkey C).

![1](https://github.com/user-attachments/assets/f9bfbbb4-7cee-4332-aa63-32fe26d090bc)


## Features

### Prayer times view
- See the next prayer time, previous prayer time, and surrounding prayer times once the app is opened
- See the selected city and qibla direction from the selected city on the header
- Pressing Up / Down button navigates between prayer times
- Live countdown timer to the next prayer, updating every second
- Settings icon cue on the right side to open Settings

<img width="480" height="auto" alt="1" src="https://github.com/user-attachments/assets/b6880fd1-ac5c-48f5-ac3d-76afc71e3ba2" />


### Settings view
- Press Select/Start on prayer view to open Settings
- Rotating center-selected menu (same interaction style as other lists)
- Menu items:
  - Select location
  - Find Qibla
  - About
 
<img width="480" height="auto" alt="2" src="https://github.com/user-attachments/assets/32aa0cfe-5dab-43ad-9adb-d8bbccc6ec10" />


### Find Qibla view
- Live compass page that points toward Qibla for the currently selected city
- Uses device heading sensor when available
- Kaaba marker shown on the compass ring at Qibla bearing
- City name and Qibla degree are shown inside the compass

<img width="480" height="auto" alt="4" src="https://github.com/user-attachments/assets/b04900e5-c06f-4d07-9732-bc818b15a3bf" />


### City selection view
- Accessible from Settings -> Select location
- Currently 20 cities are supported and their qibla direction is also shown
- Pressing Up / Down button navigates between cities
- Pressing the Select button selects the city and fetches corresponding prayer times
- Selected city is persisted across app launches

<img width="480" height="auto" alt="3" src="https://github.com/user-attachments/assets/62228785-0153-4338-9f99-3ddeddf64164" />

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
1. Install the [Connect IQ SDK](https://developer.garmin.com/connect-iq/sdk/) (4.0.6+) and Java 8+
2. Install the [Monkey C VS Code Extension](https://marketplace.visualstudio.com/items?itemName=garmin.monkey-c)
3. Generate a developer key: `openssl genrsa 4096 | openssl pkcs8 -topk8 -nocrypt -outform DER -out developer_key.der`
4. Build from terminal:
   - `monkeyc -f monkey.jungle -o bin/app.prg -y developer_key.der`
5. Run in simulator:
   - `"/Users/saadixl/Library/Application Support/Garmin/ConnectIQ/Sdks/connectiq-sdk-mac-9.1.0-2026-03-09-6a872a80b/bin/monkeydo" bin/app.prg fr970`

## Installing on Watch
Copy your generated `.prg` (for example `bin/app.prg`) to the `GARMIN/APPS/` folder on your watch via USB, or side-load through the Connect IQ mobile app.

## Note
- https://api.aladhan.com/v1 API is used to fetch prayer times.
- The app requires a phone with the Garmin Connect Mobile app for API requests (Garmin watches route HTTP requests through the phone via Bluetooth).
- The app uses the Sensor permission for live heading on the Find Qibla compass page.
