-- Build & run logic shared by F5 (run) and the debugger (F6).
-- Project detection order: CMakeLists.txt -> Makefile -> single file.
local M = {}

local C_FLAGS = "-std=c17 -Wall -Wextra -g"
local CXX_FLAGS = "-std=c++20 -Wall -Wextra -g"
local SANITIZE = "-fsanitize=address,undefined"

local esc = vim.fn.shellescape

local function project()
  local file = vim.api.nvim_buf_get_name(0)
  local cmake = vim.fs.root(0, { "CMakeLists.txt" })
  if cmake then return { kind = "cmake", root = cmake, file = file } end
  local make = vim.fs.root(0, { "Makefile", "makefile", "GNUmakefile" })
  if make then return { kind = "make", root = make, file = file } end
  return { kind = "single", root = vim.fs.dirname(file), file = file }
end

local function single_file_cmd(p, sanitize)
  local ft = vim.bo.filetype
  if ft ~= "c" and ft ~= "cpp" then return nil end
  local compiler = ft == "c" and "gcc" or "g++"
  local flags = ft == "c" and C_FLAGS or CXX_FLAGS
  if sanitize then flags = flags .. " " .. SANITIZE end
  local out = p.root .. "/build/" .. vim.fn.fnamemodify(p.file, ":t:r")
  local cmd = string.format("mkdir -p %s && %s %s %s -o %s -lm",
    esc(p.root .. "/build"), compiler, flags, esc(p.file), esc(out))
  return cmd, out
end

local function cmake_build_cmd(p)
  local build = p.root .. "/build"
  return string.format(
    "cmake -S %s -B %s -G Ninja -DCMAKE_BUILD_TYPE=Debug -DCMAKE_EXPORT_COMPILE_COMMANDS=ON >/dev/null && cmake --build %s",
    esc(p.root), esc(build), esc(build))
end

-- Newest executable directly inside dir (a decent guess for "the program")
local function newest_executable(dir)
  local best, best_time
  for name, type in vim.fs.dir(dir) do
    local path = dir .. "/" .. name
    if type == "file" and vim.fn.executable(path) == 1 then
      local stat = vim.uv.fs_stat(path)
      if stat and (not best_time or stat.mtime.sec > best_time) then
        best, best_time = path, stat.mtime.sec
      end
    end
  end
  return best
end

local function in_terminal(cmd)
  vim.cmd("silent! wall")
  require("toggleterm").exec("clear; " .. cmd, 1, nil, nil, "horizontal", nil, false, true)
  vim.schedule(function() vim.cmd("startinsert") end)
end

local function shell_cmd(p, run)
  if p.kind == "cmake" then
    local cmd = cmake_build_cmd(p)
    if run then
      cmd = cmd .. string.format(
        [[ && exe=$(find %s -maxdepth 1 -type f -executable -printf '%%T@ %%p\n' | sort -nr | head -1 | cut -d' ' -f2-) && echo "▶ $exe" && "$exe"]],
        esc(p.root .. "/build"))
    end
    return cmd
  elseif p.kind == "make" then
    local cmd = "make -C " .. esc(p.root)
    if run then
      cmd = cmd .. string.format(
        [[ && if make -C %s -n run >/dev/null 2>&1; then make -s -C %s run; else echo "Build OK (no 'run' target in Makefile)"; fi]],
        esc(p.root), esc(p.root))
    end
    return cmd
  end
  local cmd, out = single_file_cmd(p, true)
  if not cmd then return nil end
  if run then
    cmd = string.format("%s && cd %s && %s", cmd, esc(p.root), esc(out))
  end
  return cmd
end

function M.run()
  local cmd = shell_cmd(project(), true)
  if not cmd then return vim.notify("Not a C/C++ file and no Makefile/CMakeLists.txt found", vim.log.levels.WARN) end
  in_terminal(cmd)
end

function M.build_only()
  local cmd = shell_cmd(project(), false)
  if not cmd then return vim.notify("Nothing to build here", vim.log.levels.WARN) end
  in_terminal(cmd)
end

-- Used by nvim-dap: builds synchronously and returns the program path (or nil on failure).
function M.build_for_debug()
  vim.cmd("silent! wall")
  local p = project()
  local cmd, out
  if p.kind == "single" then
    cmd, out = single_file_cmd(p, false)
    if not cmd then return nil end
  elseif p.kind == "cmake" then
    cmd = cmake_build_cmd(p)
  else
    cmd = "make -C " .. esc(p.root)
  end

  local output = vim.fn.system(cmd .. " 2>&1")
  if vim.v.shell_error ~= 0 then
    vim.fn.setqflist({}, " ", { title = "Build errors", lines = vim.split(output, "\n"), efm = vim.o.errorformat })
    vim.cmd("copen")
    vim.notify("Build failed", vim.log.levels.ERROR)
    return nil
  end

  if out then return out, p.root end
  local guess = newest_executable(p.kind == "cmake" and p.root .. "/build" or p.root) or (p.root .. "/")
  local path = vim.fn.input({ prompt = "Program to debug: ", default = guess, completion = "file" })
  if path == "" then return nil end
  return path, p.root
end

return M
