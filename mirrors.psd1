# Known mirrors for bin/Use-Mirror.ps1, read with Import-PowerShellDataFile (data only, no code runs).
# This is a .psd1 rather than .json because Scoop's CI checks every changed *.json file against the manifest schema.
#
# Format: app name (as in bucket/, any case) = list of mirrors. 'mirror1', 'mirror2', ... pick them by position.
#   name         short name, also accepted instead of 'mirrorN'
#   description  shown when listing mirrors
#   '64bit', '32bit', 'arm64'  URL for that architecture; 'url' for apps without architectures.
#                An array of URLs when the manifest downloads several files. '$version' is replaced
#                with the manifest's version (keep such URLs in single quotes).
@{
  TrueConf = @(
    @{
      name        = 'trueconf.ru'
      description = "TrueConf's Russian download server (OKB Progress, Moscow): same files, hashes and signatures as trueconf.com"
      '64bit'     = 'https://download.trueconf.ru/download/client/windows/trueconf_client_x64.msi'
      '32bit'     = 'https://download.trueconf.ru/download/client/windows/trueconf_client_x86.msi'
    }
  )
}
