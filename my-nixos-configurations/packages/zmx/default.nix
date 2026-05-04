{
  lib,
  stdenv,
  fetchFromGitHub,
  zig_0_15,
  callPackage,
}:
let
  zig = zig_0_15;
in
stdenv.mkDerivation (finalAttrs: {
  pname = "zmx";
  version = "0.5.0";

  src = fetchFromGitHub {
    owner = "neurosnap";
    repo = "zmx";
    tag = "v${finalAttrs.version}";
    hash = "sha256-eVp9Lgpx4Dn60NH17zZ+VOUy1VVK73A17bIkPFDKuz4=";
  };

  nativeBuildInputs = [zig.hook];

  deps = callPackage ./build.zig.zon.nix {inherit zig;};

  zigBuildFlags = [
    "--system"
    "${finalAttrs.deps}"
  ];

  zigPreferMusl = true;

  meta = {
    homepage = "https://zmx.sh/";
    description = "Session persistence for terminal processes";
    longDescription = ''
      zmx provides session persistence for terminal shell sessions.
      It lets you attach and detach from long-lived shell sessions without
      tmux-style panes or windows, while preserving terminal output.
    '';
    license = lib.licenses.mit;
    mainProgram = "zmx";
    platforms = lib.platforms.unix;
  };
})
