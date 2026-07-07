{
  mkShell,
  shotcut,
  wf-recorder,
}:
mkShell {
  packages = [
    shotcut
    wf-recorder
  ];
}
