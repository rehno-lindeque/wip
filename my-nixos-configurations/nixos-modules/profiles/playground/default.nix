{
  config,
  flake,
  lib,
  pkgs,
  ...
}: let
  cfg = config.profiles.playground;
in {
  options = with lib; {
    profiles.playground = {
      enable = mkEnableOption ''
        Whether to enable my personal playground.
        This includes services, packages, options, and other cruft that I'm
        trying out, but haven't committed to keeping longer term.
      '';
    };
  };

  config =
    lib.mkIf cfg.enable
    (lib.mkMerge [
      (lib.mkIf config.profiles.workstation.enable {
        users.users.me.packages = with pkgs; [
          # Clipboard operations from the command-line (also a clipboard provider for neovim)
          # TODO: determine if this (does/could?) work over remote ssh
          xsel
        ];
      })
      (lib.mkIf config.profiles.preferences.enable {
        # # Keyboard layouts that I use (TODO: there may be a better way to set this up)
        # environment.systemPackages = let
        #   norman = pkgs.writeScriptBin "norman" ''
        #     ${pkgs.xorg.setxkbmap}/bin/setxkbmap us -variant norman
        #   '';
        #   qwerty = pkgs.writeScriptBin "qwerty" ''
        #     ${pkgs.xorg.setxkbmap}/bin/setxkbmap us
        #   '';
        # in [
        #   norman
        #   qwerty
        # ];

        # TODO: should this be a preference setting for e.g. some terminal?
        # TODO: check where fonts are used (vim?)
        # TODO: Check against any home-manager font settings?
        # TODO: Check against i18n.consoleFont ?
        # fonts.fonts = with pkgs; [
        #   source-code-pro
        #   terminus-nerdfont
        #   inconsolata-nerdfont
        #   firacode-nerdfont ?
        #   source-code-pro-nerdfont ?
        #   fira-code
        #   iosevka
        #   terminus_font
        # ];

        # https://www.reddit.com/r/NixOS/comments/8j3w16/what_are_your_recommendedfavorite_nixos_options/dyzce1q?utm_source=share&utm_medium=web2x&context=3
        console.useXkbConfig = true;

        home-manager = {
          users.me = {pkgs, ...}: {
            home.shellAliases = {
              # Edit all files modified relative to a recent git commit
              virecent = ''vi $(git diff HEAD~1 --relative --name-only)'';

              # Edit all unmerged files containing git conflicts
              viconflict = ''vi $(git status -s | grep \\\(UU\\\|AA\\\) | sed "s/^\(UU\|AA\) //")'';
            };
            programs = {
              # Enable fzf bash integration
              fzf.enableBashIntegration = true;

              starship = {
                enable = true;
                enableBashIntegration = true;
                settings = {
                  #   add_newline = false;
                  #   format = lib.concatStrings [
                  #     "$line_break"
                  #     "$package"
                  #     "$line_break"
                  #     "$directory"
                  #     "$git_branch"
                  #     "$node"
                  #     "$rust"
                  #     "(bold green)"
                  #   ];
                  #   scan_timeout = 10;
                  #   directory.format = "[$path]($style) ";
                  #   time.disabled = true;

                  #   # # See docs here: https://starship.rs/config/
                  #   # # Symbols config configured ./starship-symbols.nix.
                  #   # battery.display.threshold = 25; # display battery information if charge is <= 25%
                  #   # directory.fish_style_pwd_dir_length = 1; # turn on fish directory truncation
                  #   # directory.truncation_length = 2; # number of directories not to truncate
                  #   # gcloud.disabled = true; # annoying to always have on
                  #   # hostname.style = "bold green"; # don't like the default
                  #   # memory_usage.disabled = true; # because it includes cached memory it's reported as full a lot
                  #   # username.style_user = "bold blue"; # don't like the default

                  #   # symbols
                  #   aws.symbol = lib.mkDefault " ";
                  #   battery.full_symbol = lib.mkDefault "";
                  #   battery.charging_symbol = lib.mkDefault "";
                  #   battery.discharging_symbol = lib.mkDefault "";
                  #   battery.unknown_symbol = lib.mkDefault "";
                  #   battery.empty_symbol = lib.mkDefault "";
                  #   cmake.symbol = lib.mkDefault "△ ";
                  #   conda.symbol = lib.mkDefault " ";
                  #   crystal.symbol = lib.mkDefault " ";
                  #   dart.symbol = lib.mkDefault " ";
                  #   directory.read_only = lib.mkDefault " ";
                  #   docker_context.symbol = lib.mkDefault " ";
                  #   dotnet.symbol = lib.mkDefault " ";
                  #   elixir.symbol = lib.mkDefault " ";
                  #   elm.symbol = lib.mkDefault " ";
                  #   erlang.symbol = lib.mkDefault " ";
                  #   gcloud.symbol = lib.mkDefault " ";
                  #   git_branch.symbol = lib.mkDefault " ";
                  #   git_commit.tag_symbol = lib.mkDefault " ";
                  #   git_status.format = lib.mkDefault "([$all_status$ahead_behind]($style) )";
                  #   git_status.conflicted = lib.mkDefault " ";
                  #   git_status.ahead = lib.mkDefault " ";
                  #   git_status.behind = lib.mkDefault " ";
                  #   git_status.diverged = lib.mkDefault " ";
                  #   git_status.untracked = lib.mkDefault " ";
                  #   git_status.stashed = lib.mkDefault " ";
                  #   git_status.modified = lib.mkDefault " ";
                  #   git_status.staged = lib.mkDefault " ";
                  #   git_status.renamed = lib.mkDefault " ";
                  #   git_status.deleted = lib.mkDefault " ";
                  #   golang.symbol = lib.mkDefault " ";
                  #   helm.symbol = lib.mkDefault "⎈ ";
                  #   hg_branch.symbol = lib.mkDefault " ";
                  #   java.symbol = lib.mkDefault " ";
                  #   julia.symbol = lib.mkDefault " ";
                  #   kotlin.symbol = lib.mkDefault " ";
                  #   kubernetes.symbol = lib.mkDefault "☸ ";
                  #   lua.symbol = lib.mkDefault " ";
                  #   memory_usage.symbol = lib.mkDefault " ";
                  #   nim.symbol = lib.mkDefault " ";
                  #   nix_shell.symbol = lib.mkDefault " ";
                  #   nodejs.symbol = lib.mkDefault " ";
                  #   openstack.symbol = lib.mkDefault " ";
                  #   package.symbol = lib.mkDefault " ";
                  #   perl.symbol = lib.mkDefault " ";
                  #   php.symbol = lib.mkDefault " ";
                  #   purescript.symbol = lib.mkDefault "<≡> ";
                  #   python.symbol = lib.mkDefault " ";
                  #   ruby.symbol = lib.mkDefault " ";
                  #   rust.symbol = lib.mkDefault " ";
                  #   shlvl.symbol = lib.mkDefault " ";
                  #   status.symbol = lib.mkDefault " ";
                  #   status.not_executable_symbol = lib.mkDefault " ";
                  #   status.not_found_symbol = lib.mkDefault " ";
                  #   status.sigint_symbol = lib.mkDefault " ";
                  #   status.signal_symbol = lib.mkDefault " ";
                  #   swift.symbol = lib.mkDefault " ";
                  #   terraform.symbol = lib.mkDefault "𝗧 ";
                  #   vagrant.symbol = lib.mkDefault "𝗩 ";
                  #   zig.symbol = lib.mkDefault " ";
                };
              };
              neovim = {
                extraConfig = ''
                  luafile ${./neovim/playground.lua}
                '';
                plugins = with pkgs.vimPlugins; let
                  context-vim = pkgs.vimUtils.buildVimPlugin {
                    name = "context-vim";
                    src = pkgs.fetchFromGitHub {
                      owner = "wellle";
                      repo = "context.vim";
                      rev = "e38496f1eb5bb52b1022e5c1f694e9be61c3714c";
                      sha256 = "1iy614py9qz4rwk9p4pr1ci0m1lvxil0xiv3ymqzhqrw5l55n346";
                    };
                  };
                in [
                  # Code editing: Delete surrounding brackets, quotes, etc
                  # TODO: Does this load slowly?
                  # TODO: key bindings seems awkward
                  vim-sandwich

                  # Aesthetics: context formatting
                  # TODO: Does this slow down terminal rendering / increase flickering?
                  # let g:context_nvim_no_redraw = 1 # perhaps fixed by this?
                  # context-vim

                  # Aesthetics: advanced syntax highlighting
                  # TODO: this plugin states that it is still experimental
                  # nvim-treesitter

                  # Aesthetics: Interactivity
                  # {
                  #   plugin = my-custom-interactivity;
                  #   type = "lua";
                  #   config = ''
                  #     local group = vim.api.nvim_create_augroup('aesthetics', { clear = true })
                  #     vim.api.nvim_create_autocmd('InsertEnter', {
                  #       desc = 'increase cursorline highlight in insert mode',
                  #       -- callback = function() vim.highlight.create('CursorLineNr', { guibg="#16161e" }) end,
                  #       -- callback = function() vim.highlight.create('CursorLineNr', { guifg="#ffffff" }) end,
                  #       callback = function() vim.highlight.link('CursorLineNr', 'User2', true) end,
                  #       group = group,
                  #     })
                  #   '';
                  # }
                  # vim.api.nvim_create_autocmd('InsertEnter', {
                  #   desc = 'increase cursorline highlight in insert mode',
                  #   callback = function() vim.highlight.create('CursorLine', { ctermbg=253 }) end,
                  # })
                ];
              };
            };
          };
          #   # Uncategorized
          #   ++ [
          #     # telescope-nvim
          #     # nvim-autopairs
          #     # vim-vsnip
          #     # nvim-web-devicons
          #     # nvim-tree-lua
          #   ];
        };
      })

      (lib.mkIf config.profiles.nucbox2022.enable {
        # TODO: clean up / check sound (it doesn't work right now)
        # hardware.pulseaudio.daemon.logLevel = "error";
        # hardware.pulseaudio.support32Bit = lib.mkDefault true;

        # Set the desktop manager to none so that it doesn't default to xterm sometimes
        # TODO: check if this is this still needed?
        # xserver.displayManager.defaultSession = "none+xmonad";

        # Security
        services.gnome.gnome-keyring.enable = true; # gnome's default keyring

        # Set a low brightness for my displays at night
        services.redshift = {
          temperature.night = 2750;
          brightness.night = "0.5";
        };
      })

      (lib.mkIf config.profiles.desktop2022.enable {
        # Use cuda graphics in headless mode
        # hardware.nvidia = {
        #   # headless??
        #   nvidiaPersistenced = true;
        #   nvidiaSettings = false;
        # };

        # Set the desktop manager to none so that it defaults to gnome with wayland
        # xserver.displayManager.defaultSession = ""; # gnome+wayland perhaps?

        # Security
        services.gnome.gnome-keyring.enable = true; # gnome's default keyring (does this avoid the annoying dialog popup?)

        # TODO: do we still need to open port 22 with tailscale? See https://fzakaria.com/2020/09/17/tailscale-is-magic-even-more-so-with-nixos.html
        # services.openssh.openFirewall = false;

        # TODO: automate tailscale authentication
        # Note that auth keys (now) expire after 90 days, so there may not be a good solution anymore
        # https://www.reddit.com/r/NixOS/comments/ou7hde/how_to_automate_tailscale_on_reboot/
        # https://discourse.nixos.org/t/solved-possible-to-automatically-authenticate-tailscale-after-every-rebuild-reboot/14296
        # https://tailscale.com/blog/nixos-minecraft/

        # Wait 2 seconds for tailscale to settle
        systemd.services.tailscaled-online = {
          description = "Wait for tailscale to settle and then automatically connect";
          after = ["network-pre.target" "tailscaled.service"];
          wants = ["network-pre.target" "tailscaled.service"];
          wantedBy = ["multi-user.target"];

          serviceConfig.Type = "oneshot"; # is there a native oneshot attr?

          script = with pkgs; ''
            sleep 2

            status="$(${pkgs.tailscale}/bin/tailscale status -json | ${pkgs.jq}/bin/jq -r .BackendState)"
            if test $status = "Running" ; then
              exit 0
            fi

            ${tailscale}/bin/tailscale up --accept-routes
          '';
        };

        systemd.services.sshd = {
          # Make sure sshd starts after tailscale so that it can successfully bind to the ip address
          after = ["tailscaled-online.service"];
          wants = ["tailscaled-online.service"];
        };

        # # Disable the GNOME3/GDM auto-suspend feature that cannot be disabled in GUI!
        # # If no user is logged in, the machine will power down after 20 minutes.
        # systemd.targets.sleep.enable = false;
        # systemd.targets.suspend.enable = false;
        # systemd.targets.hibernate.enable = false;
        # systemd.targets.hybrid-sleep.enable = false;

        # Extra software packages exclusively used on this system
        users.users.me.packages = with pkgs; [
          # Use GPT4 in the terminal
          shell_gpt
        ];
      })

      (lib.mkIf config.profiles.macbookpro2017.enable {
        # Power management protocol for application (turned on automatically by some display managers)
        services.upower.enable = true;

        # Control the screen brightness with light
        programs.light.enable = true;

        # Handling for power events (keyboard power button, lid close, etc)
        # TODO: investigate how this works in practice
        # TODO: investigate backlight control https://wiki.archlinux.org/title/acpid#Enabling_backlight_control
        # TODO may interfere with some desktop environments
        services.acpid.enable = true;

        # DNS setup for CircuitHub
        services.dnsmasq = let
          inherit (lib.mapAttrs (_: interface: interface.name) config.networking.interfaces) tailscale0 wlp4s0;
        in {
          enable = true;
          servers = [
            # Use cloudflare for regular top-level name resolution
            "1.1.1.1@${wlp4s0}"
            "1.0.0.1@${wlp4s0}"
          ];

          extraConfig =
            ''
              server=/picofactory-new/10.20.0.1@${tailscale0}
              server=/petersfield/10.21.0.1@${tailscale0}
            ''
            # (MagicDNS does not appear to work)
            # server=/tiger-jazz.ts.net/100.100.100.100@${tailscale0}
            +
            # Prevent packets with malformed domain names and private ip addresses
            # from leaving the network
            ''
              domain-needed
              bogus-priv
            ''
            +
            # Limit name resolution to dnsmasq (ignore /etc/resolv.conf)
            ''
              no-resolv
            ''
            +
            # Speed up queries for recent domains
            ''
              cache-size=300
            ''
            +
            # Only listen on localhost, not on public facing addresses
            ''
              listen-address=::1,127.0.0.1
              interface=lo
              bind-interfaces
            '';
        };

        # Advanced Power Management for Linux
        services.tlp =
          # Turns on power saving features usually used on battery for AC power as well.
          # This can be useful for keeping you macbook pro running cool at the cost of some performance.
          let
            aggressivePowerSavingOnAC = true;
          in {
            enable = true;
            settings = {
              # Select a CPU frequency scaling governor.
              # Intel Core i processor with intel_pstate driver:
              #   powersave(*), performance
              # Older hardware with acpi-cpufreq driver:
              #   ondemand(*), powersave, performance, conservative
              # (*) is recommended.
              # Hint: use tlp-stat -p to show the active driver and available governors.
              # Important:
              #   You *must* disable your distribution's governor settings or conflicts will
              #   occur. ondemand is sufficient for *almost all* workloads, you should know
              #   what you're doing!
              # ---
              # See also
              # * http://linrunner.de/en/tlp/docs/tlp-configuration.html#scaling

              # TODO: do we have the intel_pstate driver?

              CPU_SCALING_GOVERNOR_ON_AC = "powersave";
              CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

              # Minimize number of used CPU cores/hyper-threads under light load conditions
              # I've turned this to 1 because I prefer my macbook running cool

              SCHED_POWERSAVE_ON_AC =
                if aggressivePowerSavingOnAC
                then 1
                else 0;

              # Include listed devices into USB autosuspend even if already excluded
              # by the driver or WWAN blacklists above (separate with spaces).
              # Use lsusb to get the ids.
              # ---
              # Note that apple trackpad does have explicit autosuspend support.
              # * See http://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=88da765f4d5f59f67a7a51c8f5d608a836b32133

              USB_WHITELIST = "05ac:0274";

              # PCI Express Active State Power Management (PCIe ASPM):
              #   default, performance, powersave

              PCIE_ASPM_ON_AC =
                if aggressivePowerSavingOnAC
                then "powersave"
                else "performance";

              # Radeon graphics clock speed (profile method): low, mid, high, auto, default;
              # auto = mid on BAT, high on AC; default = use hardware defaults.
              # (Kernel >= 2.6.35 only, open-source radeon driver explicitly)
              # ---
              # I've turned this to low on AC because my graphics card tends to warm up more than I like on AC, but others may prefer mid or auto

              RADEON_POWER_PROFILE_ON_AC =
                if aggressivePowerSavingOnAC
                then "low"
                else "mid";

              # Radeon dynamic power management method (DPM): battery, balanced, performance
              # (Kernel >= 3.11 only, requires boot option radeon.dpm=1)
              # ---
              # I've turned this to battery because my graphics card tends to warm up more than I like on AC, but other may prefer to se this to balanced or performance.
              # * Note that http://linrunner.de/en/tlp/docs/tlp-configuration.html#graphics only lists battery and performance as options,
              #   however https://wiki.archlinux.org/index.php/ATI#Powersaving says that balanced should also be possible which appears to be correct.

              RADEON_DPM_STATE_ON_AC =
                if aggressivePowerSavingOnAC
                then "battery"
                else "balanced";

              # TODO:

              # Set Intel P-state performance: 0..100 (%)
              # Limit the max/min P-state to control the power dissipation of the CPU.
              # Values are stated as a percentage of the available performance.
              # Requires an Intel Core i processor with intel_pstate driver.
              #CPU_MIN_PERF_ON_AC=0
              #CPU_MAX_PERF_ON_AC=100
              #CPU_MIN_PERF_ON_BAT=0
              #CPU_MAX_PERF_ON_BAT=30
            };
          };

        # hardware.bluetooth.enable = true;

        # Enable YubiKey support
        # hardware.yubikey.enable = true;

        # Grant group access to the keyboard backlight.
        # hardware.macbook.leds.enable = true;

        # disable sd card reader to save on battery (enabled by default)
        # hardware.macbook.sdCardReader.enable = false;

        # bluetooth manager service
        # services.blueman.enable = true;

        # Extra hardware configuration for macbooks
        /*
        extraModprobeConfig = ''
        */
        /*
        # TODO: Not sure if noncq is needed for macbook SSD's, but https://github.com/mbbx6spp/mbp-nixos/blob/master/etc/nixos/configuration.nix has this
        */
        /*
        # TODO: doesn't seem to work...
        */
        /*
        # options libata.force=noncq
        */

        /*
        # TODO: mpb-nixos has this resume option, but not sure if it's really helpful
        */
        /*
        # TODO: doesn't seem to work...
        */
        /*
        # options resume=/dev/sda5
        */

        /*
        # Sound module for Apple Macs
        */
        /*
        options snd_hda_intel index=0 model=intel-mac-auto id=PCH
        */
        /*
        options snd_hda_intel index=1 model=intel-mac-auto id=HDMI
        */
        /*
        options snd-hda-intel model=mbp101
        */

        /*
        # Pressing 'F8' key will behave like a F8. Pressing 'fn'+'F8' will act as special key
        */
        /*
        options hid_apple fnmode=2
        */
        /*
        '';
        */
        boot.initrd.availableKernelModules = [
          # # "xhci_pci"    # ?
          # # "uhci_hcd"    # ?
          # "ehci_pci" # ?
          # # "ahci"        # ?
          # "usbhid" # USB input devices
          # "usb_storage" # USB storage devices
          # # "brcmsmac"    # Broadcom wireless device
          # # * Open source brcm80211 kernel driver
          # # * Appears to be an alternative to b43 (reverse-engineered kernel driver), broadcom-wl (Broadcom driver restricted-license)
          # #   We are using broadcom_sta, see extraModulePackages below
          # # * This is the PCI version of the driver (built-in wireless, not SDIO/USB)
          # # * https://wiki.archlinux.org/index.php/broadcom_wireless#Driver_selection
          # # * https://github.com/Ericson2314/nixos-configuration/blob/nixos/mac-pro/wireless.nix#L9
          # # "amdgpu"
        ];
        boot.initrd.kernelModules = [
          # "fbcon"    # Make it pretty (support fonts in the terminal)
          # modprobe: FATAL: Module fbcon not found in directory /nix/store/________________________________-kernel-modules/lib/modules/4.4.2
        ];

        boot.kernelModules = [
          # TODO: see https://github.com/fooblahblah/nixos/blob/63457072af7b558f63cc5ccec5a75b90a14f35f7/hardware-configuration-mbp.nix
          "kvm-intel" # Run kernel-based virtual machines (hypervisor functionality, useful for nix containers)
          # "applesmc" # apple system managment controller, regulates fan and other hw goodies
          # also sudden motion sensor? (enable disk protections etc)
          # * needed for mbpfan
          "coretemp" # * recommended by lm-sensors
          # * needed for mbpfan
          "msr" # * needed for powersaving, ENERGY_PERF_POLICY_ON_AC, ENERGY_PERF_POLICY_ON_BATTERY in tlp configuration
          # "bcm5974" # Apple trackpad (this doesn't appear to be strictly necessary) (seems to be broken?)
          # "hid_apple" # Apple keyboard (this doesn't appear to be strictly necessary)

          #macbook ___? (TODO)
          # "brcmsmac"      # wireless Needed?
          # "brcmfmac"      # wireless Needed?

          # "nvme" # do I need this perhaps? see https://linux-hardware.org/?probe=7b1766f4ef&log=lsmod and https://linux-hardware.org/?probe=5cd59453b1&log=lsmod
        ];

        boot.blacklistedKernelModules = [
          # From https://github.com/javins/nixos/blob/master/hardware-configuration.nix#L18:
          # Macbooks don't have PS2 capabilities, and the I8042 driver spams an err like
          # the following on boot:
          #
          # Dec 26 09:43:17 nix kernel: i8042: No controller found
          #
          # This is harmless, but it is noise in the logs when I'm looking for real errors.
          #
          # Alas atkbd was built into nixpkgs here:
          #
          # https://github.com/NixOS/nixpkgs/commit/1c22734cd2e67842090f5d59a6c7b2fb39c1cf66
          #
          # so there isn't a good way to remove it from boot.kernelModules. Thus blacklisting.
          # "atkbd"
        ];

        fonts.fonts = let
          nerdfonts = pkgs.nerdfonts.override {
            fonts = [
              "SourceCodePro"
            ];
          };
        in [nerdfonts];
        fonts.enableDefaultFonts = true;

        services.pipewire = {
          enable = true;
          alsa.enable = true;
          # alsa.support32Bit = true; #?
          pulse.enable = true;
        };

        # Interplanetary File System
        # ipfs = {
        #   # enable = true;
        #   emptyRepo = true;
        #   # defaultMode = "offline";
        #   # defaultMode = "norouting";
        #   autoMount = true; # Not supported in offline mode
        #   user = "me";
        #   autoMigrate = true;
        #   extraFlags = [
        #     # See https://github.com/ipfs/go-ipfs/issues/3320#issuecomment-511467441
        #     "--routing=dhtclient"
        #   ];
        #   # extraConfig = {
        #   # };
        # };

        # Identity/Key/Cloud storage management
        # keybase.enable = true;
        # kbfs = {
        #   # enable = true;
        #   mountPoint = "/keybase";
        # };

        # services.xserver.libinput.enable = true;

        # Extra software packages exclusively used on this system
        users.users.me.packages = with pkgs; [
          # Program launcher that works with xmonad
          # dmenu

          # # Monitor system temperatures
          # psensor

          # Terminal emulator
          # sakura

          # Music player
          spotify

          # Gui based diff for source files
          # diffuse
        ];

        # TODO EVALUATE:
        # TODO: keyboard stuff to potentially move to personalize
        services.xserver.layout = "us";
        services.xserver.xkbVariant = "norman";
        services.xserver.dpi = 144;
        services.xserver.xkbOptions = "terminate:ctrl_alt_bksp, caps:escape";

        # see https://wiki.archlinux.org/index.php/AMDGPU
        # see https://en.wikipedia.org/wiki/List_of_AMD_graphics_processing_units#Volcanic_Islands_.
        # nix-shell -p pciutils --run 'lspci | grep -e VGA -e 3D'
        # 01:00.0 VGA compatible controller: Advanced Micro Devices, Inc. [AMD/ATI] Venus XT [Radeon
        # services.xserver.videoDrivers = [ amdgpu" ];

        # * Terminate current session using ctrl + alt + backspace (usefull on macs)
        # * Make capslock into an additional escape key
        # xkbOptions = "terminate:ctrl_alt_bksp, caps:escape";

        # Adjust screen brightness at night
        # services.redshift.enable = true;

        # Add this flake to the local registry so that it's easy
        # # to reference on the command line
        # nix.registry.wip = {
        #   from = {
        #     id = "wip";
        #     type = "indirect";
        #   };
        #   to = {
        #     path = "${config.users.users.me.home}/projects/wip";
        #     type = "path";
        #   };
        # };

        # enable bluetooth as needed, keep it disabled to use less battery (disabled by default)
        # hardware.bluetooth.enable = true;

        # Enable YubiKey support
        # hardware.yubikey.enable = true;

        # Grant group access to the keyboard backlight.
        # hardware.macbook.leds.enable = true;

        # disable sd card reader to save on battery (enabled by default)
        # hardware.hardware.macbook.sdCardReader.enable = false;
        # hardware.hardware.macbook.sdCardReader.enable = true;

        # bluetooth manager service
        # services.blueman.enable = true;

        # # Limit cpu use to 4 out of the ? available
        # nix.buildCores = 4;

        sound.mediaKeys.enable = true;

        # TODO: Looking at https://github.com/garbas/dotfiles/blob/e341ab68892566bd676696d7bc33fbccb
        # and https://shen.hong.io/nixos-home-manager-wayland-sway/
        # and https://nixos.wiki/wiki/Sway
        # home-manager.users.me = {
        #   wayland.windowManager.sway.enable = true;
        #   wayland.windowManager.sway.wrapperFeatures.gtk = true;
        #   wayland.windowManager.sway.systemdIntegration = true;
        #   wayland.windowManager.sway.config.gaps.smartBorders = "on";
        #   wayland.windowManager.sway.config.fonts.names = [ "Fira Code Light" ];
        #   wayland.windowManager.sway.config.terminal = "sakura";
        #   # wayland.windowManager.sway.config.fonts.size = 8.0;
        #   # wayland.windowManager.sway.config.modifier = "Mod4";
        #   # wayland.windowManager.sway.config.menu = "dmenu-wl_run -i";
        #   # wayland.windowManager.sway.config.terminal = "kitty";
        #   # wayland.windowManager.sway.config.floating.modifier = "Mod4";
        #   # wayland.windowManager.sway.config.output = {
        #   #   # "${output.laptop}" = {
        #   #   #   scale = "2";
        #   #   # };
        #   # };
        # };
        networking.hosts = {
          "100.89.210.26" = ["desktop2022"];
          "100.123.235.67" = ["nucbox2022"];
          "100.102.213.117" = ["macbookpro2017"];

          # Broken name resolution due to Tailscale MagicDNS not working
          "100.79.57.124" = ["server.tiger-jazz.ts.net" "pnp.circuithub"];
          "100.93.41.109" = ["internal.tiger-jazz.ts.net" "programming.circuithub"];
          "100.77.224.145" = ["gpu-server.tiger-jazz.ts.net" "programming.circuithub"];
          "100.89.205.66" = ["kitting" "kitting.circuithub"];
        };

        system.nixos.tags = ["linux-${config.boot.kernelPackages.kernel.version}"];
      })
    ]);
}
