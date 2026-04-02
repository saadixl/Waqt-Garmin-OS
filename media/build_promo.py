#!/usr/bin/env python3
"""Regenerate media/waqt-promo.png (1440×720) from media/source-prayer-screen.png."""

from __future__ import annotations

import os

from PIL import Image, ImageDraw, ImageFilter, ImageFont

W, H = 1440, 720

VOID = (3, 5, 6)
BRASS_MID = (114, 96, 69)
BRASS_LIGHT = (201, 184, 150)
CYAN = (126, 200, 212)
CYAN_BRIGHT = (173, 228, 238)
IVORY = (232, 228, 220)
IVORY_MUTED = (178, 172, 162)

MEDIA = os.path.dirname(os.path.abspath(__file__))
SCREENSHOT = os.path.join(MEDIA, "source-prayer-screen.png")
OUT = os.path.join(MEDIA, "waqt-promo.png")

GEORGIA = "/System/Library/Fonts/Supplemental/Georgia.ttf"
ARIAL = "/System/Library/Fonts/Supplemental/Arial.ttf"


def _gradient_footer(draw: ImageDraw.ImageDraw) -> None:
    for x in range(W):
        t = x / max(W - 1, 1)
        r = int(BRASS_MID[0] * (1 - t) + CYAN[0] * t)
        g = int(BRASS_MID[1] * (1 - t) + CYAN[1] * t)
        b = int(BRASS_MID[2] * (1 - t) + CYAN[2] * t)
        draw.line([(x, H - 3), (x, H)], fill=(r, g, b))


def _font(path: str, size: int) -> ImageFont.FreeTypeFont | ImageFont.ImageFont:
    try:
        return ImageFont.truetype(path, size)
    except OSError:
        return ImageFont.load_default()


def build() -> Image.Image:
    canvas = Image.new("RGBA", (W, H), (*VOID, 255))

    gb = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    ImageDraw.Draw(gb).ellipse((-280, -120, 620, 880), fill=(*BRASS_MID, 78))
    canvas = Image.alpha_composite(canvas, gb)

    gc = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    ImageDraw.Draw(gc).ellipse((860, -180, 1560, 420), fill=(*CYAN, 32))
    canvas = Image.alpha_composite(canvas, gc)

    d = ImageDraw.Draw(canvas)
    f_eyebrow = _font(ARIAL, 16)
    f_title = _font(GEORGIA, 118)
    f_sub = _font(ARIAL, 26)
    f_li = _font(ARIAL, 22)

    d.text((72, 128), "CONNECT IQ", fill=(*CYAN_BRIGHT, 255), font=f_eyebrow)
    d.text((72, 168), "Waqt", fill=(*IVORY, 255), font=f_title)
    d.text((72, 312), "ISLAMIC PRAYER TIMES APP FOR GARMIN", fill=(*BRASS_LIGHT, 255), font=f_sub)

    y = 378
    for line in (
        "PRAYER TIMES WITH LIVE COUNT DOWN",
        "TWENTY CITIES",
        "QIBLA COMPASS",
    ):
        d.ellipse((72, y + 8, 82, y + 18), fill=(*CYAN, 255))
        d.text((96, y), line, fill=(*IVORY_MUTED, 255), font=f_li)
        y += 34

    watch = Image.open(SCREENSHOT).convert("RGBA")
    target_h = 618
    scale = target_h / watch.height
    nw, nh = int(watch.width * scale), int(watch.height * scale)
    watch = watch.resize((nw, nh), Image.LANCZOS)
    px = W - nw - 52
    py = (H - nh) // 2
    radius = 26

    shadow = Image.new("RGBA", (nw + 48, nh + 48), (0, 0, 0, 0))
    ImageDraw.Draw(shadow).rounded_rectangle(
        (18, 18, 18 + nw, 18 + nh),
        radius=radius + 6,
        fill=(0, 0, 0, 125),
    )
    shadow = shadow.filter(ImageFilter.GaussianBlur(16))
    sl = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    sl.paste(shadow, (px - 14, py - 10), shadow)
    canvas = Image.alpha_composite(canvas, sl)

    mask = Image.new("L", (nw, nh), 0)
    ImageDraw.Draw(mask).rounded_rectangle((0, 0, nw, nh), radius=radius, fill=255)
    plate = Image.new("RGBA", (nw, nh), (0, 0, 0, 0))
    ImageDraw.Draw(plate).rounded_rectangle(
        (0, 0, nw, nh),
        radius=radius,
        fill=(16, 14, 12, 255),
    )
    stack = Image.alpha_composite(plate, watch)
    wl = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    wl.paste(stack, (px, py), mask)
    canvas = Image.alpha_composite(canvas, wl)

    out = canvas.convert("RGB")
    _gradient_footer(ImageDraw.Draw(out))
    return out


def main() -> None:
    if not os.path.isfile(SCREENSHOT):
        raise SystemExit(f"Missing {SCREENSHOT}")
    build().save(OUT, "PNG", optimize=True)
    print(f"Wrote {OUT}")


if __name__ == "__main__":
    main()
