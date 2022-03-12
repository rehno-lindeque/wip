{
  description = "WIP";

  inputs = {
    my-dev-shells.url = "path:./my-dev-shells";
    my-nixos-configurations.url = "path:./my-nixos-configurations";
  };

  outputs = {
    self,
    my-dev-shells,
    my-nixos-configurations,
  }: {
    inherit (my-nixos-configurations) nixosConfigurations;
    inherit (my-dev-shells) devShells;

    # see note about devShells.<system>.default in dev-shells
    inherit (my-dev-shells) devShell;
  };
}
