{
  flake,
  pkgs,
  mdr,
  mkHelp,
  system,
  writeScript,
}: let
  nc = "\\e[0m"; # No Color
  white = "\\e[1;37m";
  yellow = "\\e[1;33m";
in {
  help = {
    type = "app";
    description = "display this help message";
    program =
      (mkHelp {
        name = "my-nixos-configurations";
        inherit flake system writeScript;
        additionalCommands = {
          "lsblk" = "check which device holds your thumb drive";
        };
        supplementalNotes = ''
          INSTALLER INSTRUCTIONS:

          1. Build the installer iso

          ${white}nix build .#installerIso${nc}

          2. Use dd to overwrite usb media with the iso image contents (${yellow}carefully!${nc}):

          ${white}sudo dd if=./result/iso/installer.iso of=/dev/sd${yellow}X${white} bs=1MB${nc}
        '';
      })
      .outPath;
  };

  readme = {
    type = "app";
    description = "get more detailed help";
    program =
      (writeScript "readme" ''${mdr}/bin/mdr ${../README.md}'')
      .outPath;
  };

  install-macbookpro2025 = let
    installer = pkgs.writeShellApplication {
      name = "install-macbookpro2025";
      runtimeInputs = with pkgs; [
        coreutils
        e2fsprogs
        findutils
        gawk
        gnugrep
        gnutar
        iproute2
        mount
        nixos-install-tools
        rsync
        util-linux
      ];
      text = ''
        #!/usr/bin/env bash
        set -euo pipefail

        log() {
          printf '[%s] %s\n' "$(date -Iseconds)" "$*"
        }

        fail() {
          printf 'ERROR: %s\n' "$*" >&2
          exit 1
        }

        require_cmd() {
          command -v "$1" >/dev/null 2>&1 || fail "Missing required command: $1"
        }

        for c in nixos-install lsblk blkid mount findmnt umount rsync awk mkfs.ext4; do
          require_cmd "$c"
        done

        if [[ $EUID -ne 0 ]]; then
          fail "Run as root"
        fi

        FLAKE_ROOT="''${FLAKE:-.}"
        INSTALL_SYSTEM="''${INSTALL_SYSTEM:-macbookpro2025-install}"
        BOOT_UUID="''${BOOT_UUID:-7414-141F}"
        NIX_UUID="''${NIX_UUID:-388b76d7-cb0d-4aef-80ee-13898a2ea81a}"
        MNT="''${MNT:-/mnt}"
        ESP_MNT="''${ESP_MNT:-$MNT/boot}"
        NIX_MNT="''${NIX_MNT:-$MNT/nix}"

        resolve_by_uuid() {
          local uuid="$1"
          blkid -U "$uuid" 2>/dev/null || true
        }

        ensure_device() {
          local label="$1"
          local uuid="$2"
          local fallback="$3"
          if [[ -n "$fallback" ]]; then
            echo "$fallback"
            return
          fi
          local dev
          dev="$(resolve_by_uuid "$uuid")"
          [[ -n "$dev" ]] || fail "Could not find $label device with UUID $uuid. Override with ${label^^}_DEV env var."
          echo "$dev"
        }

        BOOT_DEV="''${BOOT_DEV:-}"
        NIX_DEV="''${NIX_DEV:-}"

        BOOT_DEV="$(ensure_device boot "$BOOT_UUID" "$BOOT_DEV")"
        NIX_DEV="$(ensure_device nix "$NIX_UUID" "$NIX_DEV")"

        ensure_mountpoint() {
          local path="$1"
          mkdir -p "$path"
        }

        ensure_not_conflicting_mount() {
          local dev="$1"
          local path="$2"
          if findmnt -rno SOURCE,TARGET "$path" >/dev/null 2>&1; then
            local currentDev
            currentDev="$(findmnt -rno SOURCE "$path")"
            if [[ "$currentDev" != "$dev" ]]; then
              fail "$path already mounted from $currentDev; unmount it first"
            fi
          fi
        }

        maybe_format_nix() {
          local dev="$1"
          local fstype
          fstype="$(blkid -o value -s TYPE "$dev" 2>/dev/null || true)"
          if [[ -z "$fstype" ]]; then
            log "Formatting $dev as ext4 (label: nixos)"
            mkfs.ext4 -F -L nixos "$dev"
          elif [[ "$fstype" != "ext4" ]]; then
            fail "Device $dev has filesystem '$fstype'; expected ext4. Reformat manually if intended."
          else
            log "Device $dev already has ext4; leaving intact."
          fi
        }

        mount_if_needed() {
          local dev="$1"
          local path="$2"
          if findmnt -rno SOURCE "$path" >/dev/null 2>&1; then
            return
          fi
          log "Mounting $dev -> $path"
          mount "$dev" "$path"
        }

        ensure_mountpoint "$MNT"
        ensure_mountpoint "$ESP_MNT"
        ensure_mountpoint "$NIX_MNT"

        ensure_not_conflicting_mount "$BOOT_DEV" "$ESP_MNT"
        ensure_not_conflicting_mount "$NIX_DEV" "$NIX_MNT"

        maybe_format_nix "$NIX_DEV"
        mount_if_needed "$NIX_DEV" "$NIX_MNT"
        mount_if_needed "$BOOT_DEV" "$ESP_MNT"

        persist_root="$NIX_MNT/persistent"
        firmware_dest="$persist_root/etc/nixos/firmware"

        for dir in \
          "$persist_root" \
          "$persist_root/etc/nixos/firmware" \
          "$persist_root/tmp" \
          "$persist_root/var/lib/nixos" \
          "$persist_root/var/log"
        do
          mkdir -p "$dir"
        done

        copy_firmware_file() {
          local filename="$1"
          local src=""
          for candidate in \
            "$ESP_MNT/asahi/$filename" \
            "/boot/asahi/$filename"
          do
            if [[ -f "$candidate" ]]; then
              src="$candidate"
              break
            fi
          done

          local dest="$firmware_dest/$filename"
          if [[ -f "$dest" ]]; then
            log "Firmware already present: $dest"
            return
          fi

          if [[ -n "$src" ]]; then
            log "Copying firmware $filename from $src to $dest"
            rsync -av "$src" "$dest"
          else
            fail "Missing firmware file $filename (looked under $ESP_MNT/asahi and /boot/asahi)."
          fi
        }

        copy_firmware_file "all_firmware.tar.gz"
        copy_firmware_file "kernelcache.release.mac14j"

        log "Running nixos-install for $INSTALL_SYSTEM"
        nixos-install --root "$MNT" --flake "$FLAKE_ROOT#$INSTALL_SYSTEM" --no-channel-copy

        log "Installation complete. Mounted:"
        findmnt -rno TARGET,SOURCE "$ESP_MNT" "$NIX_MNT" || true
        log "You can now reboot into the new system."
      '';
    };
  in {
    type = "app";
    description = "Preflight + install macbookpro2025 (checks partitions, copies firmware, runs nixos-install)";
    program = "${installer}/bin/install-macbookpro2025";
  };
}
