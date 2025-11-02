{ helpers, lib, ... }:
{
  plugins = {
    luasnip = {
      enable = true;
      fromLua = [ { paths = [ ./luasnips ]; } ];
    };
    nvim-surround.enable = true;

    # Compatibility with cmp-nvim
    blink-compat.enable = true;
    cmp-dap.enable = true;
    # Autocompletion plugin
    blink-cmp = {
      enable = true;
      settings = {
        snippets.preset = "luasnip";
        keymap = {
          preset = "default";
          "<Tab>" = helpers.emptyTable;
          "<S-Tab>" = helpers.emptyTable;
          "<C-y>" = helpers.emptyTable;
          "<C-space>" = [ "select_and_accept" ];
        };
      };
    };
  };

  keymaps =
    let
      modeKeys = mode: lib.attrsets.mapAttrsToList (key: action: { inherit key mode action; });
    in
    helpers.keymaps.mkKeymaps { options.silent = true; } (
      modeKeys [ "i" "s" ] {
        "<C-j>" = helpers.mkRaw ''
          function()
            if require("luasnip").expand_or_jumpable() then
              require("luasnip").expand_or_jump()
            end
          end
        '';
        "<C-k>" = helpers.mkRaw ''
          function()
            if require("luasnip").jumpable(-1) then
              require("luasnip").jump(-1)
            end
          end
        '';
        "<C-l>" = helpers.mkRaw ''
          function()
            if require("luasnip").choice_active() then
              require("luasnip").change_choice(1)
            end
          end
        '';
      }
    );
}
