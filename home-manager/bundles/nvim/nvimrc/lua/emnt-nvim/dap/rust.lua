local dap = require("dap")
local job = require("plenary.job")

local M = {}

local function debug_cargo_package(cwd, args, target_dir, package_name, on_success)
    vim.notify(string.format("Compiling a debug build of %s", package_name), vim.log.levels.INFO)

    local _, code = job:new({
        command = "cargo",
        env = {
            -- Include debug info, ignoring Cargo.toml config
            ["RUSTFLAGS"] = "-g",
        },
        args = {
            "build",
            "--package",
            package_name,
        },
        cwd = cwd,
    })

    if code and code > 0 then
        vim.notify(string.format("Could not compile %s", package_name), vim.log.levels.ERROR)
        return
    end

    dap.run({
        type = "lldb",
        request = "launch",
        program = string.format("%s/debug/%s", target_dir, package_name),
        cwd = cwd,
        args = args,
        stopOnEntry = false,
        runInTerminal = false,
    })

    on_success()
end

-- Finds executable cargo target. If there are multiple - asks user to select. Passes target name to callback
local function select_target(cwd, args, on_success)
    local j, code = job:new({
        command = "cargo",
        args = {
            "metadata",
            "--no-deps",
            "--format-version=1",
            "--quiet",
        },
        cwd = cwd,
        enabled_recording = true,
    }):sync()

    if code > 0 then
        vim.notify("Could not get Cargo metadata", vim.log.levels.ERROR)
        return
    end

    -- Parse JSON output from cargo
    local packages = {}
    local target_dir = ""
    for _, val in pairs(j) do
        local json = vim.fn.json_decode(val)
        if
            type(json) == "table"
            and json.packages ~= vim.NIL
            and json.packages ~= nil
            and json.target_directory ~= vim.NIL
            and json.target_directory ~= nil
        then
            packages = json.packages
            target_dir = json.target_directory
            break
        end
    end

    -- Filter out packages that don't have binary target
    local binary_packages = {}
    for _, package in pairs(packages) do
        local keep = false
        if type(package.targets) ~= "table" then
            goto continue
        end

        for _, target in pairs(package.targets) do
            if type(target.kind) ~= "table" then
                goto continue
            end

            for _, kind in pairs(target.kind) do
                if kind == "bin" then
                    keep = true
                    goto keep_package -- Already of type "bin", no need to verify other targets
                end
            end
            ::continue::
        end
        ::keep_package:: -- Jump here if any target in package has "bin" kind
        if keep then
            table.insert(binary_packages, package.name)
        end
        ::continue::
    end

    -- Select one of available targets. If target is single - skip selection
    if #binary_packages == 0 then
        vim.notify("Could not find any binary targets", vim.log.levels.ERROR)
    elseif #binary_packages == 1 then
        debug_cargo_package(cwd, args, target_dir, binary_packages[1], on_success)
    else
        vim.ui.select(binary_packages, {
            prompt = "Cargo Binary Target",
        }, function(package_name)
            debug_cargo_package(cwd, args, target_dir, package_name, on_success)
        end)
    end
end

-- Determines how to run opened rust file
M.run = function(args, on_success)
    args = args or {}
    on_success = on_success or function() end
    local cwd = vim.fn.expand("%:p:h")

    if vim.fn.executable("cargo") ~= 1 then
        vim.notify("Could not find cargo, verify Rust toolchain", vim.log.levels.ERROR)
        return
    end

    select_target(cwd, args, on_success)
end

return M
