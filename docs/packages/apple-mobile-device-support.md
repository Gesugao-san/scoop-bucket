# Apple-Mobile-Device-Support

| | |
|---|---|
| Manifest | [`bucket/Apple-Mobile-Device-Support.json`](../../bucket/Apple-Mobile-Device-Support.json) |
| Upstream | [Apple](https://support.apple.com/106372) (from the iTunes installer) |
| Install | `scoop install -g gesu/Apple-Mobile-Device-Support   # global, from an elevated shell` |

Apple Mobile Device Support (AMDS) without iTunes: the *Apple Mobile Device Service*, Apple's usbmuxd, which iTunes, `iloader` and `Impactor` talk to. **Global install only** (`scoop install -g`, elevated shell): AMDS is a per-machine MSI that installs into `Program Files\Common Files\Apple` and shows up in Settings > Apps; Scoop keeps only `AppleMobileDeviceSupport64.msi` from `iTunes64Setup.exe` (checked for Apple's signature) and runs `msiexec` ([`scripts/apple-mobile-device-support/Invoke-Amds.ps1`](../../scripts/apple-mobile-device-support/Invoke-Amds.ps1)). An AMDS that is already installed is upgraded if older, otherwise only taken over; services that depend on AMDS are paused during the update and started again. Install stops if the service exists without the MSI. `scoop uninstall` keeps AMDS while iTunes is installed. The version is AMDS's own, not iTunes': `checkver` follows Apple's permanent link and downloads iTunes (~200 MB) only when it points to a new release ([`Get-AmdsRelease.ps1`](../../scripts/apple-mobile-device-support/Get-AmdsRelease.ps1)). No USB driver: that is what `Apple-Mobile-Drivers-Installer` adds.

[All packages](../../README.md#packages)
