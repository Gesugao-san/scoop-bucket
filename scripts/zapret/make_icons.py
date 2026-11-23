#!/usr/bin/env python3
"""Draws the alternative icons of the zapret packages and their components for UniGetUI.

None of these upstreams has a usable logo: winws.exe carries a 32x32 broken padlock, winws2.exe a
padlock-and-key picture of unknown origin, and WinDivert, WinDivert-hide, zapret-discord-youtube and
the Cygwin runtime package have none of their own (Cygwin's logo is the Cygwin project's). These are
original vector drawings, no third-party logos or trademarks:

  zapret                  a broken padlock (in the spirit of winws.exe's icon, new artwork)
  zapret2                 the same padlock with a "2" badge
  zapret-discord-youtube  the padlock with a play triangle and a chat bubble badge
  windivert               packets on a line, one diverted up through a filter box and back
  windivert-hide          the same with a dark grey filter, the diverted path dotted, with a crossed-out eye badge
  cygwin-runtime          a green library tile with a terminal prompt

Writes, relative to the bucket root, for each <id> above:
  icons/<id>-alt.svg  the vector icon
  icons/<id>-alt.png  its 192x192 render, used for UniGetUI

Needs rsvg-convert (librsvg) on the PATH; on Windows, MSYS2's mingw-w64-x86_64-librsvg.

Usage:
  python3 scripts/zapret/make_icons.py [--size 192]
"""

import argparse
import shutil
import subprocess
import sys
from pathlib import Path

BUCKET_ROOT = Path(__file__).resolve().parents[2]
ICONS = BUCKET_ROOT / "icons"
VIEW = 512  # square viewBox side

LOCK = {
    "shackle": "#4b5563",
    "body": "#f5b731",
    "body_shade": "#d9921b",
    "outline": "#8a5a12",
}
BADGE_RING = "#ffffff"


def svg(body: str) -> str:
    """Wraps drawing elements in a square SVG document."""
    return (
        f'<svg xmlns="http://www.w3.org/2000/svg" width="{VIEW}" height="{VIEW}" '
        f'viewBox="0 0 {VIEW} {VIEW}">\n{body}\n</svg>\n'
    )


def broken_padlock(dx: float = 0, dy: float = 0, scale: float = 1.0) -> str:
    """A padlock whose body is split by a zigzag crack and whose shackle is broken open on the left."""
    # Shackle: an arch from the right leg over the top, ending in a broken stub on the left.
    shackle = (
        f'<path d="M 336 236 V 160 A 80 80 0 0 0 186 122" fill="none" stroke="{LOCK["shackle"]}" '
        'stroke-width="42" stroke-linecap="round"/>'
        f'<path d="M 176 196 V 236" fill="none" stroke="{LOCK["shackle"]}" stroke-width="42" stroke-linecap="round"/>'
    )
    # Body halves, separated by a zigzag gap and pushed apart a little.
    zigzag = [(262, 226), (240, 270), (272, 300), (236, 346), (270, 380), (246, 446)]
    left = [(116, 226)] + zigzag + [(116, 446)]
    right = [(396, 226)] + [(x + 16, y) for x, y in zigzag] + [(396, 446)]

    def half(points, shift, clip_id):
        # The shade along the bottom is clipped to its own half, so it stops at the crack.
        pts = " ".join(f"{x + shift},{y}" for x, y in points)
        return (
            f'<clipPath id="{clip_id}"><polygon points="{pts}"/></clipPath>'
            f'<polygon points="{pts}" fill="{LOCK["body"]}"/>'
            f'<rect x="100" y="400" width="320" height="30" fill="{LOCK["body_shade"]}" opacity="0.55" '
            f'clip-path="url(#{clip_id})"/>'
            f'<polygon points="{pts}" fill="none" stroke="{LOCK["outline"]}" '
            'stroke-width="14" stroke-linejoin="round"/>'
        )

    body = half(left, -6, "lock-left") + half(right, 6, "lock-right")
    return f'<g transform="translate({dx} {dy}) scale({scale})">{shackle}{body}</g>'


def badge(cx: float, cy: float, r: float, fill: str, inner: str) -> str:
    """A round badge with a white ring and the given inner drawing."""
    return (
        f'<circle cx="{cx}" cy="{cy}" r="{r + 10}" fill="{BADGE_RING}"/>'
        f'<circle cx="{cx}" cy="{cy}" r="{r}" fill="{fill}"/>{inner}'
    )


def icon_zapret() -> str:
    return svg(broken_padlock(0, 10))


def icon_zapret2() -> str:
    # The digit is a stroked path, so the SVG needs no font.
    two = (
        '<path d="M 368 376 C 368 344 424 344 424 376 C 424 400 372 420 366 452 H 428" fill="none" '
        'stroke="#ffffff" stroke-width="22" stroke-linecap="round" stroke-linejoin="round"/>'
    )
    return svg(broken_padlock(-28, -6, 0.92) + badge(396, 410, 74, "#2563eb", two))


