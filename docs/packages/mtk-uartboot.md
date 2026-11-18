# mtk_uartboot

| | |
|---|---|
| Manifest | [`bucket/mtk_uartboot.json`](../../bucket/mtk_uartboot.json) |
| Upstream | [981213/mtk_uartboot](https://github.com/981213/mtk_uartboot) (Chuanhong Guo) |
| Install | `scoop install gesu/mtk_uartboot` |

Loads and starts a bootloader over UART on MediaTek router SoCs (MT7622, MT7629, MT798x such as Banana Pi R3/R4 or GL.iNet) with secure boot disabled: the BootROM download protocol MTKClient uses over USB, here over a 3.3 V serial console, to RAM-boot BL2 and an FIP for unbricking. Command `mtk_uartboot`; no shortcut, it is a console tool. **0.1.1 (2 March 2024) is still the current version**; `master` has one later commit (December 2024, a small refactor) and no newer release, and no fork publishes newer builds. Uses the official static `x86_64-pc-windows-msvc` zip, the only Windows build (on ARM64 Windows Scoop falls back to it, it runs emulated). License: the repository is AGPL-3.0 (LICENSE added 19 March 2024), while `Cargo.toml` of 0.1.1 still says `GPL-2`. Also in the [lemon](https://github.com/hoilc/scoop-lemon) bucket; hash taken from it (Scoop checks it on install).

[All packages](../../README.md#packages)
