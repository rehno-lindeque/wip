{ pkgs
, ...
}:

# Use
#   $ nix-env -u
# to update

let
  # devpkgs = import <devpkgs> {};
  stdenv = pkgs.stdenv;
  # TODO: Remove
  /* inherit (with pkgs; import ./eth-env.nix { inherit pkgs stdenv fetchFromGitHub fetchurl unzip makeWrapper makeDesktopItem buildEnv myEnvFun; }) ethEnv; #gitignore */
  inherit (pkgs.callPackage ./eth-env.nix {}) ethEnv ethClassicEnv;
  peek = pkgs.callPackage ./peek.nix {};
  moonscript = pkgs.callPackage ./moonscript.nix {};
  gifine = pkgs.callPackage ./gifine.nix { inherit moonscript; };
in
{
  allowUnfree = true;
  # permittedInsecurePackages = [
  #   "webkitgtk-2.4.11" # Needed temporarily in order to build tek (truely ergonomic keyboard firmware program)
  # ];

  packageOverrides = super: with super; rec {

    # inherit (import ./yi-custom.nix { inherit pkgs; }) yi-custom;

    # Work environments
    # Enter an environment like this:
    #
    #   $ load-env-analysis
    #
    analysisEnv = myEnvFun
      {
        name = "analysis";
        buildInputs = with python34Packages; [
          python34
          numpy
          toolz
          ipython
          numpy
          scipy
          matplotlib
          pandas
          # cvxopt
        ];
      };

    # Maintenance environment
    # Enter an environment like this:
    #
    #   $ load-env-maintenance
    #
    maintenanceEnv = myEnvFun
      {
        name = "maintenance";
        buildInputs = with python34Packages; [
          lm_sensors # temperature
          usbutils   # list usb devices
          powertop   # power/battery management analysis and advice
          libsysfs   # list options that are set for a loaded kernel module
                     # * https://wiki.archlinux.org/index.php/kernel_modules#Obtaining_information
          radeontop  # investigate gpu usage
          bmon       # monitor network traffic
          pciutils   # list pci devices via lspci
          lshw       # list detailed hardware configuration
          iw         # wireless scan
          wirelesstools # more wireless
          rfkill     # more wireless (https://ianweatherhogg.com/tech/2015-08-05-rfkill-connman-enable-wifi.html)
          # To read more about wpa_supplicant see:
          # https://github.com/NixOS/nixpkgs/issues/10804#issuecomment-154971201
        ];
      };

    # busybox environment
    # Enter an environment like this:
    #
    #   $ load-env-maintenance
    #
    busyboxEnv = myEnvFun
      {
        name = "busybox";
        buildInputs =  [
          busybox
        ];
      };


    # My non-system packages
    # Install and update using:
    #
    #   $ nix-env -i me-packages
    #
    all = with pkgs; buildEnv {  # pkgs is your overriden set of packages itself
      name = "me-packages";
      paths =
        [
          # Private #gitignore
          # ethEnv    #gitignore
          # ethClassicEnv    #gitignore

          # Working environments
          # maintenanceEnv
          # busyboxEnv
        ];
    };
  };
}
