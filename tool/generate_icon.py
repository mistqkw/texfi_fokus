#!/usr/bin/env python3
"""Генератор иконки TexFi f0kus.

Иконка рисуется программно, пиксель за пикселем, а не берётся готовым
изображением: так она гарантированно консистентна со стилистикой приложения
и её легко пересобрать в любом размере без размытия.

Мотив — песочные часы: самый прямой символ сфокусированного отрезка времени,
и при этом он хорошо читается в 16×16, где глаз или мишень превращаются в
кашу. Палитра — фирменная: синий #4A7DFB на почти чёрном фоне.

Всё масштабирование идёт методом NEAREST — любая интерполяция превратила бы
пиксель-арт в мыло.

Запуск:  python3 tool/generate_icon.py
"""

from __future__ import annotations

import os
import struct
import zlib

from PIL import Image

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
ICON_DIR = os.path.join(ROOT, "assets", "icon")
LINUX_DIR = os.path.join(ICON_DIR, "linux")

# Палитра
BG = (11, 11, 14, 255)          # #0B0B0E — фон тёмной темы
BLUE = (74, 125, 251, 255)      # #4A7DFB — фирменный акцент
BLUE_DEEP = (43, 79, 176, 255)  # #2B4FB0 — тень/объём
BLUE_LIGHT = (143, 176, 255, 255)
SAND = (255, 251, 243, 255)     # «песок» — тёплый белый
EMPTY = (0, 0, 0, 0)

# Сетка 16×16: крупные пиксели, читаемые даже в трее.
#   . — прозрачно
#   # — синий (корпус)
#   D — тёмно-синий (тень корпуса)
#   L — светло-синий (блик)
#   o — песок
GRID = [
    "................",
    "..############..",
    "..#DDDDDDDDDD#..",
    "..#Loooooooo.#..",
    "...#oooooooo#...",
    "....#oooooo#....",
    ".....#oooo#.....",
    "......#oo#......",
    "......#oo#......",
    ".....#o..o#.....",
    "....#oo..oo#....",
    "...#oooooooo#...",
    "..#Loooooooo.#..",
    "..#DDDDDDDDDD#..",
    "..############..",
    "................",
]

COLORS = {
    "#": BLUE,
    "D": BLUE_DEEP,
    "L": BLUE_LIGHT,
    "o": SAND,
    ".": EMPTY,
}


def build_grid() -> Image.Image:
    """Рисует базовую сетку 16×16 с прозрачным фоном."""
    size = len(GRID)
    image = Image.new("RGBA", (size, size), EMPTY)
    pixels = image.load()
    for y, row in enumerate(GRID):
        for x, char in enumerate(row):
            pixels[x, y] = COLORS.get(char, EMPTY)
    return image


def scale(image: Image.Image, size: int) -> Image.Image:
    """Увеличение строго по пикселям — без сглаживания."""
    return image.resize((size, size), Image.NEAREST)


def master(size: int = 1024) -> Image.Image:
    """Мастер-иконка: спрайт на фирменном тёмном фоне, с полями.

    Поля обязательны: иконка без воздуха выглядит распухшей в лаунчере,
    а на iOS/macOS её ещё и обрежет скруглением.
    """
    canvas = Image.new("RGBA", (size, size), BG)
    sprite_size = int(size * 0.75)
    sprite_size -= sprite_size % len(GRID)  # кратно сетке — иначе рябь
    sprite = scale(build_grid(), sprite_size)
    offset = (size - sprite_size) // 2
    canvas.alpha_composite(sprite, (offset, offset))
    return canvas


def foreground(size: int = 1024) -> Image.Image:
    """Слой foreground для адаптивной иконки Android.

    Android обрезает адаптивную иконку маской и оставляет видимой примерно
    центральную треть, поэтому спрайт здесь заметно меньше, чем в мастере,
    и фон прозрачный — его подставит adaptive_icon_background.
    """
    canvas = Image.new("RGBA", (size, size), EMPTY)
    sprite_size = int(size * 0.46)
    sprite_size -= sprite_size % len(GRID)
    sprite = scale(build_grid(), sprite_size)
    offset = (size - sprite_size) // 2
    canvas.alpha_composite(sprite, (offset, offset))
    return canvas


