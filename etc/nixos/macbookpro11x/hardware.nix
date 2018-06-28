{
  pkgs
, ...
}:

{
  hardware =
    {
      opengl =
        {
          extraPackages =
            [
              pkgs.libvdpau-va-gl
              pkgs.vaapiVdpau
              # pkgs.vaapiIntel # ?
            ];
        };

      # enables the facetime HD webcam on newer Macbook Pros (mid-2014+).
      facetimehd.enable = true;

      # enable pulseaudio for audio
      pulseaudio.enable = true;
    };
}
