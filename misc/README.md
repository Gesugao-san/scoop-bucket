# misc

Odds and ends that are not part of any package.

## Banner

The animated title banners of the READMEs, with the scripts that render them. Each script is self-describing; see the docstring at its top.

| File | What |
|---|---|
| [`banner/banner.gif`](banner/banner.gif) | Black capsules tumbling down behind the title; used in the [main README](../README.md) |
| [`banner/banner-plombir.gif`](banner/banner-plombir.gif) | The same capsules with Soviet plombir in waffle cups among them |
| [`banner/banner_pills.py`](banner/banner_pills.py) | Renders `banner.gif` |
| [`banner/banner_plombir.py`](banner/banner_plombir.py) | Renders `banner-plombir.gif`, reusing `banner_pills.py` |

Both scripts need Python 3 with numpy and Pillow, and the [Inter](https://rsms.me/inter/) font (SIL Open Font License), which is only rendered into the pictures, not shipped. With [gifsicle](https://www.lcdf.org/gifsicle/) on the PATH the GIFs come out smaller, with no loss in quality. Run them from the bucket root:

```powershell
scoop install python gifsicle
python -m pip install numpy pillow
python misc/banner/banner_pills.py
python misc/banner/banner_plombir.py
```

The output is the same on every run: positions, turns and colors come from a fixed seed, and every body makes a whole number of passes and turns per 20-second loop, so the last frame joins the first.

[Back to the main README](../README.md)
