#!/usr/bin/env python3
"""Draws the mtg-multi icon for UniGetUI and renders it to PNG.

mtg-multi has no logo of its own, and Telegram's paper plane is Telegram's
trademark, so this is an original drawing of what the program does: one proxy
(a hub with a keyhole, for the FakeTLS secret) shared by several users (three
nodes linked to the hub), on a rounded dark-blue tile.

Writes, relative to the bucket root:
  icons/mtg-multi-alt.svg  the vector icon
  icons/mtg-multi-alt.png  its 192x192 render, used for UniGetUI

Needs rsvg-convert (librsvg) on the PATH; on Windows, MSYS2's
mingw-w64-x86_64-librsvg.

Usage:
  python3 scripts/mtg-multi/make_icon.py [--size 192]
"""

import argparse
import math
import shutil
import subprocess
import sys
from pathlib import Path

BUCKET_ROOT = Path(__file__).resolve().parents[2]
SVG_PATH = BUCKET_ROOT / "icons" / "mtg-multi-alt.svg"
PNG_PATH = BUCKET_ROOT / "icons" / "mtg-multi-alt.png"

VIEW = 512  # square viewBox side

COLORS = {
    "tile_top": "#24415f",
    "tile_bottom": "#132538",
    "link": "#7fb8ff",
    "hub": "#2f8cff",
    "hub_ring": "#ffffff",
    "keyhole": "#ffffff",
    "user": "#ffffff",
    "user_ring": "#7fb8ff",
}

TILE = {"margin": 24, "rx": 96}
HUB = {"cx": 256, "cy": 268, "r": 82}
USERS = {"distance": 160, "r": 44, "angles": (-90, 30, 150)}  # degrees, clockwise from east


def tile() -> str:
    """Returns the rounded background tile with a vertical gradient."""
    m, rx = TILE["margin"], TILE["rx"]
    side = VIEW - 2 * m
    return (
        "  <defs>\n"
        '    <linearGradient id="tile" x1="0" y1="0" x2="0" y2="1">\n'
        f'      <stop offset="0" stop-color="{COLORS["tile_top"]}"/>\n'
        f'      <stop offset="1" stop-color="{COLORS["tile_bottom"]}"/>\n'
        "    </linearGradient>\n"
        "  </defs>\n"
        f'  <rect x="{m}" y="{m}" width="{side}" height="{side}" rx="{rx}" fill="url(#tile)"/>\n'
    )


def user_centers() -> list:
    """Returns the centres of the user nodes around the hub."""
    cx, cy, d = HUB["cx"], HUB["cy"], USERS["distance"]
    return [
        (cx + d * math.cos(math.radians(a)), cy + d * math.sin(math.radians(a)))
        for a in USERS["angles"]
    ]


def links() -> str:
    """Returns the lines from the hub to each user."""
    cx, cy = HUB["cx"], HUB["cy"]
    lines = "\n".join(
        f'    <line x1="{cx}" y1="{cy}" x2="{x:.1f}" y2="{y:.1f}"/>' for x, y in user_centers()
    )
    return (
        f'  <g stroke="{COLORS["link"]}" stroke-width="16" stroke-linecap="round">\n'
        f"{lines}\n"
        "  </g>\n"
    )


def users() -> str:
    """Returns the user nodes: white discs with a light-blue ring."""
    r = USERS["r"]
    return "".join(
        f'  <circle cx="{x:.1f}" cy="{y:.1f}" r="{r}" fill="{COLORS["user"]}" '
        f'stroke="{COLORS["user_ring"]}" stroke-width="10"/>\n'
        for x, y in user_centers()
    )


def hub() -> str:
    """Returns the hub: a blue disc with a white ring and a keyhole."""
    cx, cy, r = HUB["cx"], HUB["cy"], HUB["r"]
    # Keyhole: a round head above a tapering slot.
    head_r, slot_top, slot_bottom = 22, cy - 2, cy + 44
    keyhole = (
        f"M{cx - 10},{slot_top} L{cx - 18},{slot_bottom} H{cx + 18} L{cx + 10},{slot_top} Z"
    )
    return (
        f'  <circle cx="{cx}" cy="{cy}" r="{r}" fill="{COLORS["hub"]}" '
        f'stroke="{COLORS["hub_ring"]}" stroke-width="12"/>\n'
        f'  <circle cx="{cx}" cy="{cy - 16}" r="{head_r}" fill="{COLORS["keyhole"]}"/>\n'
        f'  <path d="{keyhole}" fill="{COLORS["keyhole"]}"/>\n'
    )


def build_svg() -> str:
    """Returns the whole icon as an SVG document."""
    return (
        f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {VIEW} {VIEW}">\n'
        "  <!-- mtg-multi icon for the gesu Scoop bucket: original drawing,\n"
        "       written by scripts/mtg-multi/make_icon.py. -->\n"
        + tile()
        + links()
        + users()
        + hub()
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
