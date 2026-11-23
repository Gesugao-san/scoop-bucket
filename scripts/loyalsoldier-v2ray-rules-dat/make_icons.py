#!/usr/bin/env python3
"""Draws the icons of the three v2ray-rules-dat packages for UniGetUI and renders them to PNG.

None of the three projects has a square logo: Loyalsoldier/v2ray-rules-dat and
runetfreedom/russia-v2ray-rules-dat have none at all, and Chocolate4U/Iran-v2ray-rules
has a wide wordmark. These are original vector drawings in the style of the
Loyalsoldier-GeoIP icon (scripts/loyalsoldier-geoip/make_icon.py): a gridded globe
resting on three stacked data layers, with a rules sheet (a page with lines) where
that icon has its map pin. The layers tell the packages apart:

  Loyalsoldier-v2ray-rules-dat         three green layers
  Chocolate4U-Iran-v2ray-rules         green, white and red, top to bottom
  runetfreedom-russia-v2ray-rules-dat  white, blue and red, top to bottom

Writes, relative to the bucket root, for each package's app ID:
  icons/<app-id>-alt.svg  the vector icon
  icons/<app-id>-alt.png  its 192x192 render, used for UniGetUI

Needs rsvg-convert (librsvg) on the PATH; on Windows, MSYS2's
mingw-w64-x86_64-librsvg.

Usage:
  python3 scripts/loyalsoldier-v2ray-rules-dat/make_icons.py [--size 192]
"""

import argparse
import math
import shutil
import subprocess
import sys
from pathlib import Path

BUCKET_ROOT = Path(__file__).resolve().parents[2]
ICONS_DIR = BUCKET_ROOT / "icons"

VIEW = 512  # square viewBox side

# Each layer: top face, left face, right face (the sides are darker, as if lit from above).
GREEN_LAYERS = (
    ("#5ccf8a", "#2f9c5c", "#237a47"),
    ("#46bd76", "#2a8f53", "#1f6f40"),
    ("#33a862", "#25804a", "#1a6339"),
)

PACKAGES = {
    "loyalsoldier-v2ray-rules-dat": {
        "title": "Loyalsoldier-v2ray-rules-dat",
        "layers": GREEN_LAYERS,
    },
    "chocolate4u-iran-v2ray-rules": {
        "title": "Chocolate4U-Iran-v2ray-rules",
        "layers": (
            ("#2fa35a", "#21804a", "#19663a"),  # green
            ("#f4f4f2", "#c9c9c4", "#a9a9a3"),  # white
            ("#e0353b", "#b0262b", "#8c1d21"),  # red
        ),
    },
    "runetfreedom-russia-v2ray-rules-dat": {
        "title": "runetfreedom-russia-v2ray-rules-dat",
        "layers": (
            ("#f4f4f2", "#c9c9c4", "#a9a9a3"),  # white
            ("#2f6fd6", "#2357ad", "#1b448a"),  # blue
            ("#e0353b", "#b0262b", "#8c1d21"),  # red
        ),
    },
}

GLOBE_COLORS = {"light": "#9cc8ff", "dark": "#3a82f0", "grid": "#ffffff"}
SHEET_COLORS = {"paper": "#ffffff", "edge": "#1d3557", "lines": "#3a82f0"}

# Layers: isometric slabs (a diamond top face and two side faces), lowest first.
SLAB_CX = 256
SLAB_HALF_WIDTH = 176
SLAB_HALF_DEPTH = 70
SLAB_THICKNESS = 22
SLAB_CENTERS_Y = (418, 372, 326)  # bottom, middle, top: each covers the one below

# Globe resting on the top layer, with the rules sheet in front of its right side.
GLOBE = {"cx": 230, "cy": 196, "r": 116}
SHEET = {"x": 300, "y": 62, "w": 128, "h": 160, "fold": 34, "rx": 12}


def slab(cy: float, colors: tuple) -> str:
    """Returns one isometric slab: left and right side faces, then the top face."""
    top_color, left_color, right_color = colors
    x0, w, h, t = SLAB_CX, SLAB_HALF_WIDTH, SLAB_HALF_DEPTH, SLAB_THICKNESS
    left = f"{x0 - w},{cy} {x0},{cy + h} {x0},{cy + h + t} {x0 - w},{cy + t}"
    right = f"{x0 + w},{cy} {x0},{cy + h} {x0},{cy + h + t} {x0 + w},{cy + t}"
    top = f"{x0},{cy - h} {x0 + w},{cy} {x0},{cy + h} {x0 - w},{cy}"
    return (
        f'  <polygon points="{left}" fill="{left_color}"/>\n'
        f'  <polygon points="{right}" fill="{right_color}"/>\n'
        f'  <polygon points="{top}" fill="{top_color}"/>\n'
    )


