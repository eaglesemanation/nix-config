{
  lib,
  config,
  pkgs,
  ...
}:
lib.mkIf (builtins.elem "godot" config.emnt.lang_support.langs) {
  plugins = {
    lsp.servers = {
      gdscript = {
        enable = true;
        package = pkgs.gdtoolkit_4;
      };
    };
    dap = {
      adapters.servers.godot = {
        host = "127.0.0.1";
        port = 6006;
      };
      configurations.gdscript = [
        {
          type = "godot";
          request = "launch";
          name = "Launch scene";
          project = "\${workspaceFolder}";
          launch_scene = true;
        }
      ];
    };
  };
}
