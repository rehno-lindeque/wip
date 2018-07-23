{
  pkgs
, ...
}:

{
  hardware =
    {
      # enable pulseaudio for audio
      pulseaudio.enable = true;
    };
}
