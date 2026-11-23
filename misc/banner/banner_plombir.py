#!/usr/bin/env python3
"""
Renders the title banner of banner_pills.py with Soviet plombir in waffle cups
tumbling down among the capsules.

The cup is a truncated cone with a raised diamond lattice, the plombir a
sphere a little wider than the rim, with melted drips running down the waffle.
Both are bodies of revolution shaded per pixel under the same light as the
capsules; the cup also spins around its own axis, so the lattice and the drips
travel around it. The capsules are exactly the ones of the plain banner.

Needs everything banner_pills.py needs; run it from any folder.

Usage:
  python misc/banner/banner_plombir.py [output.gif] [--fonts DIR]
"""
import math
import os
import sys

import numpy as np

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import banner_pills as bp  # noqa: E402

CUPS = 7                  # how many cups fall
ICE_DIM = 0.62            # brightness of the ice cream against its true colors

R_TOP, R_BOT = 0.42, 0.30  # cup radii in model units (cup height is 1)
WAFFLE = np.array([0.78, 0.56, 0.30])
CREAM = np.array([1.0, 0.92, 0.74])
# Drips: angle around the cup, extra length down the waffle, half-width in radians.
DRIPS = ((0.4, 0.15, 0.20), (1.6, 0.08, 0.16), (2.7, 0.19, 0.22), (3.9, 0.10, 0.18), (5.1, 0.13, 0.20))


def make_cups(rng):
  """Random cups; like the capsules, each one's motion repeats every loop."""
  cups = []
  for _ in range(CUPS):
    z = rng.uniform(0.4, 1.0) ** 0.8
    cups.append(dict(
      z=z, size=(62 * z + 14) * bp.SCALE, wraps=1 if z < 0.75 else 2, spins=rng.choice([-1, 1]),
      axial=int(rng.choice([-1, 1, -1, 1])), spin0=rng.uniform(0, 2 * math.pi),
      x0=rng.uniform(0, bp.W), y0=rng.uniform(0, bp.H + 2 * bp.PAD),
      sway=rng.uniform(4, 14) * z * bp.SCALE, sway_n=int(rng.integers(1, 2)), sway_ph=rng.uniform(0, 2 * math.pi),
      ang0=rng.uniform(0, 2 * math.pi),
    ))
  return cups


def shade(nx, ny, nz):
  """Lambert term and Blinn base for screen-space normals."""
  ndl = nx * bp.LIGHT[0] + ny * bp.LIGHT[1] + nz * bp.LIGHT[2]
  ndh = np.clip(nx * bp.HALF[0] + ny * bp.HALF[1] + nz * bp.HALF[2], 0, 1)
  return ndl, ndh


