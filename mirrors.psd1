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
  'Xray-core' = @(
    @{
      name        = 'sourceforge'
      description = "SourceForge's automatic copy of the GitHub releases (project xray-core.mirror), not run by the developers; byte-identical to GitHub for 26.11.9 (all three archives)"
      '64bit'     = 'https://downloads.sourceforge.net/project/xray-core.mirror/$tag/Xray-windows-64.zip'
      '32bit'     = 'https://downloads.sourceforge.net/project/xray-core.mirror/$tag/Xray-windows-32.zip'
      arm64       = 'https://downloads.sourceforge.net/project/xray-core.mirror/$tag/Xray-windows-arm64-v8a.zip'
    }
  )
  'Loyalsoldier-v2ray-rules-dat' = @(
    @{
      name        = 'raw'
      description = "Upstream's release branch on raw.githubusercontent.com: the same files, but always the newest build (no version in the URL), so they match the manifest only until the next daily build and Excavator's update after it. Checked for 202611222203"
      url         = @(
        'https://raw.githubusercontent.com/Loyalsoldier/v2ray-rules-dat/release/geoip.dat'
        'https://raw.githubusercontent.com/Loyalsoldier/v2ray-rules-dat/release/geosite.dat'
      )
    }
  )
  'Chocolate4U-Iran-v2ray-rules' = @(
    @{
      name        = 'raw'
      description = "Upstream's release branch on raw.githubusercontent.com, which upstream documents as a download location: always the newest build, so it matches the manifest only until the next daily build. Checked for 202611221249"
      url         = @(
        'https://raw.githubusercontent.com/Chocolate4U/Iran-v2ray-rules/release/geoip.dat'
        'https://raw.githubusercontent.com/Chocolate4U/Iran-v2ray-rules/release/geosite.dat'
        'https://raw.githubusercontent.com/Chocolate4U/Iran-v2ray-rules/release/geoip-lite.dat'
        'https://raw.githubusercontent.com/Chocolate4U/Iran-v2ray-rules/release/geosite-lite.dat'
        'https://raw.githubusercontent.com/Chocolate4U/Iran-v2ray-rules/release/geoip-services.dat'
        'https://raw.githubusercontent.com/Chocolate4U/Iran-v2ray-rules/release/security.dat'
        'https://raw.githubusercontent.com/Chocolate4U/Iran-v2ray-rules/release/security-ip.dat'
        'https://raw.githubusercontent.com/Chocolate4U/Iran-v2ray-rules/release/Country.mmdb'
        'https://raw.githubusercontent.com/Chocolate4U/Iran-v2ray-rules/release/Country-lite.mmdb'
        'https://raw.githubusercontent.com/Chocolate4U/Iran-v2ray-rules/release/Services.mmdb'
        'https://raw.githubusercontent.com/Chocolate4U/Iran-v2ray-rules/release/Security-ip.mmdb'
      )
    }
  )
  'runetfreedom-russia-v2ray-rules-dat' = @(
    @{
      name        = 'raw'
      description = "Upstream's release branch on raw.githubusercontent.com, which upstream links as the download location: always the newest build, so it matches the manifest only until the next build, a few hours at most. Checked for 202611230154"
      url         = @(
        'https://raw.githubusercontent.com/runetfreedom/russia-v2ray-rules-dat/release/geoip.dat'
        'https://raw.githubusercontent.com/runetfreedom/russia-v2ray-rules-dat/release/geosite.dat'
      )
    }
  )
  WinDivert = @(
    @{
      name        = 'reqrypt.org'
      description = "The author's own download page (reqrypt.org/download), which upstream's README points to for the originals; not reachable from where this entry was written, so not compared byte for byte (Scoop still checks the hash)"
      url         = 'https://reqrypt.org/download/WinDivert-$version.zip'
    }
  )
  'Cygwin-Runtime' = @(
    @{
      name        = 'dotsrc'
      description = "Official Cygwin mirror at dotsrc.org (Aalborg University); its sha512.sum lists the same SHA-512 as mirrors.kernel.org for 3.6.12-1"
      '64bit'     = 'https://mirrors.dotsrc.org/cygwin/x86_64/release/cygwin/cygwin-$version-x86_64.tar.xz'
    }
    @{
      name        = 'fau'
      description = "Official Cygwin mirror at ftp.fau.de (University of Erlangen-Nuremberg); not compared from where this entry was written (Scoop still checks the hash)"
      '64bit'     = 'https://ftp.fau.de/cygwin/x86_64/release/cygwin/cygwin-$version-x86_64.tar.xz'
    }
  )
  zapret = @(
    @{
      name        = 'sourceforge'
      description = "SourceForge's automatic copy of the GitHub releases (project zapret.mirror), not run by the developer; same SHA-256 as GitHub for 72.13"
      '64bit'     = 'https://downloads.sourceforge.net/project/zapret.mirror/$tag/zapret-$tag.zip'
    }
  )
  zapret2 = @(
    @{
      name        = 'sourceforge'
      description = "SourceForge's automatic copy of the GitHub releases (project zapret2.mirror), not run by the developer; same SHA-256 as GitHub for 1.0.6"
      '64bit'     = 'https://downloads.sourceforge.net/project/zapret2.mirror/$tag/zapret2-$tag.zip'
    }
  )
  'zapret-discord-youtube' = @(
    @{
      name        = 'sourceforge'
      description = "SourceForge's automatic copy of the GitHub releases (project zapret-discord-youtube.mirror), not run by Flowseal, who says he runs no other download pages; same SHA-256 as GitHub for 1.10.4"
      '64bit'     = 'https://downloads.sourceforge.net/project/zapret-discord-youtube.mirror/$tag/zapret-discord-youtube-$tag.zip'
    }
  )
  'TG-WS-Proxy' = @(
    @{
      name        = 'sourceforge'
      description = "SourceForge's automatic copy of the GitHub releases (project tg-ws-proxy.mirror), which upstream's release notes offer to those who cannot reach GitHub; same SHA-256 as GitHub for 1.11.4 (all three builds)"
      '64bit'     = 'https://downloads.sourceforge.net/project/tg-ws-proxy.mirror/$tag/TgWsProxy_windows.exe#/TgWsProxy.exe'
      '32bit'     = 'https://downloads.sourceforge.net/project/tg-ws-proxy.mirror/$tag/TgWsProxy_windows_7_32bit.exe#/TgWsProxy.exe'
      arm64       = 'https://downloads.sourceforge.net/project/tg-ws-proxy.mirror/$tag/TgWsProxy_windows_arm64.exe#/TgWsProxy.exe'
    }
  )
}
