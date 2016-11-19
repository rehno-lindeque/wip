{
  # eagleKey ? ./eagle.key,
  ...
}:

{
  eagle =
    let nixpkgs1509 = oldPkgs.fetchgit {
          url = git://github.com/nixos/nixpkgs;
          rev = "655cda730d14b7da25e23eb87ef4d42d6c32a8b8";
          sha256 = "89a60c0db8a03a29e9b0bc43f2da4211c207c87553833f831a6a646f84e7a16c";
        };
    in (import nixpkgs1509 {}).eagle;
}
