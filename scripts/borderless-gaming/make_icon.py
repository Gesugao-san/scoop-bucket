#!/usr/bin/env python3
"""Draws the alternative Borderless Gaming icon for UniGetUI and renders it to PNG.

An original vector redraw in the spirit of the upstream 64x64 icon
(BorderlessGaming_new.ico): bold teal "BG" letters between four corner brackets
on a dark blue gradient tile. Same idea and palette, new artwork.

The letters are the "B" and "G" outlines of Carlito Bold (SIL OFL 1.1, a free
font metrically compatible with Calibri, which the upstream icon appears to use),
thickened by a thin outline in the same colour to match the upstream weight.
They are written into the SVG as plain paths, so the SVG needs no font to render.

Writes, relative to the bucket root:
  icons/borderless-gaming-alt.svg  the vector icon
  icons/borderless-gaming-alt.png  its 192x192 render, used for UniGetUI

Needs:
  fontTools (pip install fonttools)
  rsvg-convert (librsvg) on the PATH; on Windows, MSYS2's mingw-w64-x86_64-librsvg
  Carlito-Bold.ttf: found in the usual font folders, or given with --font;
    otherwise downloaded once from the google/fonts repository.

Usage:
  python3 scripts/borderless-gaming/make_icon.py [--font PATH] [--size 192]
"""

import argparse
import shutil
import subprocess
import sys
import tempfile
import urllib.request
from pathlib import Path

from fontTools.pens.boundsPen import BoundsPen
from fontTools.pens.svgPathPen import SVGPathPen
from fontTools.pens.transformPen import TransformPen
from fontTools.ttLib import TTFont

BUCKET_ROOT = Path(__file__).resolve().parents[2]
SVG_PATH = BUCKET_ROOT / "icons" / "borderless-gaming-alt.svg"
PNG_PATH = BUCKET_ROOT / "icons" / "borderless-gaming-alt.png"

FONT_NAME = "Carlito-Bold.ttf"
FONT_URL = "https://raw.githubusercontent.com/google/fonts/main/ofl/carlito/Carlito-Bold.ttf"
FONT_FOLDERS = [
    Path("/usr/share/fonts/truetype/crosextra"),
    Path("/usr/share/fonts/truetype/carlito"),
    Path("/usr/share/fonts/carlito"),
    Path.home() / ".local/share/fonts",
    Path.home() / "AppData/Local/Microsoft/Windows/Fonts",
    Path("C:/Windows/Fonts"),
]

# Palette sampled from the upstream icon.
COLORS = {
    "tile_top": "#0D1029",
    "tile_bottom": "#1D2587",
    "letters": "#1FFFBB",
    "bracket_left": "#1BCE9E",
    "bracket_right": "#21A9C0",
}

BRACKET_STROKE = 14

# Corner brackets: centre lines, so the outer edge sits BRACKET_STROKE / 2 further out.
BRACKETS = [
    "M13 36V13H36",
    "M156 13H179V36",
    "M13 156V179H36",
    "M156 179H179V156",
]

# Letter layout, in viewBox units (192x192), measured on the upstream icon:
# cap height from y=60 to y=132, the pair from x=36 to x=162.
CAP_TOP, CAP_BOTTOM = 60, 132
PAIR_LEFT, PAIR_RIGHT = 36, 162
LETTER_GAP = 11
# Extra weight: an outline of this width in the letter colour (half of it grows outwards,
# so the layout box above is shrunk by half of it to keep the outer bounds).
LETTER_OUTLINE = 1.5


def find_font(explicit: Path | None) -> Path:
    """Returns a path to Carlito Bold: the given one, an installed copy, or a download."""
    if explicit:
        if not explicit.is_file():
            sys.exit(f"Font not found: {explicit}")
        return explicit
    for folder in FONT_FOLDERS:
        candidate = folder / FONT_NAME
        if candidate.is_file():
            return candidate
    target = Path(tempfile.gettempdir()) / FONT_NAME
    if not target.is_file():
        print(f"Downloading {FONT_NAME} from google/fonts")
        urllib.request.urlretrieve(FONT_URL, target)
    return target


