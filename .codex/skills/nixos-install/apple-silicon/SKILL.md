---
name: apple-silicon
description: "Apple Silicon (Asahi) specifics for the nixos-install skill. Trigger when installing NixOS on Apple Silicon hardware."
---

# Apple Silicon (Asahi) — incremental

Use together with parent `nixos-install`. Keep concise; extend only after steps are verified.

Meta: log only confirmed steps; append new ones right after you perform them.

## Steps we have confirmed
- Networking on live ISO: `iwctl` → `station wlan0 get-networks` → `station wlan0 connect <ssid>` (NetworkManager absent).

## Next details to capture after execution
- ESP + LUKS partitioning, firmware copy (`all_firmware.tar.gz`, `kernelcache.release.*`) into persistent `/etc/nixos/firmware`.
- Asahi kernel selection in flake.
- Any quirks observed during install.

## References
- See `links.md` for the Apple Silicon UEFI install guide; open only when needed.
