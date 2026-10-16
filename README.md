# c-ide

A keyboard-first C IDE that runs in the terminal. It is built on Neovim and themed after VS Code's **Dark Modern**.
It is meant to be driven entirely from the keyboard, though the mouse also works.

- File explorer, editor tabs, status bar and an integrated terminal, laid out like VS Code
- **clangd** for completion, diagnostics, go to definition, rename, formatting and .c/.h switching
- **F5** builds and runs the code. It detects CMake, then a Makefile, and otherwise compiles the single file with ASan/UBSan.
- **gdb** debugging (gdb's native DAP mode) with breakpoints, stepping, variables and watches
- VS Code shortcuts: `Ctrl+P`, `Ctrl+Shift+F`, `Ctrl+B`, `Ctrl+J`, `Ctrl+/`, `F12`, `F2`, `F9`/`F10`/`F11`
- Toggles: code coloring on/off (`F7`), and peeking parameter-name inlay hints (`Ctrl+Alt+H`)
- Markdown preview: rendered in the editor (`Ctrl+Shift+V`), or live in the browser with scroll sync (`Space m b`)
- Lightweight. With clangd running it uses about 115 MB of RAM in total, while VS Code with the same file uses about 1.2 GB.

## Requirements

- Neovim >= 0.11 (tested on 0.12)
- Node.js + npm (only for the browser markdown preview)
- `git`, `gcc`, `clangd`, `gdb` >= 14, `make`, `ripgrep`
- Optional: `foot` (dedicated window), `fd`, `lazygit`, `cmake` + `ninja`, `wl-clipboard`
- A Nerd Font, for example *Cascadia Mono NF*

On Fedora:

```sh
sudo dnf install neovim git gcc clang-tools-extra gdb make ripgrep fd-find lazygit foot cmake ninja-build wl-clipboard cascadia-mono-nf-fonts
```

## Install

```sh
./install.sh
```

The installer symlinks `nvim/` to `~/.config/nvim` and `bin/cide` to `~/.local/bin/cide`, and creates a
"C IDE" entry in the app menu. If a `~/.config/nvim` already exists, it is backed up before the link is made.
Because the files are symlinked, any edit to this repo takes effect the next time Neovim starts.

To undo the installation, run `./uninstall.sh`.

## Usage

```sh
cide                 # open the current directory in this terminal
cide path/to/project
cide -w path/to/file.c   # open in a dedicated foot window (full key support)
```

The dedicated window is useful because some terminals cannot tell certain keys apart (`Ctrl+Shift+F`, `Ctrl+Alt+H`, ...).
foot supports the kitty keyboard protocol, so every shortcut works there. Every shortcut also has a `Space ...`
alternative that works in any terminal.

Inside the editor:

- `Space` (then wait) lists every command
- `Space h` opens the cheat sheet ([nvim/CHEATSHEET.md](nvim/CHEATSHEET.md))
- `:Tutor` is the interactive Vim tutorial, worth doing once

## Layout

```
bin/cide                  launcher script
desktop/cide.desktop.in   app menu entry template
foot/foot.ini             dedicated terminal window (Dark Modern palette)
nvim/
  init.lua                entry point, bootstraps lazy.nvim
  lazy-lock.json          pinned plugin versions
  CHEATSHEET.md
  lua/cide/
    options.lua           editor options (mirrors the VS Code settings)
    keymaps.lua           global shortcuts
    autocmds.lua          auto save, treesitter, misc
    runner.lua            build / run / debug-build logic
    toggles.lua           syntax coloring and inlay hint toggles
    plugins/
      ui.lua              theme, explorer, tabs, status line, which-key
      editor.lua          telescope, terminal, git, problems panel, editing helpers
      lsp.lua             clangd + completion
      debug.lua           nvim-dap + gdb
      markdown.lua        in-editor and browser markdown preview
```

## Build & run rules (F5)

| Project has      | F5 does                                                                 |
|------------------|-------------------------------------------------------------------------|
| `CMakeLists.txt` | configures `build/` (Ninja, Debug), builds it, runs the newest executable |
| `Makefile`       | runs `make`, then `make run` if that target exists                       |
| neither          | `gcc -std=c17 -Wall -Wextra -g -fsanitize=address,undefined` → `./build/<name>`, then runs it |

The debugger (F6) uses the same rules but leaves out the sanitizers. For projects, it asks which executable
to debug and suggests the newest one.

## Known limitations

- A terminal cannot report a held modifier key on its own. VS Code shows parameter names while Ctrl+Alt is held;
  here they appear when you press `Ctrl+Alt+H` and disappear on the next cursor move.
- When debugging, a program that reads from stdin (`scanf`) cannot take input from the debugger UI.
  Use F5 for interactive programs.
- GNOME terminals use F11 for fullscreen. Use `Space d i` to step into instead.

## License

[MIT](LICENSE)