def icon_zapret_discord_youtube() -> str:
    # A play triangle on the left half of the padlock body.
    play = '<polygon points="106,262 106,350 176,306" fill="#ffffff" stroke="#ffffff" stroke-width="12" stroke-linejoin="round"/>'
    bubble = (
        '<path d="M 350 362 h 92 a 18 18 0 0 1 18 18 v 52 a 18 18 0 0 1 -18 18 h -50 l -26 24 v -24 h -16 '
        'a 18 18 0 0 1 -18 -18 v -52 a 18 18 0 0 1 18 -18 z" fill="#ffffff"/>'
        '<circle cx="372" cy="406" r="9" fill="#4f46e5"/><circle cx="396" cy="406" r="9" fill="#4f46e5"/>'
        '<circle cx="420" cy="406" r="9" fill="#4f46e5"/>'
    )
    return svg(broken_padlock(-28, -6, 0.92) + play + badge(396, 410, 74, "#4f46e5", bubble))


def divert_diagram(line: str, path: str, box: str, dashed: bool) -> str:
    """Packets on a line; the middle one goes up through a filter box and comes back down."""
    # A dotted path: zero-length dashes with round caps are round dots. Dashes along a curve read
    # as a worm's segments with round caps, and stick out from under the box with square ones.
    dash = ' stroke-dasharray="0 46" stroke-linecap="round"' if dashed else ' stroke-linecap="round"'
    return (
        # The network path, left and right of the diversion, with an arrowhead at the end.
        f'<path d="M 40 360 H 150 M 362 360 H 448" stroke="{line}" stroke-width="30" stroke-linecap="round" fill="none"/>'
        f'<polygon points="440,326 492,360 440,394" fill="{line}"/>'
        # The diversion: up into user mode, through the filter box, back down.
        f'<path d="M 150 360 C 150 250 150 230 200 200 M 312 200 C 362 230 362 250 362 360" stroke="{path}" '
        f'stroke-width="30" fill="none"{dash}/>'
        f'<polygon points="332,312 392,312 362,368" fill="{path}"/>'
        f'<rect x="176" y="116" width="160" height="128" rx="26" fill="{box}"/>'
        # A funnel in the box: the filter.
        '<path d="M 214 152 H 298 L 268 192 V 218 L 244 206 V 192 Z" fill="#ffffff"/>'
    )


def icon_windivert() -> str:
    return svg(divert_diagram("#64748b", "#2563eb", "#1d4ed8", dashed=False))


def icon_windivert_hide() -> str:
    # A crossed-out eye: an almond with a pupil, and a slash with a gap around it.
    eye = (
        '<path d="M 340 410 Q 396 340 452 410 Q 396 480 340 410 Z" fill="#ffffff"/>'
        '<circle cx="396" cy="410" r="22" fill="#374151"/>'
        '<path d="M 350 456 L 442 364" stroke="#374151" stroke-width="26" stroke-linecap="round"/>'
        '<path d="M 350 456 L 442 364" stroke="#ffffff" stroke-width="10" stroke-linecap="round"/>'
    )
    diagram = divert_diagram("#64748b", "#4b5563", "#374151", dashed=True)
    return svg(f'<g transform="translate(-20 -40) scale(0.94)">{diagram}</g>' + badge(396, 410, 70, "#374151", eye))


def icon_cygwin_runtime() -> str:
    return svg(
        # A library tile: a rounded square with a folded corner.
        '<path d="M 112 64 H 340 L 420 144 V 424 a 32 32 0 0 1 -32 32 H 112 a 32 32 0 0 1 -32 -32 V 96 '
        'a 32 32 0 0 1 32 -32 Z" fill="#2f8f46"/>'
        '<path d="M 340 64 V 120 a 24 24 0 0 0 24 24 H 420 Z" fill="#1f6b33"/>'
        # A terminal prompt: chevron and cursor.
        '<path d="M 152 236 L 228 290 L 152 344" fill="none" stroke="#ffffff" stroke-width="34" '
        'stroke-linecap="round" stroke-linejoin="round"/>'
        '<path d="M 252 352 H 344" stroke="#ffffff" stroke-width="34" stroke-linecap="round"/>'
        # Three link marks along the bottom: a shared library.
        '<circle cx="168" cy="408" r="12" fill="#bfe6c8"/><circle cx="212" cy="408" r="12" fill="#bfe6c8"/>'
        '<circle cx="256" cy="408" r="12" fill="#bfe6c8"/>'
    )


DRAWINGS = {
    "zapret": icon_zapret,
    "zapret2": icon_zapret2,
    "zapret-discord-youtube": icon_zapret_discord_youtube,
    "windivert": icon_windivert,
    "windivert-hide": icon_windivert_hide,
    "cygwin-runtime": icon_cygwin_runtime,
}


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("--size", type=int, default=192, help="PNG side in pixels (default: 192)")
    args = parser.parse_args()

    renderer = shutil.which("rsvg-convert")
    if not renderer:
        print("rsvg-convert not found on PATH (librsvg).", file=sys.stderr)
        return 1

    for app_id, draw in DRAWINGS.items():
        svg_path = ICONS / f"{app_id}-alt.svg"
        png_path = ICONS / f"{app_id}-alt.png"
        svg_path.write_text(draw(), encoding="utf-8", newline="\n")
        subprocess.run(
            [renderer, "-w", str(args.size), "-h", str(args.size), "-o", str(png_path), str(svg_path)],
            check=True,
        )
        print(f"{svg_path.relative_to(BUCKET_ROOT)} -> {png_path.relative_to(BUCKET_ROOT)}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
