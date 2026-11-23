# Known mirrors for bin/Use-Mirror.ps1, read with Import-PowerShellDataFile (data only, no code runs).
# This is a .psd1 rather than .json because Scoop's CI checks every changed *.json file against the manifest schema.
#
# Format: app name (as in bucket/, any case) = list of mirrors. 'mirror1', 'mirror2', ... pick them by position.
#   name         short name, also accepted instead of 'mirrorN'
#   description  shown when listing mirrors
#   '64bit', '32bit', 'arm64'  URL for that architecture; 'url' for apps without architectures.
#                An array of URLs when the manifest downloads several files. '$version' is replaced
#                with the manifest's version and '$tag' with the release tag from the manifest's GitHub URL
#                (keep such URLs in single quotes).
@{
  TrueConf = @(
    @{
      name        = 'trueconf.ru'
      description = "TrueConf's Russian download server (OKB Progress, Moscow): same files, hashes and signatures as trueconf.com"
      '64bit'     = 'https://download.trueconf.ru/download/client/windows/trueconf_client_x64.msi'
      '32bit'     = 'https://download.trueconf.ru/download/client/windows/trueconf_client_x86.msi'
    }
  )
  'Mi-Unlock' = @(
    @{
      name        = 'miuirom.xiaomi.com'
      description = "Xiaomi's ROM server: the same English archive as the CDN link on miui.com (same SHA-256 for 7.6.727.43)"
      url         = 'https://miuirom.xiaomi.com/rom/u1106245679/$version/miflash_unlock_en_$version.zip'
    }
  )
  Victoria = @(
    @{
      name        = 'sourceforge'
      description = "Copy on SourceForge (project victoria-ssd-hdd), not run by the author; same SHA-256 as hdd.by for 5.37. The file name has no dots in the version, so this URL is pinned to 5.37"
      url         = 'https://downloads.sourceforge.net/project/victoria-ssd-hdd/Victoria537.zip'
    }
  )
  'Borderless-Gaming' = @(
    @{
      name        = 'dropbox'
      description = "Dropbox copy used by the starise/scoop-gaming bucket, not run by the author (who asks for the official download); byte-identical to the file on legacy.borderlessgam.ing for 9.6.0 (same SHA-256). Pinned to 9.6.0"
      url         = 'https://www.dropbox.com/scl/fi/0l6er6hchkqtbgodvqe3l/BorderlessGaming-9.6.0.exe?rlkey=xbj8j0ldr8i4g0g0nxakvpicd&dl=1#/dl.exe'
    }
  )
  Halloy = @(
    @{
      name        = 'sourceforge'
      description = "SourceForge's automatic copy of the GitHub releases (project halloy-irc-client.mirror), not run by the developers; same SHA-256 as GitHub for 2026.10"
      '64bit'     = 'https://downloads.sourceforge.net/project/halloy-irc-client.mirror/$version/halloy-installer.exe'
    }
  )
  Cromite = @(
    @{
      name        = 'sourceforge'
      description = "SourceForge's automatic copy of the GitHub releases (project cromite.mirror), not run by the developers; same SHA-256 as GitHub for 153.0.8010.37"
      '64bit'     = 'https://downloads.sourceforge.net/project/cromite.mirror/$tag/chrome-win.zip'
    }
  )
  'Loyalsoldier-GeoIP' = @(
    @{
      name        = 'raw'
      description = "Upstream's release branch on raw.githubusercontent.com: the same files, but always the newest build (no version in the URL), so they match the manifest only until the next Thursday build and Excavator's update after it. Checked for 202611190019"
      url         = @(
        'https://raw.githubusercontent.com/Loyalsoldier/geoip/release/Country.mmdb'
        'https://raw.githubusercontent.com/Loyalsoldier/geoip/release/Country-without-asn.mmdb'
        'https://raw.githubusercontent.com/Loyalsoldier/geoip/release/Country-only-cn-private.mmdb'
        'https://raw.githubusercontent.com/Loyalsoldier/geoip/release/Country-asn.mmdb'
        'https://raw.githubusercontent.com/Loyalsoldier/geoip/release/geoip.dat'
        'https://raw.githubusercontent.com/Loyalsoldier/geoip/release/geoip-only-cn-private.dat'
        'https://raw.githubusercontent.com/Loyalsoldier/geoip/release/geoip-asn.dat'
        'https://raw.githubusercontent.com/Loyalsoldier/geoip/release/cn.dat'
        'https://raw.githubusercontent.com/Loyalsoldier/geoip/release/private.dat'
      )
    }
  )
  Pumpkin = @(
    @{
      name        = 'sourceforge'
      description = "SourceForge's automatic copy of the GitHub releases (project pumpkin.mirror), not run by the developers; same SHA-256 as GitHub for 0.2.2"
      '64bit'     = 'https://downloads.sourceforge.net/project/pumpkin.mirror/$tag/pumpkin-X64-Windows.exe'
      arm64       = 'https://downloads.sourceforge.net/project/pumpkin.mirror/$tag/pumpkin-ARM64-Windows.exe'
    }
  )
  FerrumC = @(
    @{
      name        = 'sourceforge'
      description = "SourceForge's automatic copy of the GitHub releases (project ferrumc.mirror), not run by the developers; same SHA-256 as GitHub for 0.1.0-rc2"
      '64bit'     = 'https://downloads.sourceforge.net/project/ferrumc.mirror/v$version/ferrumc-v$version-x86_64-pc-windows-msvc.zip'
    }
  )
  SteelMC = @(
    @{
      name        = 'sourceforge'
      description = "SourceForge's automatic copy of the GitHub releases (project steelmc.mirror), not run by the developers; byte-identical for 0.17.0, but it lags behind GitHub (0.17.1 was not there yet in November 2026)"
      '64bit'     = 'https://downloads.sourceforge.net/project/steelmc.mirror/$tag/steel-windows.exe'
    }
  )
  MCHPRS = @(
    @{
      name        = 'sourceforge'
      description = "SourceForge's automatic copy of the GitHub releases (project minecraft-high-perform.mirror), not run by the developers; byte-identical for 0.5.2, but it lags behind GitHub (0.5.3 was not there yet in November 2026)"
      '64bit'     = 'https://downloads.sourceforge.net/project/minecraft-high-perform.mirror/v$version/mchprs-x86_64-pc-windows-msvc.zip'
      arm64       = 'https://downloads.sourceforge.net/project/minecraft-high-perform.mirror/v$version/mchprs-aarch64-pc-windows-msvc.zip'
    }
  )
}
