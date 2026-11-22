# Installing from a mirror

Scoop has no fallback URLs: an array in `url` lists different files, not alternatives for one file, and a failed download stops the install. It does look in its cache first, though, so [`bin/Use-Mirror.ps1`](../bin/Use-Mirror.ps1) downloads the file from another host into the cache under the name Scoop expects for the manifest URL:

```powershell
.\bin\Use-Mirror.ps1 gesu/TrueConf            # list TrueConf's mirrors
.\bin\Use-Mirror.ps1 gesu/TrueConf mirror1    # first mirror; or by name: trueconf.ru
scoop install gesu/TrueConf
```

Known mirrors are kept in [`mirrors.psd1`](../mirrors.psd1), a PowerShell data file read with `Import-PowerShellDataFile`, which accepts data only, so the file cannot run code. It was kept out of JSON while CI still checked every changed `*.json` in the repository against the manifest schema; CI now checks only `bucket/` (see [Automation](automation.md)). Each app has a list of mirrors; `mirror1`, `mirror2`, ... pick them by position, and each one's `name` works too. A mirror gives one URL per architecture (`64bit`, `32bit`, `arm64`), or `url` for apps without architectures; any of them can be an array when the manifest downloads several files, `$version` in a URL is replaced with the manifest's version, and `$tag` with the release tag taken from the manifest's own GitHub download URL (for mirrors whose folders are named after tags such as `0.2.2+26.3-26.60`, which the version alone does not give). A full URL instead of a mirror name works for hosts not in the file:

```powershell
.\bin\Use-Mirror.ps1 gesu/TrueConf https://download.trueconf.ru/download/client/windows/trueconf_client_x64.msi
```

Run it from a clone of this repository or from the copy Scoop keeps of the bucket, `~\scoop\buckets\gesu` (under `$env:SCOOP` if Scoop lives elsewhere). The script loads Scoop's own `lib/` to find the manifest, the cache folder (`SCOOP_CACHE` and `cache_path` included) and the cache file name, so it follows whatever the installed Scoop does. It checks the downloaded file against the manifest's hash before putting it into the cache, so a mirror can only supply the exact file the manifest describes, and Scoop checks the hash again when it installs. `-Architecture` picks another architecture, `-Index` another file when a manifest lists several. The manifest URL is part of the cache file name, so each new version needs a new run.
