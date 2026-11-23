#!/usr/bin/env python3
"""
Renders the bucket's title banner: black capsules tumbling down behind the
title, as a seamless looping GIF.

Every capsule is shaded per pixel as a 3D body (a cylinder with two
hemispherical ends) under one fixed light, so highlights stay in place while
the capsules turn. Far capsules are smaller, slower and sink into the haze;
near ones are larger, faster and sharp. Each capsule makes a whole number of
passes and turns per loop, so the last frame joins the first.

banner_plombir.py imports this module and adds Soviet plombir in waffle cups.

Needs Python 3, numpy and Pillow, plus the Inter font (InterDisplay-Bold.otf
and Inter-SemiBold.otf, https://rsms.me/inter/); gifsicle on PATH, if present,
makes the file smaller without losing quality.

Usage:
  python misc/banner/banner_pills.py [output.gif] [--fonts DIR]
"""
import argparse
import math
import os
import shutil
import subprocess
import sys

import numpy as np
from PIL import Image, ImageDraw, ImageFilter, ImageFont

W, H = 1000, 250          # banner size, px
FRAMES = 100              # loop length
DELAY = 40                # ms per frame (25 fps, 4 s loop)
SS = 2                    # supersampling of the shaded bodies
PAD = 90                  # bodies start and end this far outside the frame
SEED = 7                  # same seed, same banner

TITLE = "scoop-bucket"
SUBTITLE = "gesu  ·  a personal Scoop bucket"
FONT_TITLE = "InterDisplay-Bold.otf"
FONT_SUB = "Inter-SemiBold.otf"

LIGHT = np.array([-0.45, -0.75, 0.55])
LIGHT /= np.linalg.norm(LIGHT)
HALF = LIGHT + np.array([0.0, 0.0, 1.0])  # Blinn half vector, the viewer looks along +z
HALF /= np.linalg.norm(HALF)


def font_dirs(extra):
  """Folders searched for the fonts, the one given on the command line first."""
  dirs = [extra] if extra else []
  dirs += ["/usr/share/fonts/opentype/inter", "/usr/share/fonts/OTF", os.path.expanduser("~/.fonts")]
  if os.name == "nt":
    dirs += [os.path.expandvars(r"%LOCALAPPDATA%\Microsoft\Windows\Fonts"), os.path.expandvars(r"%WINDIR%\Fonts")]
  return dirs


def find_font(name, extra):
  """Path of a font file; exits with a message when it is nowhere to be found."""
  for d in font_dirs(extra):
    path = os.path.join(d, name)
    if os.path.isfile(path):
      return path
  sys.exit(f"Font {name} not found; install Inter or pass --fonts <folder with it>.")


def background():
  """Dark radial gradient with a vignette, gray values 0..1."""
  y, x = np.mgrid[0:H, 0:W].astype(np.float32)
  dx, dy = (x - W / 2) / (W / 2), (y - H * 0.45) / (H / 2)
  r = np.sqrt(dx * dx * 0.55 + dy * dy * 0.9)
  return np.clip(0.13 - 0.10 * r, 0.015, 1.0)


def falling(c, t):
  """Center and in-plane angle of a falling body at loop phase t (0..1)."""
  ang = c["ang0"] + 2 * math.pi * c["spins"] * t
  span = H + 2 * PAD
  cy = (c["y0"] + span * c["wraps"] * t) % span - PAD
  cx = c["x0"] + c["sway"] * math.sin(2 * math.pi * c["sway_n"] * t + c["sway_ph"])
  return cx, cy, ang


def make_capsules(rng):
  """Random capsules; each one's motion repeats exactly every FRAMES."""
  caps = []
  for _ in range(34):
    z = rng.uniform(0.3, 1.0) ** 0.8          # depth: 1 is nearest
    r = 11.0 * z + 2.0                         # radius
    a = r * rng.uniform(1.5, 1.9)              # half-length of the straight part
    wraps = 1 if z < 0.55 else (2 if z < 0.9 else 3)
    spins = rng.choice([-2, -1, 1, 2]) if z > 0.5 else rng.choice([-1, 1])
    caps.append(dict(
      z=z, r=r, a=a, wraps=wraps, spins=spins,
      x0=rng.uniform(0, W), y0=rng.uniform(0, H + 2 * PAD),
      sway=rng.uniform(4, 18) * z, sway_n=int(rng.integers(1, 3)), sway_ph=rng.uniform(0, 2 * math.pi),
      ang0=rng.uniform(0, 2 * math.pi),
      tone=(0.035, 0.075) if rng.random() < 0.5 else (0.075, 0.035),
    ))
  return caps


