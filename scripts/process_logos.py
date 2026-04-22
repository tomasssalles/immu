# /// script
# dependencies = ["pillow"]
# ///

from pathlib import Path
from PIL import Image

ASSETS = Path(__file__).parent.parent / "assets"
SOURCES = [
    {"name": "logo-full-body-light.full-size.png",  "bg_lower": 10, "bg_upper": 200},
    {"name": "logo-head-light.full-size.png", "bg_lower": 20, "bg_upper": 200},
]

MARGIN_FRACTION = 0.05  # margin around content as a fraction of the larger dimension
DARK_FLOOR = 90        # darkest grey allowed in the dark variant (0=black, 255=white)


def remove_background(img: Image.Image, bg_lower: int, bg_upper: int) -> Image.Image:
    """Remove the background by measuring each pixel's distance from pure white.

    - dist <= bg_lower: fully transparent (background)
    - dist >= bg_upper: fully opaque (logo)
    - in between: linearly interpolated alpha for a soft edge
    """
    img = img.convert("RGBA")
    pixels = img.load()
    w, h = img.size

    for y in range(h):
        for x in range(w):
            r, g, b, a = pixels[x, y]
            dist = 255 - r  # red deficit: low for near-white background, high for teal
            if dist <= bg_lower:
                pixels[x, y] = (r, g, b, 0)
            elif dist < bg_upper:
                t = (dist - bg_lower) / (bg_upper - bg_lower)
                # Un-premultiply the white out of the RGB: the edge pixel is a
                # blend of foreground * t + white * (1-t), so we recover the
                # foreground colour to avoid a white fringe when composited.
                def unmix(c: int) -> int:
                    return min(255, max(0, round((c - 255 * (1 - t)) / t)))
                pixels[x, y] = (unmix(r), unmix(g), unmix(b), round(t * 255))

    return img


def crop_square_with_margin(img: Image.Image) -> Image.Image:
    """Crop to a square that fits around the opaque content with a small margin."""
    alpha = img.split()[3]
    bbox = alpha.point(lambda a: 255 if a >= 128 else 0).getbbox()
    if bbox is None:
        return img

    left, upper, right, lower = bbox
    side = max(right - left, lower - upper)
    margin = int(side * MARGIN_FRACTION)
    side += 2 * margin

    cx = (left + right) // 2
    cy = (upper + lower) // 2
    new_left = cx - side // 2
    new_upper = cy - side // 2

    # Paste onto a transparent canvas (handles cases where margin exceeds image bounds)
    canvas = Image.new("RGBA", (side, side), (0, 0, 0, 0))
    src_l = max(new_left, 0)
    src_u = max(new_upper, 0)
    src_r = min(new_left + side, img.width)
    src_b = min(new_upper + side, img.height)
    canvas.paste(img.crop((src_l, src_u, src_r, src_b)), (src_l - new_left, src_u - new_upper))
    return canvas


def to_dark_variant(img: Image.Image) -> Image.Image:
    """Map each pixel's luminosity to a light shade of grey, preserving transparency.

    Remaps luminosity from [0, 255] to [DARK_FLOOR, 255] so the darkest logo
    elements become light grey rather than near-black, making the logo legible
    on a dark background.
    """
    r, g, b, a = img.split()
    gray = Image.merge("RGB", (r, g, b)).convert("L")
    gray = gray.point(lambda L: DARK_FLOOR + L * (255 - DARK_FLOOR) // 255)
    return Image.merge("RGBA", (gray, gray, gray, a))


def debug_mask(img: Image.Image, bg_lower: int, bg_upper: int) -> Image.Image:
    """Diagnostic image: paints the soft-transition zone orange to show its extent."""
    img = img.convert("RGBA")
    pixels = img.load()
    w, h = img.size
    out = img.copy()
    out_pixels = out.load()

    for y in range(h):
        for x in range(w):
            r, g, b, a = pixels[x, y]
            dist = 255 - r  # red deficit: low for near-white background, high for teal
            if bg_lower < dist < bg_upper:
                out_pixels[x, y] = (255, 165, 0, 255)  # orange

    return out


def process(name: str, bg_lower: int, bg_upper: int):
    stem = name.replace(".full-size.png", "")
    print(f"Processing {name}...")

    img = Image.open(ASSETS / name)
    debug = debug_mask(img, bg_lower, bg_upper)
    debug.save(ASSETS / f"{stem}.debug.png")
    print(f"  -> {stem}.debug.png")
    img = remove_background(img, bg_lower, bg_upper)
    img = crop_square_with_margin(img)

    img.save(ASSETS / f"{stem}.png")
    print(f"  -> {stem}.png")

    dark = to_dark_variant(img)
    dark.save(ASSETS / f"{stem.replace('-light', '-dark')}.png")
    print(f"  -> {stem.replace('-light', '-dark')}.png")


for source in SOURCES:
    process(**source)