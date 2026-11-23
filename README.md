# scoop-bucket

[![CI](https://github.com/Gesugao-san/scoop-bucket/actions/workflows/ci.yml/badge.svg)](https://github.com/Gesugao-san/scoop-bucket/actions/workflows/ci.yml) [![Excavator](https://github.com/Gesugao-san/scoop-bucket/actions/workflows/excavator.yml/badge.svg)](https://github.com/Gesugao-san/scoop-bucket/actions/workflows/excavator.yml) [![Security](https://github.com/Gesugao-san/scoop-bucket/actions/workflows/security.yml/badge.svg)](https://github.com/Gesugao-san/scoop-bucket/actions/workflows/security.yml)

Personal [Scoop](https://scoop.sh) bucket by [Gesugao-san](https://github.com/Gesugao-san), automated by CI and by [Claude](https://claude.ai): GitHub Actions keep manifests up to date and check them (see [Automation](docs/automation.md)), and Claude researches, writes and maintains the packages with the [skill](skills/scoop-bucket-add/SKILL.md) kept here.

## Contents

- [Usage](#usage)
- [Packages](#packages)
  - [Games](#games)
    - [Minecraft](#minecraft)
    - [EVE Online](#eve-online)
    - [Other games](#other-games)
    - [Mods and tools](#mods-and-tools)
  - [Apple tools](#apple-tools)
  - [Android tools](#android-tools)
  - [Communication](#communication)
    - [Chat and video calls](#chat-and-video-calls)
    - [P2P](#p2p)
  - [Network](#network)
    - [Browsers](#browsers)
    - [Proxies and VPN](#proxies-and-vpn)
    - [Censorship circumvention](#censorship-circumvention)
    - [Services](#services)
    - [Terminals](#terminals)
    - [CLI](#cli)
  - [OS maintenance](#os-maintenance)
  - [Hardware tools](#hardware-tools)
  - [Reverse engineering](#reverse-engineering)
  - [Drivers](#drivers)
  - [Redistributables](#redistributables)
  - [Databases](#databases)
- [Documentation](#documentation)
- [License](#license)
- [Moved sections](#moved-sections)

## Usage

However much you want to, you cannot use this repository for its intended purpose without [Scoop](https://scoop.sh), so install it first (and it's cool, I promise!). Run this from a regular (non-admin) PowerShell, as [Scoop's README](https://github.com/ScoopInstaller/Scoop#installation) says:

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
```

The first command lets PowerShell run Scoop's scripts; it is needed once per user. Scoop refuses to install from an elevated shell by default; see [ScoopInstaller/Install](https://github.com/ScoopInstaller/Install) for other options, such as a custom install folder.

Adding a bucket needs Git; install it through Scoop if it is missing. Scoop's Git package comes as a 7-Zip archive, so it needs 7-Zip too: Scoop would pull it in by itself, the command just names it:

```powershell
scoop install 7zip git
```

Add the bucket once:

```powershell
scoop bucket add gesu https://github.com/Gesugao-san/scoop-bucket
```

`gesu` is only a local name for the bucket; any other name works too.

Then install packages from it by name:

```powershell
scoop install gesu/<Package>
```

The install command for every package is under its category in [Packages](#packages). Packages marked `-g` install globally and need an elevated shell.

> [!TIP]
> **[UniGetUI](https://github.com/Devolutions/UniGetUI) is strongly recommended** for using this bucket. It is a window for Scoop and other package managers: it shows updates for everything installed in one list and updates it in a few clicks, and it shows the package icons this bucket provides. Add the bucket in UniGetUI's Scoop settings (or with the command above), then search for the package.

## Packages

Each package has a page with its notes: requirements, what the manifest does differently from upstream, and known issues. Packages are grouped by what they are for; a package is listed once, under its main use.

### Games

#### Minecraft

| Package | Upstream | About |
|---|---|---|
| [`NBT-Studio`](docs/packages/nbt-studio.md) | [tryashtar/nbt-studio](https://github.com/tryashtar/nbt-studio) | NBT editor for Minecraft |
| [`NBT-Explorer`](docs/packages/nbt-explorer.md) | [jaquadro/NBTExplorer](https://github.com/jaquadro/NBTExplorer) | NBT editor for Minecraft (the classic NBTExplorer) |
| [`Freesm-Launcher`](docs/packages/freesm-launcher.md) | [FreesmTeam/FreesmLauncher](https://github.com/FreesmTeam/FreesmLauncher) | Minecraft launcher, a Prism Launcher fork |
| [`Pomme`](docs/packages/pomme.md) | [PommeMC/Client](https://github.com/PommeMC/Client) | Minecraft: Java Edition client in Rust and Vulkan; vanilla servers 1.20 to 26.3 |
| [`Horizon-Launcher`](docs/packages/horizon-launcher.md) | [horizon-rust/horizon](https://github.com/horizon-rust/horizon) | Launcher for Horizon, Minecraft 26.3 rewritten in Rust; telemetry off |
| [`Pumpkin`](docs/packages/pumpkin.md) | [pumpkinmc.org](https://pumpkinmc.org/) ([Pumpkin-MC/Pumpkin](https://github.com/Pumpkin-MC/Pumpkin)) | Multithreaded Minecraft server in Rust, Java and Bedrock clients |
| [`SteelMC`](docs/packages/steelmc.md) | [steelmc.dev](https://steelmc.dev/) ([Steel-Foundation/SteelMC](https://github.com/Steel-Foundation/SteelMC)) | Minecraft server in Rust tracking the latest release, pre-alpha |
| [`FerrumC`](docs/packages/ferrumc.md) | [ferrumc.com](https://www.ferrumc.com/) ([ferrumc-rs/ferrumc](https://github.com/ferrumc-rs/ferrumc)) | Minecraft 1.21.8 server in Rust, imports vanilla worlds |
| [`MCHPRS`](docs/packages/mchprs.md) | [MCHPR/MCHPRS](https://github.com/MCHPR/MCHPRS) | Minecraft 1.20.4 creative server for computational redstone |

```powershell
scoop install gesu/NBT-Studio
scoop install gesu/NBT-Explorer
scoop install gesu/Freesm-Launcher
scoop install gesu/Pomme              # Minecraft client in Rust
scoop install gesu/Horizon-Launcher   # Minecraft rewritten in Rust, needs your copy of 26.3
scoop install gesu/Pumpkin            # Minecraft server in Rust (Java and Bedrock)
scoop install gesu/SteelMC            # Minecraft server in Rust, pre-alpha
scoop install gesu/FerrumC            # Minecraft 1.21.8 server in Rust
scoop install gesu/MCHPRS             # Minecraft 1.20.4 redstone server in Rust
```

#### EVE Online

| Package | Upstream | About |
|---|---|---|
| [`jEveAssets`](docs/packages/jeveassets.md) | [GoldenGnu/jeveassets](https://github.com/GoldenGnu/jeveassets) | Asset and market manager for EVE Online |
| [`EVEMon`](docs/packages/evemon.md) | [mgoeppner/evemon](https://github.com/mgoeppner/evemon) | Character monitor and skill planner for EVE Online |
| [`EVE-IPH`](docs/packages/eve-iph.md) | [EVEIPH/LatestFiles](https://github.com/EVEIPH/LatestFiles) (EVEIPH, no license stated) | Industry calculator for EVE Online |

```powershell
scoop install gesu/jEveAssets   # needs Java 8+, suggests java/temurin-jre
scoop install gesu/EVEMon
scoop install gesu/EVE-IPH
```

#### Other games

| Package | Upstream | About |
|---|---|---|
| [`PlanetSide-2`](docs/packages/planetside-2.md) | [Steam app 218230](https://store.steampowered.com/app/218230/PlanetSide_2/) | PlanetSide 2 through Steam |
| [`PlanetSide-2-LaunchPad`](docs/packages/planetside-2-launchpad.md) | [planetside2.com](https://www.planetside2.com) (Daybreak Game Company) | PlanetSide 2 through Daybreak's own launcher |
| [`King-Arthurs-Gold`](docs/packages/king-arthurs-gold.md) | [kag2d.com](https://kag2d.com) (Transhuman Design, free to play; [Steam app 219830](https://store.steampowered.com/app/219830/King_Arthurs_Gold/)) | King Arthur's Gold, through Steam or standalone |

```powershell
scoop install gesu/PlanetSide-2             # through Steam
scoop install gesu/PlanetSide-2-LaunchPad   # standalone, elevated shell
scoop install gesu/King-Arthurs-Gold        # asks: Steam or standalone
```

#### Mods and tools

| Package | Upstream | About |
|---|---|---|
| [`Gale`](docs/packages/gale.md) | [Kesomannen/gale](https://github.com/Kesomannen/gale) | Mod manager for Thunderstore games |
| [`CKAN`](docs/packages/ckan.md) | [KSP-CKAN/CKAN](https://github.com/KSP-CKAN/CKAN) | Mod manager for Kerbal Space Program, self-contained .NET 10 build |
| [`CKAN-NetFx`](docs/packages/ckan-netfx.md) | [KSP-CKAN/CKAN](https://github.com/KSP-CKAN/CKAN) | Mod manager for Kerbal Space Program, small .NET Framework 4.8.1 build |
| [`Borderless-Gaming`](docs/packages/borderless-gaming.md) | [legacy.borderlessgam.ing](https://legacy.borderlessgam.ing) ([andrewmd5/Borderless-Gaming](https://github.com/andrewmd5/Borderless-Gaming), GPL-2.0) | Borderless fullscreen for windowed games (free legacy edition) |

```powershell
scoop install gesu/Gale         # Thunderstore mod manager
scoop install gesu/CKAN         # KSP mod manager, .NET 10 build
scoop install gesu/CKAN-NetFx   # KSP mod manager, .NET Framework build; one of the two
scoop install gesu/Borderless-Gaming
```

### Apple tools

| Package | Upstream | About |
|---|---|---|
| [`iloader`](docs/packages/iloader.md) | [nab138/iloader](https://github.com/nab138/iloader) | Sideloads SideStore, LiveContainer or any IPA to iOS |
| [`Impactor`](docs/packages/impactor.md) | [claration/impactor](https://github.com/claration/impactor) | iOS, iPadOS and tvOS sideloading tool |

```powershell
scoop install gesu/iloader
scoop install gesu/Impactor
```

### Android tools

| Package | Upstream | About |
|---|---|---|
| [`Mi-Unlock`](docs/packages/mi-unlock.md) | [miui.com/unlock](https://www.miui.com/unlock/) (Xiaomi, freeware) | Xiaomi bootloader unlock tool |
| [`MTKClient`](docs/packages/mtkclient.md) | [bkerler/mtkclient](https://github.com/bkerler/mtkclient) | MediaTek flash tool, tracks upstream main |
| [`MTKClient-Release`](docs/packages/mtkclient-release.md) | [bkerler/mtkclient](https://github.com/bkerler/mtkclient) | MediaTek flash tool, latest release |
| [`mtk_uartboot`](docs/packages/mtk-uartboot.md) | [981213/mtk_uartboot](https://github.com/981213/mtk_uartboot) (Chuanhong Guo) | Boots MediaTek router SoCs over UART |

```powershell
scoop install gesu/Mi-Unlock
scoop install gesu/MTKClient           # builds with uv, needs internet
scoop install gesu/MTKClient-Release   # latest release; install one of the two
scoop install gesu/mtk_uartboot
```

### Communication

#### Chat and video calls

| Package | Upstream | About |
|---|---|---|
| [`Halloy`](docs/packages/halloy.md) | [halloy.chat](https://halloy.chat) ([squidowl/halloy](https://github.com/squidowl/halloy), GPL-3.0) | IRC client; history and config kept across updates |
| [`TrueConf`](docs/packages/trueconf.md) | [trueconf.com](https://trueconf.com/downloads/windows.html) (TrueConf, proprietary) | Video conferencing client; Russian (potentially, and surely, government and private corporate spy) software. I had never heard of this program until she asked me to install it for work, when this year, for the first time in my life, after so many years of talking, friendship, love and literally growing up together since we were kids at school, she asked me to fix her computer. That is exactly why I, with pride, confusion and unbearable pain, dedicate this package manifest to my beloved, who either doesn't care about me or really is so busy that she can't answer me more often than once every six months. Please make it stop. |

```powershell
scoop install gesu/Halloy   # IRC client
scoop install gesu/TrueConf
```

#### P2P

| Package | Upstream | About |
|---|---|---|
| [`Tixati`](docs/packages/tixati.md) | [tixati.com](https://tixati.com) (Tixati Software, freeware) | BitTorrent client |
| [`Fopnu`](docs/packages/fopnu.md) | [fopnu.com](https://www.fopnu.com) (Tixati Software, freeware) | Decentralized file sharing from Tixati's author |
| [`DarkMX`](docs/packages/darkmx.md) | [darkmx.app](https://darkmx.app) (Tixati Software, freeware) | Anonymous file sharing and chat over Tor |
| [`WinMX`](docs/packages/winmx.md) | [WinMX Community Patch](https://patch.winmxconex.com) ([WinMXWorld](https://www.winmxworld.com)) | WinMX 3.54 with the community patch |

```powershell
scoop install gesu/Tixati
scoop install gesu/Fopnu
scoop install gesu/DarkMX
scoop install gesu/WinMX   # setup wizard, elevated shell
```

### Network

#### Browsers

| Package | Upstream | About |
|---|---|---|
| [`Cromite`](docs/packages/cromite.md) | [cromite.org](https://www.cromite.org/) ([uazo/cromite](https://github.com/uazo/cromite), GPL-3.0) | Privacy-focused Chromium fork with ad blocking; profile kept across updates, links open in it |

```powershell
scoop install gesu/Cromite   # privacy-focused Chromium fork
```

#### Proxies and VPN

| Package | Upstream | About |
|---|---|---|
| [`Privoxy`](docs/packages/privoxy.md) | [privoxy.org](https://www.privoxy.org) ([SourceForge](https://sourceforge.net/projects/ijbswa/files/Win32/)) | Filtering web proxy |
| [`Radmin-VPN`](docs/packages/radmin-vpn.md) | [radmin-vpn.com](https://www.radmin-vpn.com) (Famatech, freeware) | Virtual LAN over the internet |

```powershell
scoop install gesu/Privoxy
scoop install gesu/Radmin-VPN
```

#### Censorship circumvention

For getting past the [GFW](https://enwp.org/Great_Firewall) and its imitators.

| Package | Upstream | About |
|---|---|---|
| [`RealiTLScanner`](docs/packages/realitlscanner.md) | [XTLS/RealiTLScanner](https://github.com/XTLS/RealiTLScanner) | Finds TLS 1.3 + HTTP/2 servers to use as Xray REALITY targets |
| [`RealiTLScanner-GUI`](docs/packages/realitlscanner-gui.md) | [EikeiDev/RealiTLScanner-GUI](https://github.com/EikeiDev/RealiTLScanner-GUI) | Windows interface for `RealiTLScanner`: live log, results table |

```powershell
scoop install gesu/RealiTLScanner       # finds TLS targets for Xray REALITY
scoop install gesu/RealiTLScanner-GUI   # window for RealiTLScanner, .NET Desktop Runtime
```

#### Services

| Package | Upstream | About |
|---|---|---|
| [`NetTime`](docs/packages/nettime.md) | [timesynctool.com](https://www.timesynctool.com) ([SourceForge](https://sourceforge.net/projects/nettime/)) | SNTP time sync service |
| [`Tftpd64`](docs/packages/tftpd64.md) | [pjo2.github.io/tftpd64](https://pjo2.github.io/tftpd64/) ([PJO2/tftpd64](https://github.com/PJO2/tftpd64), Philippe Jounin) | TFTP, DHCP, DNS, SNTP and Syslog servers |

```powershell
scoop install -g gesu/NetTime   # global, from an elevated shell
scoop install gesu/Tftpd64
```

#### Terminals

| Package | Upstream | About |
|---|---|---|
| [`PuTTY`](docs/packages/putty.md) | [chiark.greenend.org.uk/~sgtatham/putty](https://www.chiark.greenend.org.uk/~sgtatham/putty/) (Simon Tatham) | SSH, Telnet and serial client |
| [`Tabby`](docs/packages/tabby.md) | [tabby.sh](https://tabby.sh) ([Eugeny/tabby](https://github.com/Eugeny/tabby), MIT) | Terminal with SSH, SFTP and serial |

```powershell
scoop install gesu/PuTTY
scoop install gesu/Tabby
```

#### CLI

| Package | Upstream | About |
|---|---|---|
| [`doggo`](docs/packages/doggo.md) | [mr-karan/doggo](https://github.com/mr-karan/doggo) | DNS client with readable output; DoT, DoH, DoQ, DNSCrypt |
| [`dnslookup`](docs/packages/dnslookup.md) | [ameshkov/dnslookup](https://github.com/ameshkov/dnslookup) | One DNS query over any protocol, including DoH, DoT, DoQ, DNSCrypt |
| [`q-DNS`](docs/packages/q-dns.md) | [natesales/q](https://github.com/natesales/q) | DNS client with DoT, DoH, DoQ, ODoH and DNSCrypt (command `qdns`) |

```powershell
scoop install gesu/doggo
scoop install gesu/dnslookup
scoop install gesu/q-DNS   # command qdns, not q
```

### OS maintenance

| Package | Upstream | About |
|---|---|---|
| [`Bulk-Crap-Uninstaller`](docs/packages/bulk-crap-uninstaller.md) | [BCUninstaller/Bulk-Crap-Uninstaller](https://github.com/BCUninstaller/Bulk-Crap-Uninstaller) | Bulk program uninstaller with leftover cleanup |
| [`UltraDefrag`](docs/packages/ultradefrag.md) | [SourceForge](https://sourceforge.net/projects/ultradefrag/) (GPL, last open source release) | Disk defragmenter, last open source release |
| [`JkDefrag`](docs/packages/jkdefrag.md) | [JkDefrag Portable](https://portableapps.com/apps/utilities/jkdefrag_portable) (PortableApps.com; JkDefrag by Jeroen Kessels) | Disk defragmenter and optimizer |

```powershell
scoop install gesu/Bulk-Crap-Uninstaller   # runs elevated (UAC prompt)
scoop install gesu/UltraDefrag             # runs elevated (UAC prompt)
scoop install gesu/JkDefrag                # runs elevated (UAC prompt)
```

### Hardware tools

| Package | Upstream | About |
|---|---|---|
| [`Victoria`](docs/packages/victoria.md) | [hdd.by](https://hdd.by/victoria/) (Sergei Kazanskij, freeware) | HDD and SSD diagnostics |
| [`Samsung-Magician`](docs/packages/samsung-magician.md) | [Samsung Semiconductor](https://semiconductor.samsung.com/consumer-storage/magician/) (freeware) | Management tool for Samsung SSDs |
| [`OCCT`](docs/packages/occt.md) | [ocbase.com](https://www.ocbase.com/occt-personal-use) (OCBASE, Personal edition) | Stability check and stress test tool |

```powershell
scoop install gesu/Victoria   # runs elevated (UAC prompt)
scoop install gesu/Samsung-Magician
scoop install gesu/OCCT       # runs elevated (UAC prompt)
```

### Reverse engineering

| Package | Upstream | About |
|---|---|---|
| [`Ghidra`](docs/packages/ghidra.md) | [NationalSecurityAgency/ghidra](https://github.com/NationalSecurityAgency/ghidra) | Reverse engineering framework |
| [`x64dbg`](docs/packages/x64dbg.md) | [x64dbg/x64dbg](https://github.com/x64dbg/x64dbg) | x64 and x32 debugger |
| [`dnSpyEx`](docs/packages/dnspyex.md) | [dnSpyEx/dnSpy](https://github.com/dnSpyEx/dnSpy) | .NET and Unity debugger, decompiler and assembly editor |

```powershell
scoop install gesu/Ghidra   # needs JDK 25
scoop install gesu/x64dbg
scoop install gesu/dnSpyEx
```

### Drivers

| Package | Upstream | About |
|---|---|---|
| [`Apple-Mobile-Drivers-Installer`](docs/packages/apple-mobile-drivers-installer.md) | [NelloKudo/Apple-Mobile-Drivers-Installer](https://github.com/NelloKudo/Apple-Mobile-Drivers-Installer) | Installs Apple USB and tethering drivers |
| [`Apple-Mobile-Device-Support`](docs/packages/apple-mobile-device-support.md) | [Apple](https://support.apple.com/106372) (from the iTunes installer) | Apple Mobile Device Support without iTunes |
| [`Google-USB-Driver`](docs/packages/google-usb-driver.md) | [developer.android.com](https://developer.android.com/studio/run/win-usb) (Google, proprietary) | WinUSB driver for adb and fastboot |
| [`UsbDk`](docs/packages/usbdk.md) | [daynix/UsbDk](https://github.com/daynix/UsbDk) (Daynix / Red Hat, Apache-2.0) | USB filter driver, a libusb backend |
| [`Zadig`](docs/packages/zadig.md) | [zadig.akeo.ie](https://zadig.akeo.ie) ([pbatard/libwdi](https://github.com/pbatard/libwdi), Pete Batard) | Installs generic USB drivers (WinUSB, libusb) |
| [`DriverStore-Explorer`](docs/packages/driverstore-explorer.md) | [lostindark/DriverStoreExplorer](https://github.com/lostindark/DriverStoreExplorer) | Manages driver packages in the Windows driver store |

```powershell
scoop install gesu/Apple-Mobile-Drivers-Installer
scoop install -g gesu/Apple-Mobile-Device-Support   # global, from an elevated shell
scoop install gesu/Google-USB-Driver                # driver, elevated shell
scoop install gesu/UsbDk                            # driver, elevated shell
scoop install gesu/Zadig                            # asks for admin rights (UAC) on start
scoop install gesu/DriverStore-Explorer             # runs elevated (UAC prompt)
```

### Redistributables

| Package | Upstream | About |
|---|---|---|
| [`NetFx-4.8.1`](docs/packages/netfx-4.8.1.md) | [Microsoft](https://dotnet.microsoft.com/download/dotnet-framework/net481) (proprietary) | .NET Framework 4.8.1 runtime, installed only where Windows lacks it |

```powershell
scoop install -g gesu/NetFx-4.8.1   # global, elevated shell; for CKAN-NetFx on older Windows
```

### Databases

| Package | Upstream | About |
|---|---|---|
| [`Loyalsoldier-GeoIP`](docs/packages/loyalsoldier-geoip.md) | [Loyalsoldier/geoip](https://github.com/Loyalsoldier/geoip) | Weekly GeoIP databases for MaxMind readers and Xray; used by `RealiTLScanner` |

```powershell
scoop install gesu/Loyalsoldier-GeoIP   # GeoIP databases (.mmdb, .dat)
```

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