def round_icon(size: int = 1024) -> Image.Image:
    """Круглая версия для лаунчеров, которые просят её отдельно."""
    base = master(size)
    mask = Image.new("L", (size, size), 0)
    # Рисуем круг «пиксельно», по строкам: сглаженный край чужероден стилю.
    pixels = mask.load()
    radius = size / 2
    for y in range(size):
        dy = y - radius + 0.5
        half = int((radius * radius - dy * dy) ** 0.5) if abs(dy) < radius else 0
        for x in range(int(radius - half), int(radius + half)):
            pixels[x, y] = 255
    result = Image.new("RGBA", (size, size), EMPTY)
    result.paste(base, (0, 0), mask)
    return result


def write_ico(image: Image.Image, path: str, sizes=(16, 32, 48, 256)) -> None:
    """Пишет .ico с несколькими встроенными размерами.

    Формат собирается вручную, а не через Pillow `save(format="ICO")`:
    Pillow пересэмплирует слои по-своему, а нам нужно, чтобы каждый размер
    был получен именно NEAREST-масштабированием из сетки.
    """
    entries = []
    for size in sizes:
        frame = scale(image, size) if image.width != size else image
        raw = frame.tobytes()
        # PNG-поток внутри ICO — допустимо начиная с Vista и компактнее BMP.
        png = _encode_png(frame.width, frame.height, raw)
        entries.append((size, png))

    with open(path, "wb") as handle:
        handle.write(struct.pack("<HHH", 0, 1, len(entries)))
        offset = 6 + 16 * len(entries)
        for size, png in entries:
            # 256 записывается как 0 — так устроен формат.
            dimension = 0 if size >= 256 else size
            handle.write(
                struct.pack(
                    "<BBBBHHII",
                    dimension, dimension, 0, 0, 1, 32, len(png), offset,
                )
            )
            offset += len(png)
        for _, png in entries:
            handle.write(png)


def _encode_png(width: int, height: int, rgba: bytes) -> bytes:
    """Минимальный кодировщик PNG для вложения в .ico."""
    raw = b"".join(
        b"\x00" + rgba[y * width * 4:(y + 1) * width * 4] for y in range(height)
    )

    def chunk(tag: bytes, data: bytes) -> bytes:
        return (
            struct.pack(">I", len(data))
            + tag
            + data
            + struct.pack(">I", zlib.crc32(tag + data) & 0xFFFFFFFF)
        )

    return (
        b"\x89PNG\r\n\x1a\n"
        + chunk(b"IHDR", struct.pack(">IIBBBBB", width, height, 8, 6, 0, 0, 0))
        + chunk(b"IDAT", zlib.compress(raw, 9))
        + chunk(b"IEND", b"")
    )


def main() -> None:
    os.makedirs(ICON_DIR, exist_ok=True)
    os.makedirs(LINUX_DIR, exist_ok=True)

    master_icon = master(1024)
    master_icon.save(os.path.join(ICON_DIR, "app_icon.png"))
    foreground(1024).save(os.path.join(ICON_DIR, "app_icon_foreground.png"))
    round_icon(1024).save(os.path.join(ICON_DIR, "app_icon_round.png"))

    # Linux: набор PNG для .desktop-интеграции.
    for size in (16, 32, 64, 128, 256, 512):
        scale(master_icon, size).save(
            os.path.join(LINUX_DIR, f"texfi-fokus-{size}.png")
        )

    # Windows: многоразмерный .ico.
    write_ico(master_icon, os.path.join(ICON_DIR, "app_icon.ico"))

    print(f"icons written to {ICON_DIR}")


if __name__ == "__main__":
    main()
