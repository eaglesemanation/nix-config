{
  lib,
  config,
  ...
}:
lib.mkIf (builtins.elem "go" config.emnt.lang_support.langs) {
  plugins = {
    lsp.servers.gopls.enable = true;
    lint.lintersByFt.go = [ "golangcilint" ];
    neotest.adapters.golang.enable = true;
    overseer.settings.templates = [
      "nixvim.go"
    ];
    dap.adapters.servers.go = # lua
      ''
        function(callback, config)
          if config.mode == 'remote' and config.request == 'attach' then
            callback({
              type = 'server',
              host = config.host or '127.0.0.1',
              port = config.port or '38697'
            })
          else
            callback({
              type = 'server',
              port = '$${port}',
              executable = {
                command = 'dlv',
                args = { 'dap', '-l', '127.0.0.1:$${port}', '--log', '--log-output=dap' },
                detached = vim.fn.has("win32") == 0,
              }
            })
          end
        end
      '';
  };
  extraFiles."lua/overseer/template/nixvim/go.lua".text = # lua
    ''
      -- Searches for all instances of main package and creates templates for running them through delve
      return {
        cache_key = function(opts)
          return vim.fs.root(0, {"go.mod"})
        end,
        condition = {
          filetype = {"go", "gomod"},
          callback = function(search)
            return vim.fs.root(0, {"go.mod"}) ~= nil
          end,
        },
        generator = function(opts, cb)
          local templates = {}
          local module_root = vim.fs.root(0, {"go.mod"})

          local module_name_exec = vim.system({"go", "list", "-m"}, {cwd = module_root}):wait()
          if module_name_exec.code ~= 0 then
            cb({})
            return
          end
          local module_name = module_name_exec.stdout:gsub("\n", "")

          local packages_exec = vim.system({"go", "list", "-f", "{{.ImportPath}}:{{.Name}}", "./..."}, {cwd = module_root}):wait()
          if packages_exec.code ~= 0 then
            cb({})
            return
          end

          for package in packages_exec.stdout:gmatch("[^\r\n]+") do
            local import_path, pkg_name = package:match("(.+):(.+)")
            local rel_path = import_path:gsub("^" .. vim.pesc(module_name), ".")
            if pkg_name ~= "main" then
              goto continue
            end

            table.insert(templates, {
              name = string.format("go debug: %s", import_path),
              tags = { "go", "debug", "dap" },
              params = {
                args = { type = "list", delimiter = " ", default = {} },
              },
              builder = function(params)
                local binary_path = vim.fn.tempname()
                return {
                  cmd = { "dlv" },
                  args = vim.list_extend(
                    { "debug", rel_path, "--output", binary_path, "--build-flags", "-v", "--headless", "--" },
                    params.args
                  ),
                  components = {
                    {
                      "nixvim.run_on_output",
                      pattern = "API server listening at: (.+):(%d+)",
                      oneshot = true,
                      callback = function(line, pattern)
                        local host, port = line:match(pattern)
                        local dap = require("dap")
                        dap.run({
                          type = "go",
                          name = string.format("go debug: %s", import_path),
                          mode = "remote",
                          request = "attach",
                          port = port,
                          host = host,
                        })
                      end,
                    },
                    "default",
                  },
                }
              end,
            })
            ::continue::
          end
          cb(templates)
        end
      }
    '';
}
