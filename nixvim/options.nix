{
  helpers,
  lib,
  ...
}:
{
  colorschemes.everforest = {
    settings.background = "hard";
    enable = true;
  };

  globals = {
    mapleader = " ";
    maplocalleader = " ";
  };

  opts = {
    # Don't limit colors to 256 in terminal
    termguicolors = true;
    # Enable mouse in all modes
    mouse = "a";
    # Creates new windows in bottom/right instead of top/left
    splitbelow = true;
    splitright = true;
    # Keeps text stable relative to screen position instead of cursor
    splitkeep = "screen";
    # Show column with line offsets
    number = true;
    relativenumber = true;
    numberwidth = 1;
    # Always show column with diagnostic signs, even if there are no errors
    signcolumn = "yes";
    # Use persistent undo files for recovery
    swapfile = false;
    backup = false;
    undofile = true;
    # Case-insensitive search UNLESS \C or one or more capital letters in the search term
    ignorecase = true;
    smartcase = true;
    # Speed up CursorHold events
    updatetime = 250;
    # Speed up mapped sequence timeout
    timeoutlen = 500;
    list = true;
    listchars = {
      tab = "» ";
      lead = "·";
      nbsp = "␣";
      trail = "•";
    };
    # Preview substitutions
    inccommand = "split";
    # Match indentation on a long line that is split for readability
    breakindent = true;
    # Show which line your cursor is on
    cursorline = true;
    # Minimal number of screen lines to keep above and below the cursor
    scrolloff = 10;
    # Do not automatically fold code
    foldenable = false;
  };

  keymaps =
    let
      inherit (import ./lib.nix { inherit lib; }) modeKeys;
    in
    helpers.keymaps.mkKeymaps { options.silent = true; } (
      modeKeys [ "n" ] {
        # Tab operations
        "<leader>tc" = "<cmd>tabclose<cr>";
        "<leader>tl" = "<cmd>tabnext<cr>";
        "<leader>th" = "<cmd>tabprevious<cr>";
        "<leader>tL" = "<cmd>tabmove +1<cr>";
        "<leader>tH" = "<cmd>tabmove -1<cr>";
        # Recenter after moving half a page
        "<C-d>" = "<C-d>zz";
        "<C-u>" = "<C-u>zz";
        # Clears highlights after searching
        "<Esc>" = "<cmd>nohlsearch<cr>";
      }
    )
    ++ (modeKeys [ "n" "v" ] {
      "<Space>" = "<Nop>";
    });
}