def letter_paths(font_path: Path) -> str:
    """Returns the SVG path data of "B" and "G", scaled and placed on the icon."""
    font = TTFont(font_path)
    glyphs = font.getGlyphSet()
    cmap = font.getBestCmap()
    names = [cmap[ord(letter)] for letter in "BG"]

    bounds = []
    for name in names:
        pen = BoundsPen(glyphs)
        glyphs[name].draw(pen)
        bounds.append(pen.bounds)

    inset = LETTER_OUTLINE / 2
    top, bottom = CAP_TOP + inset, CAP_BOTTOM - inset
    left, right = PAIR_LEFT + inset, PAIR_RIGHT - inset
    gap = LETTER_GAP + LETTER_OUTLINE

    font_bottom = min(b[1] for b in bounds)
    font_top = max(b[3] for b in bounds)
    scale = (bottom - top) / (font_top - font_bottom)
    widths = [(b[2] - b[0]) * scale for b in bounds]
    x = (left + right - (sum(widths) + gap)) / 2
    baseline = bottom + font_bottom * scale

    commands = []
    for name, (x_min, *_), width in zip(names, bounds, widths):
        pen = SVGPathPen(glyphs, ntos=lambda n: f"{n:.2f}".rstrip("0").rstrip("."))
        # Font units have y up; SVG has y down.
        glyphs[name].draw(TransformPen(pen, (scale, 0, 0, -scale, x - x_min * scale, baseline)))
        commands.append(pen.getCommands())
        x += width + gap
    return " ".join(commands)


def build_svg(letters: str) -> str:
    """Returns the icon as a standalone SVG document."""
    brackets = "\n    ".join(f'<path d="{d}"/>' for d in BRACKETS)
    return f"""<svg xmlns="http://www.w3.org/2000/svg" width="192" height="192" viewBox="0 0 192 192">
  <title>Borderless Gaming (redrawn icon, gesu Scoop bucket)</title>
  <!-- Letters: outlines of Carlito Bold, Copyright 2013 The Carlito Project Authors, SIL OFL 1.1. -->
  <defs>
    <linearGradient id="tile" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0.35" stop-color="{COLORS['tile_top']}"/>
      <stop offset="1" stop-color="{COLORS['tile_bottom']}"/>
    </linearGradient>
    <linearGradient id="brackets" x1="0" y1="0" x2="192" y2="0" gradientUnits="userSpaceOnUse">
      <stop offset="0" stop-color="{COLORS['bracket_left']}"/>
      <stop offset="1" stop-color="{COLORS['bracket_right']}"/>
    </linearGradient>
  </defs>
  <rect width="192" height="192" fill="url(#tile)"/>
  <g fill="none" stroke="url(#brackets)" stroke-width="{BRACKET_STROKE}" stroke-linecap="square">
    {brackets}
  </g>
  <path fill="{COLORS['letters']}" stroke="{COLORS['letters']}" stroke-width="{LETTER_OUTLINE}" stroke-linejoin="round"
    d="{letters}"/>
</svg>
"""


def render_png(svg: Path, png: Path, size: int) -> None:
    """Renders the SVG to a square PNG with rsvg-convert."""
    renderer = shutil.which("rsvg-convert")
    if not renderer:
        sys.exit("rsvg-convert not found: install librsvg to render the PNG.")
    subprocess.run(
        [renderer, "--width", str(size), "--height", str(size), "--output", str(png), str(svg)],
        check=True,
    )


def main() -> None:
    """Writes the SVG, then its PNG render."""
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("--font", type=Path, help=f"path to {FONT_NAME}")
    parser.add_argument("--size", type=int, default=192, help="PNG side in pixels (default: 192)")
    args = parser.parse_args()

    letters = letter_paths(find_font(args.font))
    SVG_PATH.write_text(build_svg(letters), encoding="utf-8", newline="\r\n")
    render_png(SVG_PATH, PNG_PATH, args.size)
    print(f"Wrote {SVG_PATH.relative_to(BUCKET_ROOT)} and {PNG_PATH.relative_to(BUCKET_ROOT)}")


if __name__ == "__main__":
    main()
