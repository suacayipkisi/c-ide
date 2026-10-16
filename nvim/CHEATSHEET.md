# C IDE cheat sheet            (close: <leader>q  |  leader = Space)

## Start here: everyday keys
Learn these first. Everything else below is reference.

| Key                      | Action                                         |
|--------------------------|------------------------------------------------|
| i / Esc                  | Start typing / stop typing (back to commands)  |
| Ctrl+S                   | Save (auto save is also on)                    |
| Ctrl+C / Ctrl+X / Ctrl+V | Copy / cut / paste                             |
| Ctrl+Z                   | Undo                                           |
| Ctrl+P                   | Open a file by name                            |
| Ctrl+B                   | Show / hide the file explorer                  |
| Ctrl+J                   | Show / hide the terminal                       |
| Ctrl+/                   | Comment / uncomment                            |
| F5                       | Build & run                                    |
| F9 / F6 / F10            | Breakpoint / start debugging / next line       |
| F12                      | Go to definition                               |
| F2                       | Rename                                         |
| Space (then wait)        | Menu with every other command                  |
| Ctrl+Q                   | Quit                                           |

## VS Code style
| Key                  | Action                                  |
|----------------------|-----------------------------------------|
| Ctrl+S               | Save all (auto save is also on)         |
| Ctrl+C / Ctrl+X      | Copy / cut selection (no selection: line)|
| Ctrl+V               | Paste (system clipboard)                |
| Ctrl+P               | Go to file                              |
| Ctrl+Shift+F         | Search in all files  (also Space f g)   |
| Ctrl+F               | Find in current file (also /)           |
| F1 / Ctrl+Shift+P    | Command palette                         |
| Ctrl+B               | Toggle explorer      (Space e = focus)  |
| Ctrl+J / Ctrl+`      | Toggle terminal                         |
| Ctrl+/               | Toggle comment                          |
| Alt+Up / Alt+Down    | Move line                               |
| Shift+Alt+Down       | Duplicate line                          |
| Shift+Alt+F          | Format document                         |
| Ctrl+Shift+M         | Problems panel       (also Space x x)   |
| F8 / Shift+F8        | Next / previous problem                 |
| Ctrl+\               | Split editor right                      |
| Shift+L / Shift+H    | Next / previous tab (Ctrl+PgDn/PgUp)    |
| Space 1..5           | Go to tab N                             |
| Space q              | Close tab                               |
| Ctrl+Q / Space Q     | Quit the IDE (asks first)               |

## Code (clangd)
| Key            | Action                                   |
|----------------|------------------------------------------|
| F12 / gd       | Go to definition                         |
| Shift+F12 / gr | Find references                          |
| K              | Hover docs                               |
| F2             | Rename symbol                            |
| Ctrl+.         | Quick fix / code action                  |
| Alt+O          | Switch .c <-> .h                         |
| Ctrl+Space     | Trigger completion                       |
| Tab / Enter    | Accept completion                        |
| Ctrl+O / Ctrl+I| Jump back / forward                      |
| Ctrl+Alt+H     | Peek parameter names (hidden on next move)|
| Space u h      | Inlay hints on/off (permanent)           |

## Toggles
| Key            | Action                                   |
|----------------|------------------------------------------|
| F7 / Space u c | Code coloring on/off                     |
| Space u w      | Word wrap on/off                         |
| Space u n      | Relative line numbers on/off             |

## Markdown (.md files)
| Key                       | Action                                    |
|---------------------------|-------------------------------------------|
| Ctrl+Shift+V / Space m p  | Rendered preview in the editor on/off     |
| Space m b                 | Live preview in the browser (scroll sync) |

## Build, run, debug
| Key          | Action                                            |
|--------------|---------------------------------------------------|
| F5 / Space r | Build & run (CMake > Makefile > single file)      |
| Space R      | Build only                                        |
| F6 / Space dd| Start debugging / continue                        |
| F9 / Space db| Toggle breakpoint                                 |
| F10 / Space dn| Step over                                        |
| F11 / Space di| Step into (F11 may be fullscreen in the terminal)|
| Shift+F11 / Space do | Step out                                  |
| Shift+F5 / Space dq  | Stop                                      |
| Space de     | Evaluate expression under cursor                  |

Single files are built with `gcc -std=c17 -Wall -Wextra -g -fsanitize=address,undefined`
into `./build/<name>`. A Makefile `run:` target is used if it exists.

## Moving without the mouse (the Vim essentials)
| Key              | Action                                       |
|------------------|----------------------------------------------|
| i / a / o / O    | Insert before / after cursor, new line below / above |
| Esc              | Back to normal mode                          |
| h j k l          | Left / down / up / right                     |
| w / b / e        | Next word / previous word / end of word      |
| 0 / ^ / $        | Line start / first char / line end           |
| gg / G / 42G     | File start / end / line 42                   |
| 5j / 12k         | 5 lines down / 12 up (see relative numbers)  |
| { / }            | Previous / next paragraph (block)            |
| %                | Jump to matching bracket                     |
| s + 2 letters    | Jump anywhere on screen (flash)              |
| Ctrl+D / Ctrl+U  | Half page down / up                          |
| dd / yy / p      | Delete (cut) line / copy line / paste        |
| ciw / ci( / ci"  | Change word / inside parens / inside quotes  |
| u / Ctrl+R       | Undo / redo                                  |
| v / V            | Select characters / lines                    |
| Alt+V            | Block (column) selection                     |
| .                | Repeat last change                           |
| * / n / N        | Search word under cursor / next / previous   |

## Windows & terminal
| Key            | Action                                     |
|----------------|--------------------------------------------|
| Alt+h/j/k/l    | Move between explorer / editor / terminal  |
| Esc Esc        | Leave terminal typing mode                 |
| Space t f      | Floating terminal                          |
| Space g g      | Lazygit                                    |

## Explorer (when focused)
`a` new file (end with / for a folder), `d` delete, `r` rename, `c`/`m` copy/move,
`l`/Enter open, `h` close folder, `H` hidden files, `?` help.

`:q`, `ZZ` or `Ctrl+W q` on the last file closes the file, not the IDE.
If the IDE ever closes unexpectedly, the last keys pressed are in
`~/.local/state/nvim/cide-last-keys.log`.

Press **Space** and wait to see every leader shortcut. `Space ?` lists all keys.
New to Vim? Run `:Tutor` once (≈30 min) — it pays off fast.
