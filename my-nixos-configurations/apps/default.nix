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
  flakeRefDefault = "path:${flake.outPath}";
  mkRebuildApp = {name, host}: let
    script = pkgs.writeShellApplication {
      name = "${name}-rebuild";
      runtimeInputs = with pkgs; [
        gh
        nix
        nixos-rebuild-ng
        openssh
      ];
      text = ''
        #!/usr/bin/env bash
        set -euo pipefail

        FLAKE_REF="''${FLAKE_REF:-${flakeRefDefault}}"
        local_host="$(hostname)"
        local_short="$(hostname -s 2>/dev/null || true)"
        if [[ -z "''${BUILD_HOST:-}" ]] && [[ "${host}" != "$local_host" ]] && [[ "${host}" != "$local_short" ]]; then
          BUILD_HOST="${host}"
        fi
        if [[ -z "''${TARGET_HOST:-}" ]] && [[ "${host}" != "$local_host" ]] && [[ "${host}" != "$local_short" ]]; then
          TARGET_HOST="${host}"
        fi

        gh_token="''${GH_TOKEN:-''${GITHUB_TOKEN:-}}"
        if [[ -z "$gh_token" ]] && command -v gh >/dev/null 2>&1; then
          gh_token="$(gh auth token 2>/dev/null || true)"
        fi
        if [[ -n "$gh_token" ]]; then
          if [[ -n "''${NIX_CONFIG:-}" ]]; then
            NIX_CONFIG="access-tokens = github.com=$gh_token
''${NIX_CONFIG}"
          else
            NIX_CONFIG="access-tokens = github.com=$gh_token"
          fi
          export NIX_CONFIG
        fi

        args=(
          --flake "''${FLAKE_REF}#${name}"
          --sudo
          --ask-sudo-password
        )
        if [[ -n "''${BUILD_HOST:-}" ]]; then
          args+=(--build-host "$BUILD_HOST")
        fi
        if [[ -n "''${TARGET_HOST:-}" ]]; then
          args+=(--target-host "$TARGET_HOST")
        fi

        user_args=("$@")
        action=""
        if [[ ''${#user_args[@]} -gt 0 ]]; then
          case "''${user_args[0]}" in
            switch|boot|test|build|edit|repl|dry-build|dry-run|dry-activate|build-image|build-vm|build-vm-with-bootloader|list-generations)
              action="''${user_args[0]}"
              ;;
          esac
        fi
        if [[ -n "$action" ]]; then
          has_option_after=0
          for i in "''${!user_args[@]}"; do
            if [[ $i -gt 0 && "''${user_args[$i]}" == -* ]]; then
              has_option_after=1
              break
            fi
          done
          if [[ $has_option_after -eq 1 ]]; then
            user_args=("''${user_args[@]:1}" "$action")
          fi
        fi

        echo nixos-rebuild "''${args[@]}" "''${user_args[@]}"
        exec nixos-rebuild "''${args[@]}" "''${user_args[@]}"
      '';
    };
  in {
    type = "app";
    description = "nixos-rebuild ${name} via ${host}";
    program = "${script}/bin/${name}-rebuild";
  };
in
  {
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
    desktop2022-rebuild = mkRebuildApp {name = "desktop2022"; host = "desktop2022";};
    macbookpro2017-rebuild = mkRebuildApp {name = "macbookpro2017"; host = "macbookpro2017";};
    macbookpro2025-rebuild = mkRebuildApp {name = "macbookpro2025"; host = "macbookpro2025";};
    nucbox2022-rebuild = mkRebuildApp {name = "nucbox2022"; host = "nucbox2022";};
    install-macbookpro2025-remote = let
      installer = pkgs.writeShellApplication {
        name = "install-macbookpro2025-remote";
        runtimeInputs = with pkgs; [
          openssh
        ];
        text = ''
          #!/usr/bin/env bash
          set -euo pipefail

          host="''${INSTALL_HOST:-''${1:-}}"
          if [[ -z "$host" ]]; then
            echo "Usage: install-macbookpro2025-remote <host>" >&2
            echo "Set INSTALL_HOST to skip the argument." >&2
            exit 1
          fi

          cat <<'EOF'
Before running the remote install, prepare the stock NixOS installer:

  iwctl
  [iwd]# station wlan0 scan
  [iwd]# station wlan0 get-networks
  [iwd]# station wlan0 connect <ssid>

  sudo su
  passwd
  systemctl start sshd
  ip a

Then make sure you can SSH in as root.
EOF
          read -r -p "Continue with remote install? [y/N] " reply
          if [[ ! "$reply" =~ ^[Yy]$ ]]; then
            echo "Aborted."
            exit 1
          fi

          ssh-keygen -R "$host" >/dev/null 2>&1 || true
          exec ssh -o StrictHostKeyChecking=accept-new "root@$host" \
            'export NIX_CONFIG="experimental-features = nix-command flakes"; nix run github:rehno-lindeque/wip?dir=my-nixos-configurations#install-macbookpro2025 --refresh --accept-flake-config'
        '';
      };
    in {
      type = "app";
      description = "Run install-macbookpro2025 on a remote installer over SSH";
      program = "${installer}/bin/install-macbookpro2025-remote";
    };
  }
  // pkgs.lib.optionalAttrs (system == "aarch64-linux") {
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
          gh
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

          gh_token="''${GH_TOKEN:-''${GITHUB_TOKEN:-}}"
          if [[ -z "$gh_token" ]] && command -v gh >/dev/null 2>&1; then
            if ! gh auth status -h github.com >/dev/null 2>&1; then
              log "gh is not logged in; run 'gh auth login' or set GH_TOKEN to avoid SSH prompts."
            fi
            gh_token="$(gh auth token 2>/dev/null || true)"
          fi
          if [[ -n "$gh_token" ]]; then
            if [[ -n "''${NIX_CONFIG:-}" ]]; then
              NIX_CONFIG="access-tokens = github.com=$gh_token
''${NIX_CONFIG}"
            else
              NIX_CONFIG="access-tokens = github.com=$gh_token"
            fi
            export NIX_CONFIG
          fi

          if [[ $EUID -ne 0 ]]; then
            fail "Run as root"
          fi

          # Default to the upstream flake URL so running from nix run works without a local checkout.
          FLAKE_ROOT="''${FLAKE:-github:rehno-lindeque/wip?dir=my-nixos-configurations}"
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
            [[ -n "$dev" ]] || fail "Could not find $label device with UUID $uuid. Override with ''${label^^}_DEV env var."
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
            local opts="''${3:-}"
            if findmnt -rno SOURCE "$path" >/dev/null 2>&1; then
              return
            fi
            log "Mounting $dev -> $path"
            if [[ -n "$opts" ]]; then
              mount -o "$opts" "$dev" "$path"
            else
              mount "$dev" "$path"
            fi
          }

          ensure_mountpoint "$MNT"
          ensure_mountpoint "$ESP_MNT"
          ensure_mountpoint "$NIX_MNT"

          ensure_not_conflicting_mount "$BOOT_DEV" "$ESP_MNT"
          ensure_not_conflicting_mount "$NIX_DEV" "$NIX_MNT"

          maybe_format_nix "$NIX_DEV"
          mount_if_needed "$NIX_DEV" "$NIX_MNT"
          mount_if_needed "$BOOT_DEV" "$ESP_MNT" "fmask=0077,dmask=0077"

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

          log "Diagnostics (trimmed):"
          log "  BOOT_DEV=$BOOT_DEV -> $ESP_MNT"
          log "  NIX_DEV=$NIX_DEV -> $NIX_MNT"
          echo
          echo "== $ESP_MNT/asahi =="
          ls -1 "$ESP_MNT/asahi" 2>/dev/null || echo "(missing)"
          echo
          echo "== $firmware_dest =="
          ls -1 "$firmware_dest" 2>/dev/null || echo "(missing)"
          echo
          printf "Continue after diagnostics? [y/N] "
          read -r reply
          if [[ ! "$reply" =~ ^[Yy]$ ]]; then
            echo "Aborted."
            exit 1
          fi

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

          log "Persisted /etc files can conflict with impermanence activation."
          rm -i \
            "$MNT/etc/passwd" \
            "$MNT/etc/group" \
            "$MNT/etc/shadow" \
            "$MNT/etc/subuid" \
            "$MNT/etc/subgid"

          log "Running nixos-install for $INSTALL_SYSTEM"
          echo nixos-install \
            --root "$MNT" \
            --flake "$FLAKE_ROOT#$INSTALL_SYSTEM" \
            --no-channel-copy \
            --option accept-flake-config true \
            --option extra-sandbox-paths "$firmware_dest"
          nixos-install \
            --root "$MNT" \
            --flake "$FLAKE_ROOT#$INSTALL_SYSTEM" \
            --no-channel-copy \
            --option accept-flake-config true \
            --option extra-sandbox-paths "$firmware_dest"

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
