{
  ffmpeg,
  lib,
  losslesscut-bin,
  mkShell,
  shotcut,
  slurp,
  stdenv,
  wf-recorder,
}: let
  videoEditor =
    if stdenv.hostPlatform.isAarch64 && stdenv.hostPlatform.isLinux
    then {
      package = shotcut;
      command = lib.getExe shotcut;
      name = "Shotcut";
    }
    else {
      package = losslesscut-bin;
      command = lib.getExe losslesscut-bin;
      name = "LosslessCut";
    };
in
mkShell {
  packages = [
    ffmpeg
    slurp
    videoEditor.package
    wf-recorder
  ];

  shellHook = ''
    echo "Video tools available: wf-recorder, slurp, ffmpeg, ${videoEditor.name}"
    echo "Record screen with audio: wf-recorder -a -f recording.mp4"
    echo "Record region with audio: wf-recorder -a -g '\$(slurp)' -f recording.mp4"
    echo "Edit video: ${videoEditor.command} recording.mp4"
  '';
}
