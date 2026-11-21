#!/usr/bin/env python3
"""Draws the alternative Loyalsoldier-GeoIP icon for UniGetUI and renders it to PNG.

Loyalsoldier/geoip has no logo of its own; its README banner (assets/hero.png)
shows a small app-style tile with a globe and a map pin above stacked layers.
Cut out of the banner, that tile is only about 85x107 pixels on a white
background, too small for a sharp 192x192 icon. This is an original vector
drawing on the same idea: a gridded globe with a map pin, resting on two
stacked data layers, in blue. New artwork, not traced from the banner.

Writes, relative to the bucket root:
  icons/loyalsoldier-geoip-alt.svg  the vector icon
  icons/loyalsoldier-geoip-alt.png  its 192x192 render, used for UniGetUI

Needs rsvg-convert (librsvg) on the PATH; on Windows, MSYS2's
mingw-w64-x86_64-librsvg.

Usage:
  python3 scripts/loyalsoldier-geoip/make_icon.py [--size 192]
"""

import argparse
import math
import shutil
import subprocess
import sys
from pathlib import Path

BUCKET_ROOT = Path(__file__).resolve().parents[2]
SVG_PATH = BUCKET_ROOT / "icons" / "loyalsoldier-geoip-alt.svg"
PNG_PATH = BUCKET_ROOT / "icons" / "loyalsoldier-geoip-alt.png"

VIEW = 512  # square viewBox side

COLORS = {
    "slab_top": "#4d94ff",
    "slab_top_upper": "#6aa8ff",
    "slab_left": "#2f6fe0",
    "slab_right": "#1f56c2",
    "globe_light": "#9cc8ff",
    "globe_dark": "#3a82f0",
    "grid": "#ffffff",
    "pin": "#1450c8",
    "pin_halo": "#ffffff",
}

# Layers: isometric slabs (a diamond top face and two side faces).
SLAB_CX = 256
SLAB_HALF_WIDTH = 176
SLAB_HALF_DEPTH = 74
SLAB_THICKNESS = 26
SLAB_CENTERS_Y = (404, 350)  # lower slab first, so the upper one covers it

# Globe resting on the upper slab, with a map pin above its right side.
GLOBE = {"cx": 236, "cy": 214, "r": 120}
PIN = {"cx": 352, "cy": 112, "r": 54, "tip_y": 214, "dot_r": 20}


def slab(cy: float, top_color: str) -> str:
    """Returns one isometric slab: right and left side faces, then the top face."""
    x0, w, h, t = SLAB_CX, SLAB_HALF_WIDTH, SLAB_HALF_DEPTH, SLAB_THICKNESS
    left = f"{x0 - w},{cy} {x0},{cy + h} {x0},{cy + h + t} {x0 - w},{cy + t}"
    right = f"{x0 + w},{cy} {x0},{cy + h} {x0},{cy + h + t} {x0 + w},{cy + t}"
    top = f"{x0},{cy - h} {x0 + w},{cy} {x0},{cy + h} {x0 - w},{cy}"
    return (
        f'  <polygon points="{left}" fill="{COLORS["slab_left"]}"/>\n'
        f'  <polygon points="{right}" fill="{COLORS["slab_right"]}"/>\n'
        f'  <polygon points="{top}" fill="{top_color}"/>\n'
    )


def globe() -> str:
    """Returns the globe: a shaded disc with two meridians and three parallels."""
    cx, cy, r = GLOBE["cx"], GLOBE["cy"], GLOBE["r"]
    grid = []
    # Meridians: the central one as a line, two more as ellipses.
    grid.append(f'<line x1="{cx}" y1="{cy - r}" x2="{cx}" y2="{cy + r}"/>')
    for rx in (r * 0.42, r * 0.8):
        grid.append(f'<ellipse cx="{cx}" cy="{cy}" rx="{rx:.1f}" ry="{r}"/>')
    # Parallels: chords of the circle at the equator and at +-45% of the radius.
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
        f'      <stop offset="0" stop-color="{COLORS["globe_light"]}"/>\n'
        f'      <stop offset="1" stop-color="{COLORS["globe_dark"]}"/>\n'
        "    </linearGradient>\n"
        f'    <clipPath id="disc"><circle cx="{cx}" cy="{cy}" r="{r}"/></clipPath>\n'
        "  </defs>\n"
        f'  <circle cx="{cx}" cy="{cy}" r="{r}" fill="url(#globe)"/>\n'
        f'  <g clip-path="url(#disc)" fill="none" stroke="{COLORS["grid"]}" '
        'stroke-opacity="0.6" stroke-width="7">\n'
        f"{lines}\n"
        "  </g>\n"
    )


def pin() -> str:
    """Returns the map pin: a teardrop with a white halo and a white dot."""
    cx, cy, r, tip = PIN["cx"], PIN["cy"], PIN["r"], PIN["tip_y"]
    # Two curves from the tip up to the sides of the head, closed over the top.
    shape = (
        f"M{cx},{tip} "
        f"C{cx - r * 0.45:.1f},{cy + r * 1.1:.1f} {cx - r},{cy + r * 0.6:.1f} {cx - r},{cy} "
        f"A{r},{r} 0 1 1 {cx + r},{cy} "
        f"C{cx + r},{cy + r * 0.6:.1f} {cx + r * 0.45:.1f},{cy + r * 1.1:.1f} {cx},{tip} Z"
    )
    return (
        f'  <path d="{shape}" fill="{COLORS["pin"]}" stroke="{COLORS["pin_halo"]}" '
        'stroke-width="12" stroke-linejoin="round" paint-order="stroke"/>\n'
        f'  <circle cx="{cx}" cy="{cy}" r="{PIN["dot_r"]}" fill="{COLORS["pin_halo"]}"/>\n'
    )


def build_svg() -> str:
    """Returns the whole icon as an SVG document."""
    lower_cy, upper_cy = SLAB_CENTERS_Y
    return (
        f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {VIEW} {VIEW}">\n'
        "  <!-- Loyalsoldier-GeoIP icon for the gesu Scoop bucket: original drawing,\n"
        "       written by scripts/loyalsoldier-geoip/make_icon.py. -->\n"
        + slab(lower_cy, COLORS["slab_top"])
        + slab(upper_cy, COLORS["slab_top_upper"])
        + globe()
        + pin()
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

    SVG_PATH.write_text(build_svg(), encoding="utf-8", newline="\n")
    render_png(SVG_PATH, PNG_PATH, args.size)
    print(f"Wrote {SVG_PATH.relative_to(BUCKET_ROOT)} and {PNG_PATH.relative_to(BUCKET_ROOT)}")


if __name__ == "__main__":
    main()
