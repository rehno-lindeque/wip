{
  losslesscut-bin,
  mkShell,
  wf-recorder,
}:
mkShell {
  packages = [
    losslesscut-bin
    wf-recorder
  ];
}
