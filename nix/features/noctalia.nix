{
  self,
  inputs,
  ...
}: {
  perSystem = {pkgs, ...}: {
    packages.emntNoctalia = inputs.wrapper-modules.wrappers.noctalia-shell.wrap {
      inherit pkgs;
    };
  };
}
