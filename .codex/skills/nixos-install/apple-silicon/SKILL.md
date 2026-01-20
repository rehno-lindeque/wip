---
name: apple-silicon
description: "Apple Silicon (Asahi) specifics for the nixos-install skill. Trigger when installing NixOS on Apple Silicon hardware."
---

# Apple Silicon (Asahi)

Use together with parent `nixos-install`. Keep concise; extend only after steps are verified.

Meta: log only confirmed steps; append new ones right after you perform them.

## 1. Setup wifi

```
iwctl
[iwd]# station wlan0 scan
[iwd]# station wlan0 get-networks
[iwd]# station wlan0 connect <ssid>
```

## 2. Get root
```
sudo su
```

# 3. Install macbookpro2025
```
nix --extra-experimental-features "nix-command flakes" run github:rehno-lindeque/wip?dir=my-nixos-configurations#install-macbookpro2025 --refresh
```

## References
- See `links.md` for the Apple Silicon UEFI install guide; open only when needed.
