# scoop-bucket

[![CI](https://github.com/Gesugao-san/scoop-bucket/actions/workflows/ci.yml/badge.svg)](https://github.com/Gesugao-san/scoop-bucket/actions/workflows/ci.yml) [![Excavator](https://github.com/Gesugao-san/scoop-bucket/actions/workflows/excavator.yml/badge.svg)](https://github.com/Gesugao-san/scoop-bucket/actions/workflows/excavator.yml) [![Security](https://github.com/Gesugao-san/scoop-bucket/actions/workflows/security.yml/badge.svg)](https://github.com/Gesugao-san/scoop-bucket/actions/workflows/security.yml)

Personal [Scoop](https://scoop.sh) bucket by [Gesugao-san](https://github.com/Gesugao-san).

## Usage

Add the bucket once:

```powershell
scoop bucket add gesu https://github.com/Gesugao-san/scoop-bucket
```

`gesu` is only a local name for the bucket; any other name works too.

Then install packages from it:

```powershell
scoop install gesu/NBT-Studio
scoop install gesu/NBT-Explorer
scoop install gesu/iloader
scoop install gesu/Impactor
scoop install gesu/Apple-Mobile-Drivers-Installer
scoop install -g gesu/Apple-Mobile-Device-Support   # global, from an elevated shell
scoop install gesu/Privoxy
scoop install -g gesu/NetTime   # global, from an elevated shell
scoop install gesu/Freesm-Launcher
scoop install gesu/Radmin-VPN
scoop install gesu/Samsung-Magician
scoop install gesu/PlanetSide-2             # through Steam
scoop install gesu/PlanetSide-2-LaunchPad   # standalone, elevated shell
scoop install gesu/King-Arthurs-Gold        # asks: Steam or standalone
scoop install gesu/Borderless-Gaming
scoop install gesu/Gale                     # Thunderstore mod manager
scoop install gesu/CKAN                     # KSP mod manager, .NET 10 build
scoop install gesu/CKAN-NetFx               # KSP mod manager, .NET Framework build; one of the two
scoop install -g gesu/NetFx-4.8.1           # global, elevated shell; for CKAN-NetFx on older Windows
scoop install gesu/Tixati
scoop install gesu/Fopnu
scoop install gesu/DarkMX
scoop install gesu/WinMX                    # setup wizard, elevated shell
scoop install gesu/DriverStore-Explorer     # runs elevated (UAC prompt)
scoop install gesu/Google-USB-Driver        # driver, elevated shell
scoop install gesu/Mi-Unlock
scoop install gesu/MTKClient                # builds with uv, needs internet
scoop install gesu/MTKClient-Release        # latest release; install one of the two
scoop install gesu/mtk_uartboot
scoop install gesu/UsbDk                    # driver, elevated shell
scoop install gesu/Zadig                    # asks for admin rights (UAC) on start
scoop install gesu/PuTTY
scoop install gesu/Tabby
scoop install gesu/Tftpd64
scoop install gesu/doggo
scoop install gesu/dnslookup
scoop install gesu/q-DNS                   # command qdns, not q
scoop install gesu/RealiTLScanner           # finds TLS targets for Xray REALITY
scoop install gesu/RealiTLScanner-GUI       # window for RealiTLScanner, .NET Desktop Runtime
scoop install gesu/Loyalsoldier-GeoIP       # GeoIP databases (.mmdb, .dat)
scoop install gesu/OCCT                     # runs elevated (UAC prompt)
scoop install gesu/Halloy                   # IRC client
scoop install gesu/TrueConf
scoop install gesu/Ghidra                   # needs JDK 25
scoop install gesu/x64dbg
scoop install gesu/dnSpyEx
scoop install gesu/Bulk-Crap-Uninstaller    # runs elevated (UAC prompt)
scoop install gesu/UltraDefrag              # runs elevated (UAC prompt)
scoop install gesu/JkDefrag                 # runs elevated (UAC prompt)
scoop install gesu/Victoria                 # runs elevated (UAC prompt)
```

Works in [UniGetUI](https://github.com/Devolutions/UniGetUI) too: add the bucket in UniGetUI's Scoop settings (or with the command above), then search for the package.

## Packages

Each package has a page with its notes: requirements, what the manifest does differently from upstream, and known issues.

| Package | Upstream | About |
|---|---|---|
| [`NBT-Studio`](docs/packages/nbt-studio.md) | [tryashtar/nbt-studio](https://github.com/tryashtar/nbt-studio) | NBT editor for Minecraft |
| [`NBT-Explorer`](docs/packages/nbt-explorer.md) | [jaquadro/NBTExplorer](https://github.com/jaquadro/NBTExplorer) | NBT editor for Minecraft (the classic NBTExplorer) |
| [`iloader`](docs/packages/iloader.md) | [nab138/iloader](https://github.com/nab138/iloader) | Sideloads SideStore, LiveContainer or any IPA to iOS |
| [`Impactor`](docs/packages/impactor.md) | [claration/impactor](https://github.com/claration/impactor) | iOS, iPadOS and tvOS sideloading tool |
| [`Apple-Mobile-Drivers-Installer`](docs/packages/apple-mobile-drivers-installer.md) | [NelloKudo/Apple-Mobile-Drivers-Installer](https://github.com/NelloKudo/Apple-Mobile-Drivers-Installer) | Installs Apple USB and tethering drivers |
| [`Apple-Mobile-Device-Support`](docs/packages/apple-mobile-device-support.md) | [Apple](https://support.apple.com/106372) (from the iTunes installer) | Apple Mobile Device Support without iTunes |
| [`Privoxy`](docs/packages/privoxy.md) | [privoxy.org](https://www.privoxy.org) ([SourceForge](https://sourceforge.net/projects/ijbswa/files/Win32/)) | Filtering web proxy |
| [`NetTime`](docs/packages/nettime.md) | [timesynctool.com](https://www.timesynctool.com) ([SourceForge](https://sourceforge.net/projects/nettime/)) | SNTP time sync service |
| [`Freesm-Launcher`](docs/packages/freesm-launcher.md) | [FreesmTeam/FreesmLauncher](https://github.com/FreesmTeam/FreesmLauncher) | Minecraft launcher, a Prism Launcher fork |
| [`Radmin-VPN`](docs/packages/radmin-vpn.md) | [radmin-vpn.com](https://www.radmin-vpn.com) (Famatech, freeware) | Virtual LAN over the internet |
| [`Samsung-Magician`](docs/packages/samsung-magician.md) | [Samsung Semiconductor](https://semiconductor.samsung.com/consumer-storage/magician/) (freeware) | Management tool for Samsung SSDs |
| [`PlanetSide-2`](docs/packages/planetside-2.md) | [Steam app 218230](https://store.steampowered.com/app/218230/PlanetSide_2/) | PlanetSide 2 through Steam |
| [`PlanetSide-2-LaunchPad`](docs/packages/planetside-2-launchpad.md) | [planetside2.com](https://www.planetside2.com) (Daybreak Game Company) | PlanetSide 2 through Daybreak's own launcher |
| [`King-Arthurs-Gold`](docs/packages/king-arthurs-gold.md) | [kag2d.com](https://kag2d.com) (Transhuman Design, free to play; [Steam app 219830](https://store.steampowered.com/app/219830/King_Arthurs_Gold/)) | King Arthur's Gold, through Steam or standalone |
| [`Borderless-Gaming`](docs/packages/borderless-gaming.md) | [legacy.borderlessgam.ing](https://legacy.borderlessgam.ing) ([andrewmd5/Borderless-Gaming](https://github.com/andrewmd5/Borderless-Gaming), GPL-2.0) | Borderless fullscreen for windowed games (free legacy edition) |
| [`Gale`](docs/packages/gale.md) | [Kesomannen/gale](https://github.com/Kesomannen/gale) | Mod manager for Thunderstore games |
| [`CKAN`](docs/packages/ckan.md) | [KSP-CKAN/CKAN](https://github.com/KSP-CKAN/CKAN) | Mod manager for Kerbal Space Program, self-contained .NET 10 build |
| [`CKAN-NetFx`](docs/packages/ckan-netfx.md) | [KSP-CKAN/CKAN](https://github.com/KSP-CKAN/CKAN) | Mod manager for Kerbal Space Program, small .NET Framework 4.8.1 build |
| [`NetFx-4.8.1`](docs/packages/netfx-4.8.1.md) | [Microsoft](https://dotnet.microsoft.com/download/dotnet-framework/net481) (proprietary) | .NET Framework 4.8.1 runtime, installed only where Windows lacks it |
| [`Tixati`](docs/packages/tixati.md) | [tixati.com](https://tixati.com) (Tixati Software, freeware) | BitTorrent client |
| [`Fopnu`](docs/packages/fopnu.md) | [fopnu.com](https://www.fopnu.com) (Tixati Software, freeware) | Decentralized file sharing from Tixati's author |
| [`DarkMX`](docs/packages/darkmx.md) | [darkmx.app](https://darkmx.app) (Tixati Software, freeware) | Anonymous file sharing and chat over Tor |
| [`WinMX`](docs/packages/winmx.md) | [WinMX Community Patch](https://patch.winmxconex.com) ([WinMXWorld](https://www.winmxworld.com)) | WinMX 3.54 with the community patch |
| [`DriverStore-Explorer`](docs/packages/driverstore-explorer.md) | [lostindark/DriverStoreExplorer](https://github.com/lostindark/DriverStoreExplorer) | Manages driver packages in the Windows driver store |
| [`Google-USB-Driver`](docs/packages/google-usb-driver.md) | [developer.android.com](https://developer.android.com/studio/run/win-usb) (Google, proprietary) | WinUSB driver for adb and fastboot |
| [`Mi-Unlock`](docs/packages/mi-unlock.md) | [miui.com/unlock](https://www.miui.com/unlock/) (Xiaomi, freeware) | Xiaomi bootloader unlock tool |
| [`MTKClient`](docs/packages/mtkclient.md) | [bkerler/mtkclient](https://github.com/bkerler/mtkclient) | MediaTek flash tool, tracks upstream main |
| [`MTKClient-Release`](docs/packages/mtkclient-release.md) | [bkerler/mtkclient](https://github.com/bkerler/mtkclient) | MediaTek flash tool, latest release |
| [`mtk_uartboot`](docs/packages/mtk-uartboot.md) | [981213/mtk_uartboot](https://github.com/981213/mtk_uartboot) (Chuanhong Guo) | Boots MediaTek router SoCs over UART |
| [`UsbDk`](docs/packages/usbdk.md) | [daynix/UsbDk](https://github.com/daynix/UsbDk) (Daynix / Red Hat, Apache-2.0) | USB filter driver, a libusb backend |
| [`Zadig`](docs/packages/zadig.md) | [zadig.akeo.ie](https://zadig.akeo.ie) ([pbatard/libwdi](https://github.com/pbatard/libwdi), Pete Batard) | Installs generic USB drivers (WinUSB, libusb) |
| [`PuTTY`](docs/packages/putty.md) | [chiark.greenend.org.uk/~sgtatham/putty](https://www.chiark.greenend.org.uk/~sgtatham/putty/) (Simon Tatham) | SSH, Telnet and serial client |
| [`Tabby`](docs/packages/tabby.md) | [tabby.sh](https://tabby.sh) ([Eugeny/tabby](https://github.com/Eugeny/tabby), MIT) | Terminal with SSH, SFTP and serial |
| [`Tftpd64`](docs/packages/tftpd64.md) | [pjo2.github.io/tftpd64](https://pjo2.github.io/tftpd64/) ([PJO2/tftpd64](https://github.com/PJO2/tftpd64), Philippe Jounin) | TFTP, DHCP, DNS, SNTP and Syslog servers |
| [`doggo`](docs/packages/doggo.md) | [mr-karan/doggo](https://github.com/mr-karan/doggo) | DNS client with readable output; DoT, DoH, DoQ, DNSCrypt |
| [`dnslookup`](docs/packages/dnslookup.md) | [ameshkov/dnslookup](https://github.com/ameshkov/dnslookup) | One DNS query over any protocol, including DoH, DoT, DoQ, DNSCrypt |
| [`q-DNS`](docs/packages/q-dns.md) | [natesales/q](https://github.com/natesales/q) | DNS client with DoT, DoH, DoQ, ODoH and DNSCrypt (command `qdns`) |
| [`RealiTLScanner`](docs/packages/realitlscanner.md) | [XTLS/RealiTLScanner](https://github.com/XTLS/RealiTLScanner) | Finds TLS 1.3 + HTTP/2 servers to use as Xray REALITY targets |
| [`RealiTLScanner-GUI`](docs/packages/realitlscanner-gui.md) | [EikeiDev/RealiTLScanner-GUI](https://github.com/EikeiDev/RealiTLScanner-GUI) | Windows interface for `RealiTLScanner`: live log, results table |
| [`Loyalsoldier-GeoIP`](docs/packages/loyalsoldier-geoip.md) | [Loyalsoldier/geoip](https://github.com/Loyalsoldier/geoip) | Weekly GeoIP databases for MaxMind readers and Xray; used by `RealiTLScanner` |
| [`OCCT`](docs/packages/occt.md) | [ocbase.com](https://www.ocbase.com/occt-personal-use) (OCBASE, Personal edition) | Stability check and stress test tool |
| [`Halloy`](docs/packages/halloy.md) | [halloy.chat](https://halloy.chat) ([squidowl/halloy](https://github.com/squidowl/halloy), GPL-3.0) | IRC client; history and config kept across updates |
| [`TrueConf`](docs/packages/trueconf.md) | [trueconf.com](https://trueconf.com/downloads/windows.html) (TrueConf, proprietary) | Video conferencing client |
| [`Ghidra`](docs/packages/ghidra.md) | [NationalSecurityAgency/ghidra](https://github.com/NationalSecurityAgency/ghidra) | Reverse engineering framework |
| [`x64dbg`](docs/packages/x64dbg.md) | [x64dbg/x64dbg](https://github.com/x64dbg/x64dbg) | x64 and x32 debugger |
| [`dnSpyEx`](docs/packages/dnspyex.md) | [dnSpyEx/dnSpy](https://github.com/dnSpyEx/dnSpy) | .NET and Unity debugger, decompiler and assembly editor |
| [`Bulk-Crap-Uninstaller`](docs/packages/bulk-crap-uninstaller.md) | [BCUninstaller/Bulk-Crap-Uninstaller](https://github.com/BCUninstaller/Bulk-Crap-Uninstaller) | Bulk program uninstaller with leftover cleanup |
| [`UltraDefrag`](docs/packages/ultradefrag.md) | [SourceForge](https://sourceforge.net/projects/ultradefrag/) (GPL, last open source release) | Disk defragmenter, last open source release |
| [`JkDefrag`](docs/packages/jkdefrag.md) | [JkDefrag Portable](https://portableapps.com/apps/utilities/jkdefrag_portable) (PortableApps.com; JkDefrag by Jeroen Kessels) | Disk defragmenter and optimizer |
| [`Victoria`](docs/packages/victoria.md) | [hdd.by](https://hdd.by/victoria/) (Sergei Kazanskij, freeware) | HDD and SSD diagnostics |
| [`jEveAssets`](docs/packages/jeveassets.md) | [GoldenGnu/jeveassets](https://github.com/GoldenGnu/jeveassets) | Asset and market manager for EVE Online |
| [`EVEMon`](docs/packages/evemon.md) | [mgoeppner/evemon](https://github.com/mgoeppner/evemon) | Character monitor and skill planner for EVE Online |
| [`EVE-IPH`](docs/packages/eve-iph.md) | [EVEIPH/LatestFiles](https://github.com/EVEIPH/LatestFiles) (EVEIPH, no license stated) | Industry calculator for EVE Online |

## Documentation

- [Conventions](docs/conventions.md): programs installed outside Scoop, shortcuts, running programs, paths in notes and messages, manifest names, licenses, file associations
- [Installing from a mirror](docs/mirrors.md)
- [Automation](docs/automation.md): workflows, TLS check, EVE-IPH build check
- [Icons and screenshots](docs/icons.md) for UniGetUI
- [Research](docs/research/README.md) behind some manifests
- [Skill for adding a package](skills/scoop-bucket-add/SKILL.md), for Claude and other AI assistants

## License

The bucket's own files (manifests, scripts, documentation) are released into the public domain under the [Unlicense](LICENSE), like Scoop's [BucketTemplate](https://github.com/ScoopInstaller/BucketTemplate). It does not cover:

- the programs themselves, which keep their upstream licenses (see each [package page](docs/packages/));
- third-party license texts in [`licenses/`](licenses);
- icons and screenshots, whose sources and licenses are listed in [Icons and screenshots](docs/icons.md).

## Moved sections

These sections used to be in this README and now live in [`docs/`](docs/README.md). Old links to them land here:

- <a id="installing-from-a-mirror"></a>Installing from a mirror: [docs/mirrors.md](docs/mirrors.md)
- <a id="automation"></a>Automation: [docs/automation.md](docs/automation.md)
- <a id="running-workflows-by-hand"></a>Running workflows by hand: [docs/automation.md#running-workflows-by-hand](docs/automation.md#running-workflows-by-hand)
- <a id="checking-tls"></a>Checking TLS: [docs/automation.md#checking-tls](docs/automation.md#checking-tls)
- <a id="checking-eve-iph-builds"></a>Checking EVE-IPH builds: [docs/automation.md#checking-eve-iph-builds](docs/automation.md#checking-eve-iph-builds)
- <a id="notes"></a>Notes: [docs/research/README.md](docs/research/README.md)
- <a id="licenses"></a>Licenses: [docs/conventions.md#licenses](docs/conventions.md#licenses)
- <a id="file-associations"></a>File associations: [docs/conventions.md#file-associations](docs/conventions.md#file-associations)
- <a id="icons"></a>Icons: [docs/icons.md](docs/icons.md)
- <a id="icon-size-in-unigetui"></a>Icon size in UniGetUI: [docs/icons.md#icon-size-in-unigetui](docs/icons.md#icon-size-in-unigetui)
- <a id="screenshots"></a>Screenshots: [docs/icons.md#screenshots](docs/icons.md#screenshots)

Manifests only point to upstream release files; nothing else is redistributed here.
