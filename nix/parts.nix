{
  self,
  inputs,
  ...
}: {
  systems = ["x86_64-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin"];
  imports = [
    inputs.disko.flakeModule
    inputs.home-manager.flakeModules.home-manager
  ];

  perSystem = {
    config,
    system,
    ...
  }: {
    _module.args.pkgs = import self.inputs.nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };
  };
}