def capsule_rgba(c, t):
  """
  Shades one capsule at loop phase t.

  Returns (x0, y0, color, alpha): the patch's top-left corner in the frame, its
  premultiplied RGB color and its coverage.
  """
  cx, cy, ang = falling(c, t)
  r, a = c["r"], c["a"]
  ext = int(math.ceil(a + r)) + 2
  x0, y0 = int(math.floor(cx)) - ext, int(math.floor(cy)) - ext
  n = 2 * ext + 1
  g = (np.arange(n * SS, dtype=np.float32) + 0.5) / SS
  gy, gx = np.meshgrid(g, g, indexing="ij")
  px, py = gx + x0 - cx, gy + y0 - cy
  ux, uy = math.cos(ang), math.sin(ang)
  u = px * ux + py * uy                         # along the axis
  uc = np.clip(u, -a, a)
  qx, qy = px - uc * ux, py - uc * uy           # from the axis to the point
  d2 = qx * qx + qy * qy
  inside = d2 < r * r
  h = np.sqrt(np.clip(r * r - d2, 0, None))
  nx, ny, nz = qx / r, qy / r, h / r
  diff = np.clip(nx * LIGHT[0] + ny * LIGHT[1] + nz * LIGHT[2], 0, 1)
  spec = np.clip(nx * HALF[0] + ny * HALF[1] + nz * HALF[2], 0, 1) ** 70
  rim = (1 - nz) ** 3
  albedo = np.where(u < 0, c["tone"][0], c["tone"][1])
  col = albedo * (0.35 + 0.65 * diff) + 0.95 * spec + 0.10 * rim
  col = np.where(np.abs(u) < 0.7, col * 0.45, col)   # seam between the halves
  col = col * (0.55 + 0.45 * c["z"])                  # far ones are dimmer
  alpha = inside.astype(np.float32)
  col = (col * alpha).reshape(n, SS, n, SS).mean(axis=(1, 3))
  alpha = alpha.reshape(n, SS, n, SS).mean(axis=(1, 3))
  return x0, y0, np.repeat(col[..., None], 3, axis=2), alpha


def composite(frame, x0, y0, col, alpha, fog, bg):
  """Lays a premultiplied patch over the frame, sinking far bodies into the haze by `fog`."""
  n_h, n_w = alpha.shape
  fx0, fy0 = max(x0, 0), max(y0, 0)
  fx1, fy1 = min(x0 + n_w, W), min(y0 + n_h, H)
  if fx0 >= fx1 or fy0 >= fy1:
    return
  sx, sy = fx0 - x0, fy0 - y0
  c = col[sy:sy + fy1 - fy0, sx:sx + fx1 - fx0]
  al = alpha[sy:sy + fy1 - fy0, sx:sx + fx1 - fx0][..., None]
  b = bg[fy0:fy1, fx0:fx1]
  c = c * (1 - fog) + b * al * fog
  frame[fy0:fy1, fx0:fx1] = c + frame[fy0:fy1, fx0:fx1] * (1 - al)


def title_layer(fonts):
  """Title and subtitle coverage masks and the soft halo behind them, all 0..1."""
  img, subimg, shadow = (Image.new("L", (W, H), 0) for _ in range(3))
  draw, subdraw, sdraw = ImageDraw.Draw(img), ImageDraw.Draw(subimg), ImageDraw.Draw(shadow)
  ft = ImageFont.truetype(find_font(FONT_TITLE, fonts), 84)
  fs = ImageFont.truetype(find_font(FONT_SUB, fonts), 22)
  tx, ty = (W - draw.textlength(TITLE, font=ft)) / 2, 62
  sx, sy = (W - draw.textlength(SUBTITLE, font=fs)) / 2, 160
  draw.text((tx, ty), TITLE, font=ft, fill=255)
  sdraw.text((tx + 3, ty + 4), TITLE, font=ft, fill=255)
  subdraw.text((sx, sy), SUBTITLE, font=fs, fill=255)
  sdraw.text((sx + 2, sy + 3), SUBTITLE, font=fs, fill=255)
  # A wide soft halo keeps tumbling bodies from fighting the letters.
  halo = np.maximum(np.asarray(shadow.filter(ImageFilter.GaussianBlur(6)), np.float32),
                    np.asarray(shadow.filter(ImageFilter.GaussianBlur(16)), np.float32) * 0.9) / 255
  return np.asarray(img, np.float32) / 255, np.asarray(subimg, np.float32) / 255, np.clip(halo * 1.4, 0, 1)


