# Waqt - Garmin OS

A prayer times watch app for Garmin devices, built with Connect IQ (Monkey C).

![1](https://github.com/user-attachments/assets/f9bfbbb4-7cee-4332-aa63-32fe26d090bc)


## Features

### Prayer times view
- See the next prayer time, previous prayer time, and surrounding prayer times once the app is opened
- See the selected city and qibla direction from the selected city on the header
- Pressing Up / Down button navigates between prayer times
- Live countdown timer to the next prayer, updating every second

<img width="744" height="831" alt="Screenshot 2026-04-01 at 7 03 53 PM" src="https://github.com/user-attachments/assets/a6c0f38d-8328-4228-9e58-c6cc8701c0ff" />


### City selection view
- Pressing the Select button opens the city selection view
- Currently 20 cities are supported and their qibla direction is also shown
- Pressing Up / Down button navigates between cities
- Pressing the Select button selects the city and fetches corresponding prayer times
- Selected city is persisted across app launches

<img width="743" height="828" alt="Screenshot 2026-04-01 at 7 03 41 PM" src="https://github.com/user-attachments/assets/6db57825-f7fb-4fef-8d4c-9e8307c832da" />


## Supported Cities
Singapore, Sydney, Tokyo, Kuala Lumpur, Jakarta, Dhaka, New Delhi, Karachi, Dubai, Tehran, Doha, Moscow, Makkah, Istanbul, Paris, London, Toronto, New York, Austin, San Francisco

## Target Device
- Garmin Forerunner 970

## Building
1. Install the [Connect IQ SDK](https://developer.garmin.com/connect-iq/sdk/) (4.0.6+) and Java 8+
2. Install the [Monkey C VS Code Extension](https://marketplace.visualstudio.com/items?itemName=garmin.monkey-c)
3. Generate a developer key: `openssl genrsa 4096 | openssl pkcs8 -topk8 -nocrypt -outform DER -out developer_key.der`
4. Set the key in VS Code: `Cmd+Shift+P` > "Monkey C: Set Developer Key"
5. Build: `Cmd+Shift+P` > "Monkey C: Build Current Project"

## Installing on Watch
Copy `bin/WaqtGarminOS.prg` to the `GARMIN/APPS/` folder on your watch via USB, or side-load through the Connect IQ mobile app.

## Note
- https://api.aladhan.com/v1 API is used to fetch prayer times.
- The app requires a phone with the Garmin Connect Mobile app for API requests (Garmin watches route HTTP requests through the phone via Bluetooth).
