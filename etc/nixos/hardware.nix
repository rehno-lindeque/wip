{ pkgs
, ...
}:

{
  hardware = {
    opengl = {
      enable = true;
    };

    pulseaudio = {
      enable = true;
      daemon.logLevel = "error";
      support32Bit = true;
      # package = pkgs.pulseaudioFull;
    };

    ledger.enable = true;
    teensy.enable = true;

    # Scanner
    # sane =
    #   {
    #     enable = true; # Enable this to use a scanner */
    #     # extraBackends = [ pkgs.hplipWithPlugin ]; # HP drivers */
    #     # netConf = "192.168.1.97";
    #   };
  };

  sound.enable = true;
  sound.enableOSSEmulation = false;
}
