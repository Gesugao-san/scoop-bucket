#!/usr/bin/env python3
"""Writes the RealiTLScanner icon for UniGetUI and renders it to PNG.

RealiTLScanner has no icon of its own, so this uses the logo of its authors,
Project X (XTLS): the four-pointed star from logo-light.svg in XTLS/Xray-docs-next
(docs/public/logo-light.svg, CC-BY-SA-4.0). The four polygons below are copied
from that file unchanged.

The adaptation: the black star gets an outline in #dfdfd6, the fill colour of
the same repository's logo-dark.svg, and a margin for the outline. One PNG then
works on UniGetUI's light and dark themes: black on light, outlined on dark.
Like the original, the result is under CC-BY-SA-4.0.

Writes, relative to the bucket root:
  icons/realitlscanner.svg      the adapted vector logo
  icons/realitlscanner-192.png  its 192x192 render, used for UniGetUI

Needs rsvg-convert (librsvg) on the PATH; on Windows, MSYS2's
mingw-w64-x86_64-librsvg.

Usage:
  python3 scripts/realitlscanner/make_icon.py [--size 192]
"""

import argparse
import shutil
import subprocess
import sys
from pathlib import Path

BUCKET_ROOT = Path(__file__).resolve().parents[2]
SVG_PATH = BUCKET_ROOT / "icons" / "realitlscanner.svg"
PNG_PATH = BUCKET_ROOT / "icons" / "realitlscanner-192.png"

SOURCE = (
    "https://github.com/XTLS/Xray-docs-next/blob/"
    "HEAD/docs/public/logo-light.svg"
)

# The star from logo-light.svg, in its 1000x1000 viewBox.
POLYGONS = [
    "530,530 900,530 650,650 530,1000",
    "470,530 470,900 350,650 0,530",
    "530,470 530,100 650,350 1000,470",
    "470,470 100,470 350,350 470,0",
]

FILL = "#000000"      # logo-light.svg
OUTLINE = "#dfdfd6"   # logo-dark.svg
OUTLINE_WIDTH = 36    # in viewBox units; half of it lies outside the star
MARGIN = 50           # room for the outline at the tips


def build_svg() -> str:
    """Returns the adapted logo as an SVG document."""
    side = 1000 + 2 * MARGIN
    polygons = "\n".join(f'    <polygon points="{p}"/>' for p in POLYGONS)
    return (
        '<svg xmlns="http://www.w3.org/2000/svg" '
        f'viewBox="{-MARGIN} {-MARGIN} {side} {side}">\n'
        f"  <!-- Project X logo (XTLS), from {SOURCE}, CC-BY-SA-4.0.\n"
        "       Adapted for the gesu Scoop bucket: outline added. -->\n"
        f'  <g fill="{FILL}" stroke="{OUTLINE}" stroke-width="{OUTLINE_WIDTH}" '
        'stroke-linejoin="round" paint-order="stroke">\n'
        f"{polygons}\n"
        "  </g>\n"
        "</svg>\n"
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