def cup_rgba(c, t):
  """
  Shades one plombir in a waffle cup at loop phase t.

  Model coordinates: u runs along the cup's axis from the rim (0) to the
  bottom (1), v across it, z toward the viewer. Returns the same
  (x0, y0, color, alpha) patch as banner_pills.capsule_rgba.
  """
  cx, cy, ang = bp.falling(c, t)
  spin = c["spin0"] + 2 * math.pi * c["axial"] * t
  sc = c["size"] / 1.55                       # px per model unit
  mid = 0.24                                  # model point placed at (cx, cy)
  ext = int(math.ceil(0.80 * sc)) + 2
  x0, y0 = int(math.floor(cx)) - ext, int(math.floor(cy)) - ext
  n = 2 * ext + 1
  g = (np.arange(n * bp.SS, dtype=np.float32) + 0.5) / bp.SS
  gy, gx = np.meshgrid(g, g, indexing="ij")
  px, py = (gx + x0 - cx) / sc, (gy + y0 - cy) / sc
  ax, ay = math.cos(ang), math.sin(ang)       # axis, pointing to the bottom
  bx, by = -ay, ax
  u = px * ax + py * ay + mid
  v = px * bx + py * by

  def to_screen(nu, nv, nz):
    nx, ny = nu * ax + nv * bx, nu * ay + nv * by
    ln = np.sqrt(nx * nx + ny * ny + nz * nz) + 1e-6
    return nx / ln, ny / ln, nz / ln

  # Waffle cup: a cone narrowing to the bottom, with a thicker lip at the rim.
  rad = R_TOP + (R_BOT - R_TOP) * np.clip(u, 0, 1)
  rad = np.where(u < 0.11, rad + 0.025, rad)
  in_cup = (u >= 0) & (u <= 1) & (np.abs(v) < rad)
  zc = np.sqrt(np.clip(rad * rad - v * v, 0, None))
  phi = np.arcsin(np.clip(v / np.maximum(rad, 1e-3), -1, 1)) + spin   # angle around the axis
  # Diamond lattice in (angle, height): 10 diamonds around, ridges raised.
  p1 = 10 * phi / (2 * math.pi) + u / 0.11
  p2 = 10 * phi / (2 * math.pi) - u / 0.11
  dist = np.minimum(np.abs(p1 - np.round(p1)), np.abs(p2 - np.round(p2)))
  ridge = np.clip(1 - dist / 0.16, 0, 1) ** 1.5 * (u > 0.12)
  cnu = -rad * (R_BOT - R_TOP) + 0.45 * ridge * np.sign(p1 - np.round(p1)) * rad
  ndl, ndh = shade(*to_screen(cnu, v, zc))
  cell = 0.62 + 0.55 * ridge                  # ridges toasted lighter, cells darker
  lip = np.where(u < 0.11, 1.08, 1.0)
  ao = 0.55 + 0.45 * np.clip((u - 0.02) / 0.22, 0, 1)   # shade under the plombir
  ccol = WAFFLE * (cell * lip * ao * (0.28 + 0.72 * np.clip(ndl, 0, 1)))[..., None] + (0.10 * ndh ** 18)[..., None]
  ccol = np.where((np.abs(u - 0.11) < 0.012)[..., None], ccol * 0.6, ccol)

  # Plombir: a sphere a little wider than the rim, so it overhangs it.
  du = u + 0.03
  ds2 = du * du + v * v
  in_ball = ds2 < 0.45 ** 2
  zb = np.sqrt(np.clip(0.45 ** 2 - ds2, 0, None))
  bnu, bnv, bnz = du, v, zb
  # Melted plombir: a thin layer on the cone whose lower edge waves around
  # the cup in rounded tongues, so the drips follow its shape.
  edge = np.full_like(u, 0.19)
  for ph_k, length, width in DRIPS:
    dph = (phi - ph_k + math.pi) % (2 * math.pi) - math.pi
    tongue = np.sqrt(np.clip(1 - (dph / width) ** 2, 0, None))
    edge = np.maximum(edge, 0.19 + length * tongue ** 0.6)
  on_cup = in_cup & (u < edge) & ~(in_ball & (zb >= zc))
  roll = np.clip((u - edge + 0.035) / 0.035, 0, 1)      # the edge rolls under
  bnu = np.where(on_cup, -rad * (R_BOT - R_TOP) + roll * 0.8 * rad, bnu)
  bnv = np.where(on_cup, v, bnv)
  bnz = np.where(on_cup, zc, bnz)
  zb = np.where(on_cup, zc + 0.01, zb)
  in_ball = in_ball | on_cup
  # Soft bumps: plombir is not a polished ball.
  bump = 0.01 * np.sin(u * 17 + v * 6 + spin * 2) * np.sin(v * 13 - u * 4)
  ndl, ndh = shade(*to_screen(bnu + bump, bnv + bump, bnz))
  wrap = np.clip((ndl + 0.35) / 1.35, 0, 1)             # soft, creamy falloff
  bcol = CREAM * (0.22 + 0.78 * wrap)[..., None] + (0.22 * ndh ** 24)[..., None]

  front_ball = in_ball & (~in_cup | (zb >= zc - 0.02))
  col = np.where(front_ball[..., None], bcol, ccol)
  alpha = (in_cup | in_ball).astype(np.float32)
  lum = col.mean(axis=2, keepdims=True)
  col = (col * 0.9 + lum * 0.1) * ICE_DIM * (0.55 + 0.45 * c["z"])
  col = (col * alpha[..., None]).reshape(n, bp.SS, n, bp.SS, 3).mean(axis=(1, 3))
  alpha = alpha.reshape(n, bp.SS, n, bp.SS).mean(axis=(1, 3))
  return x0, y0, col, alpha


def cup_things(rng):
  """The cups as things to draw, for banner_pills.main."""
  return [dict(z=c["z"], render=lambda t, c=c: cup_rgba(c, t)) for c in make_cups(rng)]


if __name__ == "__main__":
  bp.main(extra=cup_things, default_out="banner-plombir.gif")
