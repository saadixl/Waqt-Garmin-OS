module Constants {
    // Match Qibla needle greens (WaqtQiblaView cNeedleBody / Sh / Edge)
    const COLOR_PRIMARY = 0x5CB88A;
    const COLOR_PRIMARY_DARK = 0x2A6B48;
    const COLOR_PRIMARY_LIGHT = 0x9DD4B0;
    // Brass family (matches Qibla bezel)
    const COLOR_ACTIVE = 0x5A4C38;       // Dark brass — selection fills, arrows
    const COLOR_TEXT = 0xE8E4DC;         // Warm ivory — primary labels
    const COLOR_GRAY = 0xFFFFFF;          // White — was slate; use for secondary / inactive labels
    const COLOR_BG_ITEM = 0x2A2A2A;     // Dark gray - list item background
    const COLOR_BG_ITEM_ALT = 0x353535; // Slightly lighter gray
    const COLOR_BG = 0x000000;          // Black background
    const COLOR_ERROR = 0xFF5733;       // Red - error text
    const COLOR_ACTIVE_BORDER = 0xC9B896; // Light brass — borders, cues, gradient top
    const COLOR_ACTIVE_DARK = 0x3D3428;   // Deep brass shadow
    const COLOR_ACTIVE_MID = 0x726045;    // Qibla outer brass ring; list selection fill
    const COLOR_SELECTION_OUTLINE = 0x726045; // Bezel frame — ListSelectionChrome

    // App metadata
    const APP_VERSION = "1.4.0";
    const LAST_UPDATED = "2026-04-01";
    const CONTACT_EMAIL = "ammasudulhaque@gmail.com";

    // Prayer names
    const PRAYER_NAMES = ["Fajr", "Sunrise", "Dhuhr", "Asr", "Maghrib", "Isha"];
    const PRAYER_COUNT = 6;
}
