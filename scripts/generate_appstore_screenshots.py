#!/usr/bin/env python3
from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import Callable, Iterable, Sequence

from PIL import Image, ImageDraw, ImageFilter, ImageFont


ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "appstore_screenshots"
WIDTH = 2880
HEIGHT = 1800

FONT_REGULAR = "/System/Library/Fonts/SFNS.ttf"
FONT_MONO = "/System/Library/Fonts/SFNSMono.ttf"
ICON_PATH = ROOT / "Assets" / "AppIconSource.png"

INK = (246, 248, 250)
MUTED = (178, 187, 197)
MUTED_DARK = (94, 103, 115)
LINE = (214, 222, 230)
PANEL = (255, 255, 255)
DARK = (19, 24, 31)
BLUE = (63, 130, 255)
CYAN = (51, 190, 205)
GREEN = (44, 190, 118)
ORANGE = (245, 151, 64)
PURPLE = (132, 99, 230)
PINK = (230, 91, 150)
YELLOW = (246, 199, 85)


@dataclass(frozen=True)
class Screen:
    filename: str
    title: str
    subtitle: str
    selected_tab: str
    accent: tuple[int, int, int]
    secondary: tuple[int, int, int]
    background: tuple[tuple[int, int, int], tuple[int, int, int]]
    drawer: Callable[[Image.Image, ImageDraw.ImageDraw, "Screen"], None]


def font(size: int, mono: bool = False) -> ImageFont.FreeTypeFont:
    return ImageFont.truetype(FONT_MONO if mono else FONT_REGULAR, size=size)


def text(
    draw: ImageDraw.ImageDraw,
    xy: tuple[float, float],
    value: str,
    size: int,
    fill: tuple[int, int, int] = DARK,
    *,
    mono: bool = False,
    anchor: str | None = None,
) -> None:
    draw.text(xy, value, font=font(size, mono=mono), fill=fill, anchor=anchor)


def text_box(draw: ImageDraw.ImageDraw, value: str, size: int) -> tuple[int, int]:
    box = draw.textbbox((0, 0), value, font=font(size))
    return box[2] - box[0], box[3] - box[1]


def wrap_text(draw: ImageDraw.ImageDraw, value: str, size: int, max_width: int) -> list[str]:
    lines: list[str] = []
    current = ""
    for word in value.split():
        trial = f"{current} {word}".strip()
        if not current or text_box(draw, trial, size)[0] <= max_width:
            current = trial
        else:
            lines.append(current)
            current = word
    if current:
        lines.append(current)
    return lines


def rounded(
    draw: ImageDraw.ImageDraw,
    box: tuple[float, float, float, float],
    radius: int,
    fill: tuple[int, int, int] | tuple[int, int, int, int],
    outline: tuple[int, int, int] | None = None,
    width: int = 1,
) -> None:
    draw.rounded_rectangle(box, radius=radius, fill=fill, outline=outline, width=width)


def shadow(base: Image.Image, box: tuple[int, int, int, int], radius: int, opacity: int = 88) -> None:
    layer = Image.new("RGBA", base.size, (0, 0, 0, 0))
    draw = ImageDraw.Draw(layer)
    x1, y1, x2, y2 = box
    draw.rounded_rectangle((x1, y1 + 42, x2, y2 + 42), radius=radius, fill=(0, 0, 0, opacity))
    base.alpha_composite(layer.filter(ImageFilter.GaussianBlur(48)))


def gradient_background(start: tuple[int, int, int], end: tuple[int, int, int]) -> Image.Image:
    img = Image.new("RGBA", (WIDTH, HEIGHT), start + (255,))
    pixels = img.load()
    for y in range(HEIGHT):
        vy = y / max(HEIGHT - 1, 1)
        for x in range(WIDTH):
            vx = x / max(WIDTH - 1, 1)
            t = (vx * 0.56 + vy * 0.44)
            pixels[x, y] = tuple(int(start[i] * (1 - t) + end[i] * t) for i in range(3)) + (255,)
    return img


def soft_panel(
    base: Image.Image,
    box: tuple[int, int, int, int],
    color: tuple[int, int, int],
    alpha: int,
    radius: int,
    blur: int,
) -> None:
    layer = Image.new("RGBA", base.size, (0, 0, 0, 0))
    draw = ImageDraw.Draw(layer)
    draw.rounded_rectangle(box, radius=radius, fill=color + (alpha,))
    base.alpha_composite(layer.filter(ImageFilter.GaussianBlur(blur)))


def draw_brand(img: Image.Image, draw: ImageDraw.ImageDraw) -> None:
    if ICON_PATH.exists():
        icon = Image.open(ICON_PATH).convert("RGBA").resize((118, 118), Image.LANCZOS)
        mask = Image.new("L", icon.size, 0)
        mdraw = ImageDraw.Draw(mask)
        mdraw.rounded_rectangle((0, 0, 118, 118), radius=26, fill=255)
        img.alpha_composite(Image.composite(icon, Image.new("RGBA", icon.size, (0, 0, 0, 0)), mask), (168, 138))
    else:
        rounded(draw, (168, 138, 286, 256), 26, (28, 34, 42))
    text(draw, (314, 155), "KeyThock", 48, INK)
    text(draw, (316, 211), "Keyboard sounds for Mac", 28, MUTED)


