# Radmin-VPN

| | |
|---|---|
| Manifest | [`bucket/Radmin-VPN.json`](../../bucket/Radmin-VPN.json) |
| Upstream | [radmin-vpn.com](https://www.radmin-vpn.com) (Famatech, freeware) |
| Install | `scoop install gesu/Radmin-VPN` |

**Not portable**: runs the official installer silently (Inno Setup wrapping an MSI), which adds a network adapter driver and a service, like the `-np` packages in Scoop's [Nonportable](https://github.com/ScoopInstaller/Nonportable) bucket. Install, update and uninstall from an elevated shell. Updates install over the existing copy, so networks and settings are kept; `scoop uninstall` removes it through its MSI entry. Hash checked against [winget](https://github.com/microsoft/winget-pkgs/tree/master/manifests/f/Famatech/RadminVPN). The Inno Setup wrapper holds a WiX MSI (`Radmin VPN 2.1.1`, product code `{5560C73C-AE48-49C9-842C-8341D592F231}`); the network driver is signed by Microsoft's Windows Hardware Compatibility Publisher, so it installs without a trust prompt. The installer also adds Radmin Viewer 3, a desktop shortcut and a logon autostart.

[All packages](../../README.md#packages)
