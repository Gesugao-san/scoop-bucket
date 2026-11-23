# misc

Odds and ends that are not part of any package.

## Banner

The animated title banners of the READMEs, with the scripts that render them. Each script is self-describing; see the docstring at its top.

The files avoid the word *banner* in their names on purpose: ad blockers hide images whose URL contains `/banner.gif` and the like (RU AdList does, even on GitHub), so the title would vanish for many readers. [`bin/check-adblock.py`](../bin/check-adblock.py) checks every image the bucket shows against the common lists.

| File | What |
|---|---|
| [`title/title.gif`](title/title.gif) | Black capsules tumbling down behind the title; used in the [main README](../README.md) |
| [`title/title-plombir.gif`](title/title-plombir.gif) | The same capsules with Soviet plombir in waffle cups among them |
| [`title/title_pills.py`](title/title_pills.py) | Renders `title.gif` |
| [`title/title_plombir.py`](title/title_plombir.py) | Renders `title-plombir.gif`, reusing `title_pills.py` |

Both scripts need Python 3 with numpy and Pillow, and the [Inter](https://rsms.me/inter/) font (SIL Open Font License), which is only rendered into the pictures, not shipped. With [gifsicle](https://www.lcdf.org/gifsicle/) on the PATH the GIFs come out smaller, with no loss in quality. Run them from the bucket root:

```powershell
scoop install python gifsicle
python -m pip install numpy pillow
python misc/title/title_pills.py
python misc/title/title_plombir.py
```

The output is the same on every run: positions, turns and colors come from a fixed seed, and every body makes a whole number of passes and turns per 20-second loop, so the last frame joins the first.

[Back to the main README](../README.md)
