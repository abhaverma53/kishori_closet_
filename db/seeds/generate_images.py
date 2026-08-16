#!/usr/bin/env python3
from PIL import Image, ImageDraw, ImageFont
from pathlib import Path

OUT = Path(__file__).resolve().parent / "images"
OUT.mkdir(parents=True, exist_ok=True)

PRODUCTS = [
    ("floral-coord", [(250, 120, 150), (255, 214, 220)], "Floral Co-ord"),
    ("rose-dress", [(168, 50, 80), (240, 180, 190)], "Rose Dress"),
    ("wrap-top", [(40, 40, 55), (180, 160, 170)], "Wrap Top"),
    ("ivory-palazzo", [(236, 224, 208), (190, 160, 130)], "Ivory Set"),
    ("blush-kurta", [(232, 180, 190), (190, 90, 120)], "Blush Kurta"),
    ("pearl-earrings", [(250, 245, 240), (201, 162, 39)], "Pearl Drops"),
    ("sage-shirt", [(140, 160, 140), (220, 230, 220)], "Sage Shirt"),
    ("burgundy-anarkali", [(90, 20, 40), (160, 50, 70)], "Anarkali"),
    ("cream-midi", [(245, 235, 220), (200, 170, 140)], "Cream Midi"),
    ("gold-necklace", [(30, 30, 46), (201, 162, 39)], "Gold Hoops"),
]


def gradient(size, c1, c2):
    img = Image.new("RGB", size, c1)
    draw = ImageDraw.Draw(img)
    w, h = size
    for y in range(h):
        ratio = y / max(h - 1, 1)
        color = tuple(int(c1[i] + (c2[i] - c1[i]) * ratio) for i in range(3))
        draw.line([(0, y), (w, y)], fill=color)
    return img


def add_label(img, text):
    draw = ImageDraw.Draw(img)
    w, h = img.size
    try:
        font = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSerif.ttf", 42)
        small = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf", 18)
    except OSError:
        font = ImageFont.load_default()
        small = font
    draw.rectangle([40, h - 160, w - 40, h - 60], fill=(255, 255, 255, 180))
    draw.text((60, h - 145), text, fill=(26, 26, 46), font=font)
    draw.text((60, h - 95), "KISHORI CLOSET", fill=(194, 24, 91), font=small)
    return img


def main():
    for slug, colors, label in PRODUCTS:
        for idx in range(2):
            c1, c2 = colors if idx == 0 else list(reversed(colors))
            img = gradient((900, 1200), tuple(c1), tuple(c2))
            draw = ImageDraw.Draw(img)
            draw.ellipse([180, 180, 720, 900], outline=(255, 255, 255), width=3)
            img = add_label(img, label)
            path = OUT / f"{slug}-{idx + 1}.jpg"
            img.save(path, quality=88)
            print(path)


if __name__ == "__main__":
    main()