def render(things, fonts):
  """Draws every frame as RGB, bodies sorted far to near, the title on top."""
  bg = np.repeat(background()[..., None], 3, axis=2)
  title, sub, halo = (m[..., None] for m in title_layer(fonts))
  things = sorted(things, key=lambda it: it["z"])
  frames = []
  for i in range(FRAMES):
    t = i / FRAMES
    f = bg.copy()
    for it in things:
      composite(f, *it["render"](t), (1 - it["z"]) * 0.75, bg)
    f = f * (1 - 0.8 * halo)
    f = f * (1 - title) + 0.86 * title
    f = f * (1 - sub) + 0.58 * sub
    frames.append(np.clip(f * 255 + 0.5, 0, 255).astype(np.uint8))
  return frames


def to_gif_frames(rgb_frames):
  """
  Converts RGB frames to palette frames with one palette for the whole loop.

  Gray pixels map only to grays (every dark gray is in the palette, so the
  haze does not band) and colored pixels only to the colored entries, which
  are fitted to the colors that actually appear. A loop with no color at all
  becomes a plain grayscale GIF.
  """
  sample = np.concatenate([f.reshape(-1, 3) for f in rgb_frames[::FRAMES // 10]]).astype(np.int16)
  colored_sample = sample[(sample.max(axis=1) - sample.min(axis=1)) > 12]
  if len(colored_sample) == 0:
    return [Image.fromarray(f.mean(axis=2).round().astype(np.uint8), "L") for f in rgb_frames]
  grays = list(range(0, 64)) + list(range(64, 256, 2))
  n_col = 256 - len(grays)
  side = int(math.ceil(math.sqrt(len(colored_sample))))
  filler = np.repeat(colored_sample[:1], side * side - len(colored_sample), axis=0)
  square = np.concatenate([colored_sample, filler]).astype(np.uint8).reshape(side, side, 3)
  cpal = Image.fromarray(square, "RGB").quantize(colors=n_col, method=Image.Quantize.MEDIANCUT).getpalette()[:n_col * 3]
  palette = [v for g in grays for v in (g, g, g)] + cpal
  gray_lut = np.array([int(np.argmin([abs(g - v) for g in grays])) for v in range(256)], np.uint8)
  cpal_arr = np.array(cpal, np.int32).reshape(-1, 3)
  out = []
  for f in rgb_frames:
    flat = f.reshape(-1, 3).astype(np.int32)
    idx = gray_lut[np.clip(np.rint(flat.mean(axis=1)), 0, 255).astype(np.int32)]
    colored = (flat.max(axis=1) - flat.min(axis=1)) > 4
    if colored.any():
      d = ((flat[colored][:, None, :] - cpal_arr[None, :, :]) ** 2).sum(axis=2)
      idx[colored] = (len(grays) + d.argmin(axis=1)).astype(np.uint8)
    im = Image.fromarray(idx.reshape(H, W), "P")
    im.putpalette(palette)
    out.append(im)
  return out


def save(frames, out):
  """Writes the looping GIF and squeezes it with gifsicle when that is on PATH."""
  frames[0].save(out, save_all=True, append_images=frames[1:], duration=DELAY, loop=0, optimize=True)
  gifsicle = shutil.which("gifsicle")
  if not gifsicle:
    return
  subprocess.run([gifsicle, "-O3", "-b", out], check=True)


def capsule_things(rng):
  """The capsules as things to draw: depth plus a renderer for a loop phase."""
  return [dict(z=c["z"], render=lambda t, c=c: capsule_rgba(c, t)) for c in make_capsules(rng)]


def main(argv=None, extra=None, default_out="banner.gif"):
  """
  Renders and saves the banner.

  `extra`, if given, takes the random generator after the capsules have been
  made and returns more things to draw, so adding them does not move the capsules.
  """
  parser = argparse.ArgumentParser(description=__doc__.strip().splitlines()[0])
  parser.add_argument("output", nargs="?", default=os.path.join(os.path.dirname(os.path.abspath(__file__)), default_out))
  parser.add_argument("--fonts", help="folder with InterDisplay-Bold.otf and Inter-SemiBold.otf")
  args = parser.parse_args(argv)
  rng = np.random.default_rng(SEED)
  things = capsule_things(rng)
  if extra:
    things += extra(rng)
  save(to_gif_frames(render(things, args.fonts)), args.output)
  print(args.output)


if __name__ == "__main__":
  main()