def globe() -> str:
    """Returns the globe: a shaded disc with two meridians and three parallels."""
    cx, cy, r = GLOBE["cx"], GLOBE["cy"], GLOBE["r"]
    grid = [f'<line x1="{cx}" y1="{cy - r}" x2="{cx}" y2="{cy + r}"/>']
    for rx in (r * 0.42, r * 0.8):
        grid.append(f'<ellipse cx="{cx}" cy="{cy}" rx="{rx:.1f}" ry="{r}"/>')
    for dy in (-0.45 * r, 0.0, 0.45 * r):
        half = math.sqrt(r * r - dy * dy)
        grid.append(
            f'<line x1="{cx - half:.1f}" y1="{cy + dy:.1f}" '
            f'x2="{cx + half:.1f}" y2="{cy + dy:.1f}"/>'
        )
    lines = "\n".join(f"    {g}" for g in grid)
    return (
        "  <defs>\n"
        '    <linearGradient id="globe" x1="0" y1="0" x2="1" y2="1">\n'
        f'      <stop offset="0" stop-color="{GLOBE_COLORS["light"]}"/>\n'
        f'      <stop offset="1" stop-color="{GLOBE_COLORS["dark"]}"/>\n'
        "    </linearGradient>\n"
        f'    <clipPath id="disc"><circle cx="{cx}" cy="{cy}" r="{r}"/></clipPath>\n'
        "  </defs>\n"
        f'  <circle cx="{cx}" cy="{cy}" r="{r}" fill="url(#globe)"/>\n'
        f'  <g clip-path="url(#disc)" fill="none" stroke="{GLOBE_COLORS["grid"]}" '
        'stroke-opacity="0.6" stroke-width="7">\n'
        f"{lines}\n"
        "  </g>\n"
    )


def rules_sheet() -> str:
    """Returns the rules sheet: a page with a folded corner and four lines of 'rules'."""
    x, y, w, h, f, rx = (SHEET[k] for k in ("x", "y", "w", "h", "fold", "rx"))
    # Outline clockwise from the top-left corner; the top-right corner is folded.
    page = (
        f"M{x + rx},{y} H{x + w - f} L{x + w},{y + f} V{y + h - rx} "
        f"Q{x + w},{y + h} {x + w - rx},{y + h} H{x + rx} "
        f"Q{x},{y + h} {x},{y + h - rx} V{y + rx} Q{x},{y} {x + rx},{y} Z"
    )
    fold = f"M{x + w - f},{y} V{y + f} H{x + w}"
    rows = []
    for i, length in enumerate((0.62, 0.74, 0.5, 0.68)):
        ly = y + 58 + i * 26
        rows.append(
            f'    <line x1="{x + 22}" y1="{ly}" x2="{x + 22 + (w - 44) * length:.1f}" y2="{ly}"/>'
        )
    return (
        f'  <path d="{page}" fill="{SHEET_COLORS["paper"]}" stroke="{SHEET_COLORS["edge"]}" '
        'stroke-width="10" stroke-linejoin="round"/>\n'
        f'  <path d="{fold}" fill="none" stroke="{SHEET_COLORS["edge"]}" '
        'stroke-width="10" stroke-linejoin="round"/>\n'
        f'  <g stroke="{SHEET_COLORS["lines"]}" stroke-width="12" stroke-linecap="round">\n'
        + "\n".join(rows)
        + "\n  </g>\n"
    )


def build_svg(app_id: str) -> str:
    """Returns the icon of one package as an SVG document."""
    package = PACKAGES[app_id]
    bottom, middle, top = package["layers"][2], package["layers"][1], package["layers"][0]
    lower_cy, middle_cy, upper_cy = SLAB_CENTERS_Y
    return (
        f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {VIEW} {VIEW}">\n'
        f"  <!-- {package['title']} icon for the gesu Scoop bucket: original drawing,\n"
        "       written by scripts/loyalsoldier-v2ray-rules-dat/make_icons.py. -->\n"
        + slab(lower_cy, bottom)
        + slab(middle_cy, middle)
        + slab(upper_cy, top)
        + globe()
        + rules_sheet()
        + "</svg>\n"
    )


def render_png(svg_path: Path, png_path: Path, size: int) -> None:
    """Renders the SVG to a square PNG with rsvg-convert."""
    renderer = shutil.which("rsvg-convert")
    if not renderer:
        sys.exit("rsvg-convert not found: install librsvg to render the PNG.")
    subprocess.run(
        [renderer, "-w", str(size), "-h", str(size), str(svg_path), "-o", str(png_path)],
        check=True,
    )


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("--size", type=int, default=192, help="PNG side in pixels")
    args = parser.parse_args()

    for app_id in PACKAGES:
        svg_path = ICONS_DIR / f"{app_id}-alt.svg"
        png_path = ICONS_DIR / f"{app_id}-alt.png"
        svg_path.write_text(build_svg(app_id), encoding="utf-8", newline="\n")
        render_png(svg_path, png_path, args.size)
        print(f"Wrote {svg_path.relative_to(BUCKET_ROOT)} and {png_path.relative_to(BUCKET_ROOT)}")


if __name__ == "__main__":
    main()
