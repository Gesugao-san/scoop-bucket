# Samsung-Magician

| | |
|---|---|
| Manifest | [`bucket/Samsung-Magician.json`](../../bucket/Samsung-Magician.json) |
| Upstream | [Samsung Semiconductor](https://semiconductor.samsung.com/consumer-storage/magician/) (freeware) |
| Install | `scoop install gesu/Samsung-Magician` |

**Not portable and not silent**: Samsung's Inno Setup script refuses silent mode ("Samsung Magician cannot be installed in silent mode") and asks whether you live in a GDPR country or Brazil, so Scoop opens the setup wizard for you to finish. This manifest does not try to get around that: the answer is a privacy consent that belongs to the user. Adds the `SamsungMagicianSVC` service, the `magdrv` kernel driver, a logon scheduled task and possibly a power plan. Install, update and uninstall from an elevated shell; uninstall runs Magician's own uninstaller silently. Samsung's global [tools page](https://semiconductor.samsung.com/consumer-storage/support/tools/) lags behind (still 9.0.1.950 in October 2026), so `checkver` reads the download list embedded as JSON in a model support page ([9100 PRO 8 TB, UK](https://www.samsung.com/uk/support/model/MZ-VAP8T0BW/), the newest consumer model as of 2026) and builds the `downloadcenter.samsung.com/content/...` URL from its `filePath`, like [winget-extras](https://github.com/pl4nty/winget-extras/tree/main/manifests/s/Samsung/Magician) does. If Samsung drops Magician from that page, point `checkver` at another current SSD model.

[All packages](../../README.md#packages)