def draw_canvas(screen: Screen) -> Image.Image:
    img = gradient_background(*screen.background)
    draw = ImageDraw.Draw(img)

    soft_panel(img, (-280, 20, 930, 540), screen.accent, 95, 260, 34)
    soft_panel(img, (1820, 1140, 3160, 1900), screen.secondary, 70, 320, 58)

    for offset in range(-500, WIDTH + 500, 180):
        draw.line((offset, -80, offset - 560, HEIGHT + 120), fill=(255, 255, 255, 18), width=3)

    draw_brand(img, draw)
    pill(draw, 2205, 144, "Mac App Store ready", screen.accent, fg=(255, 255, 255), w=430, h=62)

    y = 330
    for idx, line in enumerate(wrap_text(draw, screen.title, 82, 1160)):
        text(draw, (168, y + idx * 94), line, 82, INK)
    subtitle_y = y + max(1, len(wrap_text(draw, screen.title, 82, 1160))) * 98 + 4
    for idx, line in enumerate(wrap_text(draw, screen.subtitle, 36, 1080)):
        text(draw, (172, subtitle_y + idx * 48), line, 36, MUTED)

    screen.drawer(img, draw, screen)
    return img


def pill(
    draw: ImageDraw.ImageDraw,
    x: int,
    y: int,
    label: str,
    fill: tuple[int, int, int],
    *,
    fg: tuple[int, int, int] = DARK,
    w: int | None = None,
    h: int = 50,
) -> tuple[int, int, int, int]:
    tw, _ = text_box(draw, label, 24)
    width = w or tw + 44
    rounded(draw, (x, y, x + width, y + h), h // 2, fill)
    text(draw, (x + width / 2, y + h / 2 - 2), label, 24, fg, anchor="mm")
    return (x, y, x + width, y + h)


def glass_card(
    img: Image.Image,
    box: tuple[int, int, int, int],
    *,
    fill: tuple[int, int, int] = (255, 255, 255),
    alpha: int = 232,
    radius: int = 30,
    outline_alpha: int = 72,
) -> ImageDraw.ImageDraw:
    shadow(img, box, radius, opacity=64)
    layer = Image.new("RGBA", img.size, (0, 0, 0, 0))
    ldraw = ImageDraw.Draw(layer)
    ldraw.rounded_rectangle(box, radius=radius, fill=fill + (alpha,), outline=(255, 255, 255, outline_alpha), width=2)
    img.alpha_composite(layer)
    return ImageDraw.Draw(img)


def draw_app_window(
    img: Image.Image,
    selected: str,
    x: int = 690,
    y: int = 600,
    w: int = 2020,
    h: int = 1000,
) -> tuple[int, int, int, int]:
    draw = ImageDraw.Draw(img)
    box = (x, y, x + w, y + h)
    glass_card(img, box, fill=(252, 254, 255), alpha=248, radius=34)
    draw = ImageDraw.Draw(img)

    rounded(draw, (x, y, x + w, y + 88), 34, (249, 251, 253))
    draw.rectangle((x, y + 50, x + w, y + 90), fill=(249, 251, 253))
    for i, color in enumerate([(255, 95, 87), (255, 189, 46), (40, 201, 64)]):
        draw.ellipse((x + 34 + i * 38, y + 33, x + 56 + i * 38, y + 55), fill=color)
    text(draw, (x + w // 2, y + 43), "KeyThock", 24, (82, 91, 102), anchor="mm")

    sidebar_w = 330
    draw.rectangle((x, y + 88, x + sidebar_w, y + h), fill=(242, 246, 250))
    draw.line((x + sidebar_w, y + 88, x + sidebar_w, y + h), fill=LINE, width=2)
    tabs = ["Home", "Sound Packs", "Mixer", "Keys", "App Profiles", "Diagnostics", "Privacy", "Settings"]
    yy = y + 134
    for tab in tabs:
        active = tab == selected
        if active:
            rounded(draw, (x + 28, yy - 12, x + sidebar_w - 22, yy + 52), 16, (223, 237, 255))
        icon_x = x + 58
        icon_y = yy + 12
        icon_color = BLUE if active else (126, 138, 150)
        if tab == "Mixer":
            for k in range(3):
                draw.line((icon_x - 13, icon_y - 10 + k * 10, icon_x + 14, icon_y - 10 + k * 10), fill=icon_color, width=4)
        elif tab == "Keys":
            rounded(draw, (icon_x - 14, icon_y - 11, icon_x + 16, icon_y + 11), 5, (0, 0, 0, 0), outline=icon_color, width=3)
        elif tab == "Privacy":
            draw.polygon(
                [(icon_x, icon_y - 17), (icon_x + 17, icon_y - 8), (icon_x + 11, icon_y + 15), (icon_x, icon_y + 22), (icon_x - 11, icon_y + 15), (icon_x - 17, icon_y - 8)],
                outline=icon_color,
            )
        else:
            draw.ellipse((icon_x - 14, icon_y - 14, icon_x + 14, icon_y + 14), outline=icon_color, width=3)
        text(draw, (x + 96, yy + 3), tab, 25, BLUE if active else (52, 61, 72))
        yy += 74
    return box


def section_header(draw: ImageDraw.ImageDraw, x: int, y: int, title: str, subtitle: str) -> None:
    text(draw, (x, y), title, 42, DARK)
    text(draw, (x, y + 56), subtitle, 24, MUTED_DARK)


def ui_panel(draw: ImageDraw.ImageDraw, box: tuple[int, int, int, int], fill: tuple[int, int, int] = (248, 251, 253)) -> None:
    rounded(draw, box, 18, fill, outline=LINE, width=2)


def small_button(draw: ImageDraw.ImageDraw, box: tuple[int, int, int, int], label: str, active: bool = False) -> None:
    rounded(draw, box, 12, BLUE if active else (234, 239, 244))
    text(draw, (box[0] + 20, box[1] + 12), label, 21, (255, 255, 255) if active else DARK)


def callout(
    img: Image.Image,
    x: int,
    y: int,
    title: str,
    body: str,
    accent: tuple[int, int, int],
    *,
    w: int = 430,
) -> None:
    glass_card(img, (x, y, x + w, y + 162), fill=(255, 255, 255), alpha=224, radius=24)
    draw = ImageDraw.Draw(img)
    rounded(draw, (x + 24, y + 28, x + 68, y + 72), 12, accent)
    text(draw, (x + 46, y + 50), "+", 28, (255, 255, 255), anchor="mm")
    text(draw, (x + 88, y + 28), title, 28, DARK)
    for idx, line in enumerate(wrap_text(draw, body, 22, w - 116)[:2]):
        text(draw, (x + 88, y + 68 + idx * 30), line, 22, MUTED_DARK)


def draw_waveform(draw: ImageDraw.ImageDraw, x: int, y: int, color: tuple[int, int, int], scale: int = 1) -> None:
    heights = [18, 34, 56, 88, 120, 88, 56, 34, 18]
    for i, height in enumerate(heights):
        xx = x + i * 18 * scale
        draw.rounded_rectangle((xx, y - height // 2, xx + 8 * scale, y + height // 2), radius=5, fill=color)


def draw_sound_pack_card(
    draw: ImageDraw.ImageDraw,
    x: int,
    y: int,
    name: str,
    tags: Sequence[str],
    desc: str,
    accent: tuple[int, int, int],
    active: bool = False,
) -> None:
    ui_panel(draw, (x, y, x + 498, y + 232), (247, 250, 252))
    rounded(draw, (x + 24, y + 24, x + 78, y + 78), 14, tuple(min(255, c + 150) for c in accent))
    draw_waveform(draw, x + 38, y + 51, accent)
    text(draw, (x + 98, y + 28), name, 29, DARK)
    for idx, line in enumerate(wrap_text(draw, desc, 20, 420)[:2]):
        text(draw, (x + 24, y + 93 + idx * 27), line, 20, MUTED_DARK)
    tx = x + 24
    for tag_name in tags:
        tw, _ = text_box(draw, tag_name, 18)
        rounded(draw, (tx, y + 146, tx + tw + 28, y + 181), 10, (233, 238, 243))
        text(draw, (tx + 14, y + 154), tag_name, 18, (68, 78, 90))
        tx += tw + 38
    small_button(draw, (x + 24, y + 190, x + 150, y + 224), "Preview")
    small_button(draw, (x + 166, y + 190, x + 262, y + 224), "Use", active)


def draw_sound_packs(img: Image.Image, draw: ImageDraw.ImageDraw, screen: Screen) -> None:
    x1, y1, x2, y2 = draw_app_window(img, "Sound Packs", 620, 610, 2100, 1000)
    cx, cy = x1 + 380, y1 + 132
    section_header(draw, cx, cy, "Sound Packs", "Recorded packs, instant previews, and custom imports.")
    rounded(draw, (cx, cy + 120, cx + 520, cy + 174), 14, (247, 249, 251), outline=LINE, width=2)
    text(draw, (cx + 24, cy + 136), "Search", 22, (144, 154, 164))
    small_button(draw, (cx + 550, cy + 118, cx + 700, cy + 176), "All")
    small_button(draw, (cx + 724, cy + 118, cx + 872, cy + 176), "Import")

    packs = [
        ("Creamy-2", ["Linear", "Medium", "Balanced"], "Smooth recorded keypresses from real keyboard audio.", BLUE, True),
        ("Thocky-2", ["Linear", "Deep"], "Rounded low-end hits for a deeper typing tone.", GREEN, False),
        ("Clacky-2", ["Clicky", "Bright"], "Crisp, lively samples for a sharp desk sound.", ORANGE, False),
        ("Typewriter-1", ["Vintage", "Spacebar"], "Classic typewriter keys with a dedicated spacebar.", PURPLE, False),
        ("Bubble-1", ["ASMR", "Soft"], "Gentle bubble taps for quieter, cozy typing.", CYAN, False),
        ("Morse-1", ["Morse", "Queued"], "Letters and numbers play Morse equivalents.", YELLOW, False),
    ]
    for idx, pack in enumerate(packs):
        col, row = idx % 3, idx // 3
        draw_sound_pack_card(draw, cx + col * 530, cy + 224 + row * 260, *pack)

    callout(img, 176, 1060, "Recorded, not fake", "Built from real keyboard recordings and extracted keypress samples.", screen.accent, w=480)
    callout(img, 176, 1248, "Preview first", "Hear every pack before you switch your daily typing sound.", screen.secondary, w=480)
    keycap_stack(draw, 2380, 440, ["Creamy", "Thocky", "Typewriter"], screen.accent)


def keycap_stack(draw: ImageDraw.ImageDraw, x: int, y: int, labels: Sequence[str], accent: tuple[int, int, int]) -> None:
    for idx, label in enumerate(labels):
        yy = y + idx * 86
        rounded(draw, (x + idx * 24, yy, x + 320 + idx * 24, yy + 68), 18, (255, 255, 255, 36), outline=(255, 255, 255), width=2)
        text(draw, (x + 32 + idx * 24, yy + 19), label, 26, DARK)
    draw_waveform(draw, x + 38, y + 308, accent, scale=2)


def draw_keyboard(draw: ImageDraw.ImageDraw, x: int, y: int, w: int) -> None:
    rows = [
        [("esc", 1), ("1", 1), ("2", 1), ("3", 1), ("4", 1), ("5", 1), ("6", 1), ("7", 1), ("8", 1), ("9", 1), ("0", 1), ("-", 1), ("=", 1), ("delete", 1.6)],
        [("tab", 1.4), ("Q", 1), ("W", 1), ("E", 1), ("R", 1), ("T", 1), ("Y", 1), ("U", 1), ("I", 1), ("O", 1), ("P", 1), ("[", 1), ("]", 1), ("\\\\", 1.2)],
        [("caps", 1.7), ("A", 1), ("S", 1), ("D", 1), ("F", 1), ("G", 1), ("H", 1), ("J", 1), ("K", 1), ("L", 1), (";", 1), ("'", 1), ("return", 1.9)],
        [("shift", 2.15), ("Z", 1), ("X", 1), ("C", 1), ("V", 1), ("B", 1), ("N", 1), ("M", 1), (",", 1), (".", 1), ("/", 1), ("shift", 2.2)],
        [("fn", 1), ("control", 1.25), ("option", 1.25), ("command", 1.5), ("space", 5.4), ("command", 1.5), ("option", 1.25), ("left", 1), ("up", 1), ("right", 1)],
    ]
    assigned = {"A": "S4", "space": "S2", "return": "S6", "B": "S3", "M": "S1", "delete": "S8"}
    gap = 10
    height = 72
    yy = y
    for row in rows:
        unit = (w - gap * (len(row) - 1)) / sum(unit for _, unit in row)
        xx = x
        for label, unit_count in row:
            key_w = unit * unit_count
            active = label == "A"
            is_assigned = label in assigned
            fill = (224, 238, 255) if active else ((237, 249, 244) if is_assigned else (239, 244, 248))
            outline = BLUE if active else (GREEN if is_assigned else LINE)
            rounded(draw, (xx, yy, xx + key_w, yy + height), 12, fill, outline=outline, width=3 if active or is_assigned else 2)
            text(draw, (xx + key_w / 2, yy + 17), label, 21 if len(label) <= 6 else 17, DARK, anchor="ma")
            text(draw, (xx + key_w / 2, yy + 46), assigned.get(label, "Auto"), 17, MUTED_DARK, mono=True, anchor="ma")
            xx += key_w + gap
        yy += height + 12


def draw_keys(img: Image.Image, draw: ImageDraw.ImageDraw, screen: Screen) -> None:
    x1, y1, x2, y2 = draw_app_window(img, "Keys", 640, 620, 2080, 980)
    cx, cy = x1 + 380, y1 + 132
    section_header(draw, cx, cy, "Keys", "Assign a recorded sample to each physical key.")
    ui_panel(draw, (cx, cy + 112, x2 - 58, y2 - 64), (248, 251, 253))
    rounded(draw, (cx + 34, cy + 146, cx + 398, cy + 200), 14, (235, 240, 245))
    text(draw, (cx + 58, cy + 162), "Creamy-2", 24, DARK)
    small_button(draw, (x2 - 470, cy + 144, x2 - 335, cy + 202), "Preview")
    small_button(draw, (x2 - 315, cy + 144, x2 - 180, cy + 202), "Clear Key")
    small_button(draw, (x2 - 160, cy + 144, x2 - 64, cy + 202), "Reset")
    draw_keyboard(draw, cx + 34, cy + 254, x2 - cx - 126)
    rounded(draw, (cx + 34, y2 - 166, x2 - 96, y2 - 104), 18, (236, 249, 242), outline=(201, 230, 214), width=2)
    text(draw, (cx + 64, y2 - 145), "A", 30, DARK)
    text(draw, (cx + 116, y2 - 139), "Sample 4 of 16", 24, DARK)
    text(draw, (x2 - 330, y2 - 139), "Creamy-2", 22, MUTED_DARK)

    callout(img, 180, 1020, "Per-key control", "Cycle a key through the active pack until the sound feels right.", screen.accent, w=500)
    callout(img, 180, 1210, "Spacebar matters", "Use a deeper or dedicated Space sample without changing the rest.", screen.secondary, w=500)
    draw_arrow(draw, (2000, 1020), (1838, 1290), screen.accent)


def draw_arrow(draw: ImageDraw.ImageDraw, start: tuple[int, int], end: tuple[int, int], color: tuple[int, int, int]) -> None:
    draw.line((start[0], start[1], end[0], end[1]), fill=color, width=6)
    ex, ey = end
    draw.polygon([(ex, ey), (ex - 28, ey - 6), (ex - 8, ey - 28)], fill=color)


def slider(draw: ImageDraw.ImageDraw, x: int, y: int, label: str, pct: float, accent: tuple[int, int, int] = BLUE) -> None:
    text(draw, (x, y), label, 21, DARK)
    track_x = x + 165
    length = 320
    rounded(draw, (track_x, y + 11, track_x + length, y + 21), 5, (214, 222, 230))
    rounded(draw, (track_x, y + 11, track_x + int(length * pct), y + 21), 5, accent)
    knob_x = track_x + int(length * pct)
    draw.ellipse((knob_x - 18, y - 3, knob_x + 18, y + 33), fill=(255, 255, 255), outline=(198, 207, 216), width=2)
    text(draw, (track_x + length + 34, y - 2), f"{int(pct * 100)}%", 21, MUTED_DARK)


def toggle(draw: ImageDraw.ImageDraw, x: int, y: int, label: str, on: bool) -> None:
    text(draw, (x, y + 7), label, 22, DARK)
    fill = BLUE if on else (214, 222, 230)
    rounded(draw, (x + 132, y, x + 202, y + 38), 19, fill)
    knob = x + 168 if on else x + 34
    draw.ellipse((knob - 16, y + 3, knob + 16, y + 35), fill=(255, 255, 255))


def draw_mixer(img: Image.Image, draw: ImageDraw.ImageDraw, screen: Screen) -> None:
    x1, y1, x2, y2 = draw_app_window(img, "Mixer", 650, 620, 2070, 980)
    cx, cy = x1 + 380, y1 + 132
    section_header(draw, cx, cy, "Mixer", "Shape Creamy-2 for the way you type.")
    ui_panel(draw, (cx, cy + 110, x2 - 60, cy + 218), (248, 251, 253))
    rounded(draw, (cx + 32, cy + 138, cx + 94, cy + 200), 16, (230, 238, 255))
    draw_waveform(draw, cx + 45, cy + 169, BLUE)
    text(draw, (cx + 120, cy + 135), "Creamy-2", 31, DARK)
    text(draw, (cx + 120, cy + 176), "linear - balanced - medium", 22, MUTED_DARK)
    toggle(draw, x2 - 770, cy + 151, "Echo", False)
    toggle(draw, x2 - 540, cy + 151, "Reverb", True)
    toggle(draw, x2 - 300, cy + 151, "Ducking", True)

    ui_panel(draw, (cx, cy + 246, x2 - 60, cy + 450), (248, 251, 253))
    text(draw, (cx + 32, cy + 278), "Presets", 30, DARK)
    px = cx + 32
    for label in ["Balanced", "Soft", "Deep", "Crisp", "Calm"]:
        active = label == "Deep"
        rounded(draw, (px, cy + 330, px + 250, cy + 420), 16, (224, 238, 255) if active else (234, 239, 244), outline=BLUE if active else LINE, width=3 if active else 2)
        text(draw, (px + 34, cy + 360), label, 27, BLUE if active else DARK)
        px += 278

    ui_panel(draw, (cx, cy + 474, x2 - 60, y2 - 64), (248, 251, 253))
    text(draw, (cx + 32, cy + 510), "Advanced", 30, DARK)
    text(draw, (cx + 230, cy + 516), "Levels, tone, playback", 23, MUTED_DARK)
    columns = [cx + 34, cx + 620, cx + 1208]
    labels = ["Levels", "Tone", "Playback"]
    for col_x, label in zip(columns, labels):
        text(draw, (col_x, cy + 586), label, 27, DARK)
    slider(draw, columns[0], cy + 646, "Master", 0.25, BLUE)
    slider(draw, columns[0], cy + 710, "Press", 0.92, BLUE)
    slider(draw, columns[0], cy + 774, "Spacebar", 0.72, BLUE)
    slider(draw, columns[1], cy + 646, "Pitch", 0.42, PURPLE)
    slider(draw, columns[1], cy + 710, "Bass", 0.67, PURPLE)
    slider(draw, columns[1], cy + 774, "Bright", 0.55, PURPLE)
    toggle(draw, columns[2], cy + 642, "Variation", True)
    toggle(draw, columns[2], cy + 710, "Release", False)
    toggle(draw, columns[2], cy + 778, "Limiter", True)

    callout(img, 172, 1028, "Instant presets", "Balanced, Soft, Deep, Crisp, and Calm are one click away.", screen.accent, w=500)
    callout(img, 172, 1218, "Effects up front", "Echo, reverb, and auto ducking are visible when you need them.", screen.secondary, w=500)


def draw_menu_bar(img: Image.Image, draw: ImageDraw.ImageDraw, screen: Screen) -> None:
    desktop = (530, 604, 2590, 1548)
    glass_card(img, desktop, fill=(242, 247, 250), alpha=238, radius=36)
    draw = ImageDraw.Draw(img)
    x1, y1, x2, y2 = desktop
    rounded(draw, (x1, y1, x2, y1 + 78), 36, (250, 252, 253))
    draw.rectangle((x1, y1 + 42, x2, y1 + 80), fill=(250, 252, 253))
    text(draw, (x1 + 56, y1 + 27), "Finder", 24, DARK)
    for idx, label in enumerate(["File", "Edit", "View", "Go", "Window", "Help"]):
        text(draw, (x1 + 160 + idx * 88, y1 + 27), label, 23, DARK)
    for idx in range(10):
        rounded(draw, (x2 - 470 + idx * 42, y1 + 28, x2 - 446 + idx * 42, y1 + 50), 6, (75, 86, 98))
    rounded(draw, (x2 - 505, y1 + 16, x2 - 440, y1 + 62), 23, (224, 238, 255))

    pop = (1588, 742, 2370, 1428)
    glass_card(img, pop, fill=(255, 255, 255), alpha=236, radius=34)
    draw = ImageDraw.Draw(img)
    x, y = pop[0] + 34, pop[1] + 34
    rounded(draw, (x, y, x + 62, y + 62), 15, (235, 240, 244))
    text(draw, (x + 31, y + 17), "Key", 24, DARK, anchor="ma")
    text(draw, (x + 86, y + 8), "KeyThock", 28, DARK)
    draw.ellipse((x + 88, y + 47, x + 102, y + 61), fill=GREEN)
    text(draw, (x + 112, y + 41), "On", 19, GREEN)
    rounded(draw, (pop[2] - 132, y + 4, pop[2] - 38, y + 58), 29, BLUE)
    draw.ellipse((pop[2] - 86, y + 8, pop[2] - 42, y + 54), fill=(255, 255, 255))
    ui_panel(draw, (x, y + 96, pop[2] - 34, y + 420), (242, 245, 248))

    text(draw, (x + 28, y + 130), "Volume", 21, DARK)
    small_button(draw, (x + 150, y + 114, x + 212, y + 168), "<")
    rounded(draw, (x + 250, y + 138, x + 550, y + 150), 6, (205, 214, 224))
    rounded(draw, (x + 250, y + 138, x + 325, y + 150), 6, BLUE)
    draw.ellipse((x + 304, y + 119, x + 346, y + 161), fill=(255, 255, 255), outline=(194, 204, 214), width=2)
    small_button(draw, (x + 590, y + 114, x + 652, y + 168), ">")
    text(draw, (x + 400, y + 161), "25%", 20, DARK, anchor="mm")

    text(draw, (x + 28, y + 208), "Sound", 21, DARK)
    small_button(draw, (x + 150, y + 192, x + 212, y + 246), "<")
    rounded(draw, (x + 248, y + 192, x + 550, y + 246), 13, (229, 234, 240))
    text(draw, (x + 400, y + 208), "Creamy-2", 25, DARK, anchor="ma")
    small_button(draw, (x + 590, y + 192, x + 652, y + 246), ">")

    text(draw, (x + 28, y + 286), "Effects", 21, DARK)
    toggle(draw, x + 150, y + 276, "Echo", False)
    toggle(draw, x + 392, y + 276, "Reverb", True)
    toggle(draw, x + 150, y + 338, "Ducking", True)
    small_button(draw, (x, y + 448, x + 132, y + 510), "Preview")
    small_button(draw, (x + 152, y + 448, x + 286, y + 510), "30 min")
    small_button(draw, (x + 496, y + 448, x + 628, y + 510), "Mixer")
    small_button(draw, (x + 648, y + 448, x + 778, y + 510), "Settings")
    text(draw, (x, y + 590), "Ready", 21, MUTED_DARK)
    small_button(draw, (pop[2] - 145, y + 570, pop[2] - 34, y + 624), "Quit")

    callout(img, 170, 970, "1% volume nudges", "Hold the arrow buttons to glide to the exact typing level.", screen.accent, w=520)
    callout(img, 170, 1160, "Quick sound switching", "Preview and move through packs without opening a window.", screen.secondary, w=520)
    keycap_stack(draw, 690, 980, ["Menu bar", "Always ready", "No clutter"], screen.accent)


def draw_diagnostics(img: Image.Image, draw: ImageDraw.ImageDraw, screen: Screen) -> None:
    x1, y1, x2, y2 = draw_app_window(img, "Diagnostics", 640, 620, 2080, 980)
    cx, cy = x1 + 380, y1 + 132
    section_header(draw, cx, cy, "Diagnostics", "Check audio, permission, and typing detection in one place.")
    statuses = [
        ("Audio", "Running", GREEN),
        ("Input Monitoring", "Approved", GREEN),
        ("Keyboard Listener", "Running", GREEN),
        ("Playback State", "Ready", GREEN),
    ]
    for idx, (title, value, color) in enumerate(statuses):
        w = 396
        x = cx + idx * (w + 24)
        y = cy + 126
        ui_panel(draw, (x, y, x + w, y + 150), (248, 251, 253))
        draw.ellipse((x + 28, y + 38, x + 78, y + 88), fill=(229, 248, 238))
        draw.ellipse((x + 46, y + 56, x + 60, y + 70), fill=color)
        text(draw, (x + 96, y + 34), title, 24, DARK)
        text(draw, (x + 96, y + 78), value, 28, color)
    ui_panel(draw, (cx, cy + 326, x2 - 60, cy + 558), (248, 251, 253))
    text(draw, (cx + 32, cy + 360), "Test typing sound", 31, DARK)
    text(draw, (cx + 32, cy + 408), "Type here to confirm the app can hear key events and play local samples.", 23, MUTED_DARK)
    rounded(draw, (cx + 32, cy + 468, x2 - 95, cy + 534), 14, (255, 255, 255), outline=LINE, width=2)
    text(draw, (cx + 58, cy + 490), "The quick brown fox taps Creamy-2...", 24, (120, 130, 142))
    ui_panel(draw, (cx, cy + 590, x2 - 60, y2 - 64), (248, 251, 253))
    text(draw, (cx + 32, cy + 626), "Permission shortcuts", 30, DARK)
    rows = [
        ("Open Input Monitoring", "System Settings shortcut"),
        ("Show App", "Reveal the exact app bundle to add"),
        ("Recheck", "Refresh permission and listener status"),
        ("Restart Keyboard Listener", "Restart event tap without quitting"),
    ]
    for idx, (label, detail) in enumerate(rows):
        y = cy + 692 + idx * 68
        rounded(draw, (cx + 34, y, x2 - 95, y + 50), 14, (235, 240, 245))
        text(draw, (cx + 58, y + 13), label, 22, DARK)
        text(draw, (cx + 390, y + 14), detail, 20, MUTED_DARK)

    callout(img, 176, 1018, "Built-in troubleshooting", "See permission, audio, listener, and event status together.", screen.accent, w=520)
    callout(img, 176, 1208, "Clean QA path", "Open the exact macOS settings page and recheck immediately.", screen.secondary, w=520)


def draw_privacy(img: Image.Image, draw: ImageDraw.ImageDraw, screen: Screen) -> None:
    x1, y1, x2, y2 = draw_app_window(img, "Privacy", 640, 620, 2080, 980)
    cx, cy = x1 + 380, y1 + 132
    section_header(draw, cx, cy, "Privacy", "KeyThock does not know what you typed.")
    ui_panel(draw, (cx, cy + 120, cx + 770, y2 - 64), (248, 251, 253))
    bullets = [
        "No typed text is stored.",
        "No key activity is sent to servers.",
        "No screenshots or clipboard content are read.",
        "No password fields are bypassed.",
        "Keyboard events only select local audio.",
    ]
    for idx, item in enumerate(bullets):
        y = cy + 184 + idx * 92
        draw.ellipse((cx + 42, y + 4, cx + 84, y + 46), fill=(229, 248, 238))
        text(draw, (cx + 63, y + 11), "OK", 18, GREEN, anchor="ma")
        text(draw, (cx + 112, y + 10), item, 28, DARK)

    ui_panel(draw, (cx + 825, cy + 120, x2 - 60, cy + 442), (248, 251, 253))
    text(draw, (cx + 860, cy + 162), "Input Monitoring", 32, DARK)
    for idx, line in enumerate(wrap_text(draw, "macOS asks permission before apps can react to keyboard events in other apps.", 24, 710)):
        text(draw, (cx + 860, cy + 216 + idx * 32), line, 24, MUTED_DARK)
    small_button(draw, (cx + 860, cy + 314, cx + 1194, cy + 374), "Open Settings", True)
    small_button(draw, (cx + 1220, cy + 314, cx + 1465, cy + 374), "Show App")

    ui_panel(draw, (cx + 825, cy + 488, x2 - 60, y2 - 64), (248, 251, 253))
    text(draw, (cx + 860, cy + 530), "Local-only storage", 32, DARK)
    text(draw, (cx + 860, cy + 584), "Settings, sound choices, and imported packs stay on this Mac.", 24, MUTED_DARK)
    rounded(draw, (cx + 930, cy + 692, cx + 1190, cy + 818), 20, (224, 238, 255), outline=(184, 211, 249), width=2)
    text(draw, (cx + 1060, cy + 733), "Keyboard event", 24, DARK, anchor="ma")
    draw.line((cx + 1198, cy + 755, cx + 1340, cy + 755), fill=BLUE, width=6)
    draw.polygon([(cx + 1340, cy + 755), (cx + 1310, cy + 737), (cx + 1310, cy + 773)], fill=BLUE)
    rounded(draw, (cx + 1350, cy + 692, cx + 1605, cy + 818), 20, (229, 248, 238), outline=(184, 226, 204), width=2)
    text(draw, (cx + 1478, cy + 733), "Local sound", 24, DARK, anchor="ma")
    rounded(draw, (cx + 1020, cy + 905, cx + 1510, cy + 978), 18, (238, 242, 246), outline=LINE, width=2)
    text(draw, (cx + 1265, cy + 930), "No server. No account. No tracking.", 25, DARK, anchor="ma")

    callout(img, 176, 1048, "Privacy-forward", "KeyThock listens for timing and key category, not typed content.", screen.accent, w=540)
    callout(img, 176, 1238, "Local by default", "Sounds and settings stay on the Mac unless the user exports them.", screen.secondary, w=540)


def make_contact_sheet(files: Iterable[Path]) -> None:
    thumbs = []
    for path in files:
        thumbs.append((path.name, Image.open(path).resize((576, 360), Image.LANCZOS)))
    sheet = Image.new("RGB", (2 * 576 + 40, 3 * 420 + 60), (246, 248, 250))
    draw = ImageDraw.Draw(sheet)
    for idx, (name, thumb) in enumerate(thumbs):
        x = 20 + (idx % 2) * 596
        y = 20 + (idx // 2) * 420
        sheet.paste(thumb, (x, y))
        text(draw, (x, y + 368), name, 24, DARK)
    sheet.save(OUT / "contact-sheet.png", "PNG", optimize=True)


def main() -> None:
    OUT.mkdir(exist_ok=True)
    screens = [
        Screen(
            "01-sound-packs.png",
            "Make every key sound expensive.",
            "Recorded keyboard packs, instant preview, and one-click switching for creamy, clacky, thocky, typewriter, bubble, and Morse sounds.",
            "Sound Packs",
            BLUE,
            CYAN,
            ((10, 20, 34), (22, 48, 61)),
            draw_sound_packs,
        ),
        Screen(
            "02-keys.png",
            "Tune every key individually.",
            "Pick the exact sample for A, Space, Return, modifiers, and more with a full visual keyboard editor.",
            "Keys",
            GREEN,
            BLUE,
            ((11, 29, 28), (19, 55, 76)),
            draw_keys,
        ),
        Screen(
            "03-mixer.png",
            "Your sound, dialed in seconds.",
            "Presets, pitch, volume, echo, reverb, and auto ducking give every pack a polished feel.",
            "Mixer",
            PURPLE,
            BLUE,
            ((24, 20, 42), (34, 42, 74)),
            draw_mixer,
        ),
        Screen(
            "04-menu-bar.png",
            "Everything important, one click away.",
            "Control volume, sound packs, preview, effects, and quick mute from the Mac menu bar.",
            "Settings",
            CYAN,
            YELLOW,
            ((10, 24, 35), (24, 45, 49)),
            draw_menu_bar,
        ),
        Screen(
            "05-diagnostics.png",
            "No guessing when permissions matter.",
            "Built-in diagnostics show audio, Input Monitoring, listener health, and real typing playback status.",
            "Diagnostics",
            ORANGE,
            GREEN,
            ((30, 24, 19), (50, 38, 34)),
            draw_diagnostics,
        ),
        Screen(
            "06-privacy.png",
            "Typing sound without typing surveillance.",
            "KeyThock plays local sounds from keyboard events and never stores text, screenshots, or clipboard content.",
            "Privacy",
            GREEN,
            BLUE,
            ((13, 25, 29), (17, 43, 55)),
            draw_privacy,
        ),
    ]

    outputs: list[Path] = []
    for screen in screens:
        path = OUT / screen.filename
        draw_canvas(screen).convert("RGB").save(path, "PNG", optimize=True)
        outputs.append(path)
        print(f"{path} 2880x1800")
    make_contact_sheet(outputs)

    readme = OUT / "README.md"
    readme.write_text(
        "# KeyThock App Store Screenshots\n\n"
        "These PNGs are prepared for the Mac App Store screenshot well.\n\n"
        "- Size: `2880 x 1800`\n"
        "- Aspect ratio: `16:10`\n"
        "- Format: PNG\n"
        "- Upload order:\n"
        "  1. `01-sound-packs.png`\n"
        "  2. `02-keys.png`\n"
        "  3. `03-mixer.png`\n"
        "  4. `04-menu-bar.png`\n"
        "  5. `05-diagnostics.png`\n"
        "  6. `06-privacy.png`\n\n"
        "`contact-sheet.png` is only for quick review and should not be uploaded.\n",
        encoding="utf-8",
    )


if __name__ == "__main__":
    main()
