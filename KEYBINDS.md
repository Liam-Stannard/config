# Neovim keybinds

Every keymap this config defines, grouped by what it's for. The leader is `,` and the local leader is `\`.

- `<leader>?` lists the keymaps for the current buffer, and which-key pops up the rest of a `<leader>` group as you type it.
- **Mode** is `n` normal, `i` insert, `x` visual, `o` operator-pending (after `d`, `c`, `y` …) and `t` terminal. Blank means normal.
- **Where** says when a keymap only exists in some buffers. Blank means everywhere.

## Editing and movement

Defined in `nvim/lua/config/keymaps.lua`.

| Keys | Mode | Does |
| --- | --- | --- |
| `<C-s>` | n, i, x | Save (formats on save) |
| `<Esc>` | | Clear search highlight |
| `<C-d>` / `<C-u>` | | Half page down / up, cursor centred |
| `n` / `N` | | Next / previous search result, centred |
| `J` / `K` | x | Move the selected lines down / up |
| `<` / `>` | x | Indent left / right, keep the selection |
| `<leader>p` | x | Paste over the selection without losing what you copied |

### Text objects and motions

nvim-treesitter-textobjects (`nvim/lua/plugins/treesitter-textobjects.lua`). Use the selections after an operator or in visual mode, e.g. `daf`, `cia`, `vic`.

| Keys | Mode | Does |
| --- | --- | --- |
| `af` / `if` | x, o | A function / inside a function |
| `ac` / `ic` | x, o | A class / inside a class |
| `aa` / `ia` | x, o | A parameter / inside a parameter |
| `ao` / `io` | x, o | A loop / inside a loop |
| `a?` / `i?` | x, o | A conditional / inside a conditional |
| `]m` / `[m` | n, x, o | Next / previous function start |
| `]M` / `[M` | n, x, o | Next / previous function end |
| `]]` / `[[` | n, x, o | Next / previous class start |

### Surround

nvim-surround defaults (`nvim/lua/plugins/surround.lua`).

| Keys | Mode | Does |
| --- | --- | --- |
| `ys{motion}{char}` | | Surround, e.g. `ysiw"` quotes a word |
| `ds{char}` | | Delete surrounding, e.g. `ds(` |
| `cs{old}{new}` | | Change surrounding, e.g. `cs'"`; `cst` changes an HTML tag |
| `S{char}` | x | Surround the selection |

### Folding

Folds come from treesitter and all start open. These are Vim's own keys.

| Keys | Does |
| --- | --- |
| `za` | Toggle the fold under the cursor |
| `zc` / `zo` | Close / open the fold under the cursor |
| `zM` / `zR` | Close / open every fold |

## Windows, tabs and terminal

| Keys | Mode | Does | Where |
| --- | --- | --- | --- |
| `<C-h>` `<C-j>` `<C-k>` `<C-l>` | n, t | Move to the window left / below / above / right | |
| `<S-h>` / `<S-l>` | | Previous / next tab (bufferline) | |
| `<leader>bd` | | Close tab, keep the window layout | |
| `<leader>bo` | | Close other tabs | |
| `<leader>bp` | | Pin tab | |
| `<C-\>` | n, t | Toggle terminal (snacks) | |
| `<leader>;` | | Pick a breadcrumb (dropbar) | |

In the terminal, `<C-l>` moves to the window on the right rather than clearing the screen. Type `clear` instead.

## File tree (nvim-tree)

| Keys | Does |
| --- | --- |
| `<leader>bt` | Toggle the file tree |
| `<leader>bf` | Reveal the current file in the tree |
| `<leader>br` | Refresh the tree |
| `<leader>bc` / `<leader>be` | Collapse / expand the folder under the cursor |
| `<leader>bC` / `<leader>bE` | Collapse / expand the whole tree |
| `<leader>bb` | Toggle a bookmark |
| `<leader>bB` | Clear all bookmarks |
| `<leader>bm` | Move bookmarked files |

Inside the tree, nvim-tree's default keys apply (`g?` lists them), except `<C-k>`, which moves to the window above.

## Finding (Telescope)

| Keys | Mode | Does | Where |
| --- | --- | --- | --- |
| `<leader>ff` | | Find files | |
| `<leader>fg` | | Live grep | |
| `<leader>f.` | n, x | Grep the word under the cursor, or the selection | |
| `<leader>fb` | | Open buffers | |
| `<leader>fo` | | Recent files in this directory | |
| `<leader>fr` | | Reopen the last picker where you left it | |
| `<leader>fs` | | Symbols in this file | |
| `<leader>fw` | | Symbols in the workspace | |
| `<leader>ft` | | TODO comments | |
| `<leader>fh` | | Help tags | |
| `<leader>af` | | Find Angular files (no specs) | |
| `<leader>ag` | | Grep Angular files (no specs) | |
| `<leader>ac` | | Jump to the component's `.ts` | TS, HTML, SCSS, CSS |
| `<leader>at` | | Jump to the component's `.spec.ts` | TS, HTML, SCSS, CSS |
| `<leader>ah` | | Jump to the component's `.html` | TS, HTML, SCSS, CSS |
| `<leader>as` | | Jump to the component's `.scss` | TS, HTML, SCSS, CSS |

### Harpoon

| Keys | Does |
| --- | --- |
| `<leader>ha` | Add the file to Harpoon |
| `<leader>hh` | Harpoon quick menu |
| `<leader>h1` … `<leader>h4` | Go to Harpoon file 1–4 |

## Search and replace (grug-far)

| Keys | Mode | Does |
| --- | --- | --- |
| `<leader>sr` | | Search and replace across the project |
| `<leader>sw` | n | The same, starting from the word under the cursor |
| `<leader>sw` | x | The same, starting from the selection |

## Code and LSP

Defined in `nvim/lua/config/lsp.lua`. Most only exist once a language server has attached to the buffer.

| Keys | Mode | Does | Where |
| --- | --- | --- | --- |
| `K` | | Hover documentation | LSP |
| `gd` | | Go to definition | LSP |
| `gD` | | Go to declaration | LSP |
| `gi` | | Go to implementation | LSP |
| `go` | | Go to type definition | LSP |
| `gr` | | List references | LSP |
| `gs` | | Signature help | LSP |
| `<C-k>` | i | Signature help | LSP |
| `<F2>` | | Rename symbol | LSP |
| `<F3>` | n, x | Format the buffer or selection (conform) | |
| `<F4>` | | Code actions | LSP |
| `gO` | | Organise imports | LSP |
| `<leader>cR` | | Rename the file and update imports | TS / JS (vtsls) |
| `<leader>cf` | | ESLint: fix everything in the file | ESLint projects |
| `<leader>co` | | Organise imports | Java |
| `<leader>cv` | n, x | Extract variable | Java |
| `<leader>cm` | n, x | Extract method | Java |
| `]d` / `[d` | | Next / previous diagnostic, with its message | |
| `<leader>e` | | Show the diagnostic under the cursor | |
| `<leader>lr` | | Restart language servers | |

Neovim's own `grn` / `gra` / `grr` / `gri` / `grt` / `grx` keymaps are removed so that `gr` responds without a delay.

### Completion (blink.cmp)

| Keys | Mode | Does |
| --- | --- | --- |
| `<C-n>` / `<C-p>` | i | Next / previous item |
| `<CR>` | i | Accept |
| `<C-space>` | i | Open the menu, or show / hide documentation |
| `<C-d>` / `<C-u>` | i | Scroll documentation down / up |

### Diagnostics and lists (Trouble)

| Keys | Does |
| --- | --- |
| `<leader>xx` | All diagnostics |
| `<leader>xw` | Diagnostics in this buffer |
| `<leader>xt` | TODO comments |
| `]t` / `[t` | Next / previous TODO comment |

## Git

### Fugitive

| Keys | Does |
| --- | --- |
| `<leader>gs` | Status |
| `<leader>gc` | Commit |
| `<leader>gp` / `<leader>gP` | Push / pull |
| `<leader>gb` | Blame |
| `<leader>gd` | Diff the file against the index in a split |
| `<leader>gl` | Log |
| `<leader>gL` | Log for the current file |
| `<leader>gw` | Stage the current file |
| `<leader>go` | Discard changes to the current file |

### Diffview

| Keys | Does |
| --- | --- |
| `<leader>gv` | Uncommitted changes |
| `<leader>gV` | The branch as the MR will show it |
| `<leader>gh` | History of the current file |
| `<leader>gH` | History of the repo |
| `<leader>gq` | Close the diff view |

`<leader>gV` compares from where the branch left the remote's default branch to the files on disk, so uncommitted edits show too. A new file shows once it's added (`git add -N` is enough).

### Gitsigns (hunks)

| Keys | Does |
| --- | --- |
| `]c` / `[c` | Next / previous hunk (in diff mode, next / previous change) |
| `<leader>hs` | Stage the hunk |
| `<leader>hr` | Reset the hunk |
| `<leader>hp` | Preview the hunk |
| `<leader>gB` | Full blame for the current line |
| `<leader>gtb` | Toggle the end-of-line blame |

## Testing and scripts

### Jest (`nvim/lua/jest`)

| Keys | Does | Where |
| --- | --- | --- |
| `<leader>tf` | Run the current file | |
| `<leader>td` | Run the current file's directory | |
| `<leader>tn` | Run the nearest test | Not Java |
| `<leader>tl` | Rerun the last run | |
| `<leader>to` | Reopen the last results | |
| `<leader>tp` | Pick a test file to run | |
| `<leader>tt` | Last results in Trouble | |
| `<leader>ts` | Toggle the summary window | |

Inside Jest's own windows:

| Keys | Does | Where |
| --- | --- | --- |
| `<CR>` | Run the selected file | File picker |
| `<C-d>` | Run the selected file's directory | File picker |
| `<C-r>` | Rerun the last run | Results picker, summary window |
| `<C-t>` | Open the results in Trouble | Results picker |
| `<CR>` | Jump to the test | Summary window |
| `q` | Close | Summary window |

### Java tests (jdtls)

| Keys | Does |
| --- | --- |
| `<leader>tn` | Test the nearest method (replaces Jest's `<leader>tn` in Java buffers) |
| `<leader>tc` | Test the class |

### npm scripts (`nvim/lua/npm`)

| Keys | Does |
| --- | --- |
| `<leader>np` | Pick a script to run |
| `<leader>nl` | Rerun the last script |
| `<leader>nx` | Stop the last script |
| `<leader>no` | Toggle the output window |

## Debugging (nvim-dap)

| Keys | Does |
| --- | --- |
| `<F5>` / `<leader>dc` | Start or continue |
| `<F9>` / `<leader>db` | Toggle a breakpoint |
| `<leader>dB` | Conditional breakpoint (asks for the condition) |
| `<F10>` / `<leader>do` | Step over |
| `<F11>` / `<leader>di` | Step into |
| `<S-F11>` / `<leader>dO` | Step out |
| `<leader>dt` | Stop debugging |
| `<leader>du` | Toggle the debug UI |

## Toggles (snacks)

which-key shows whether each one is currently on.

| Keys | Toggles |
| --- | --- |
| `<leader>uw` | Line wrap |
| `<leader>us` | Spell check |
| `<leader>ul` | Line numbers |
| `<leader>ud` | Diagnostics |
| `<leader>uh` | Inlay hints |

## Sessions (persistence)

| Keys | Does |
| --- | --- |
| `<leader>qs` | Restore this directory's session |
| `<leader>qS` | Pick a session |
| `<leader>ql` | Restore the last session |
| `<leader>qd` | Don't save a session when you quit |

## Markdown

| Keys | Does | Where |
| --- | --- | --- |
| `<leader>mr` | Toggle rendered markdown | Markdown, agentic chat |
| `<leader>mp` | Preview with glow | |

## AI chat (agentic.nvim)

| Keys | Mode | Does |
| --- | --- | --- |
| `<leader>ii` | n, x | Toggle the chat |
| `<leader>ia` | n, x | Add the file or selection to the chat's context |
| `<leader>in` | n, x | New session |

Inside the chat (agentic's defaults):

| Keys | Mode | Does | Where |
| --- | --- | --- | --- |
| `q` | | Close the chat | Any chat window |
| `<S-Tab>` | n, i, x | Change mode | Any chat window |
| `\s` | | Switch provider (Claude / GitLab Duo) | Any chat window |
| `\m` | | Switch model | Any chat window |
| `\t` | | Change thinking level | Any chat window |
| `\o` | | Options | Any chat window |
| `\l` | | Pick a session | Any chat window |
| `\]` / `\[` | | Next / previous session | Any chat window |
| `\D` | | Delete the session | Any chat window |
| `<CR>`, `<C-s>` | n, i, x | Send the prompt (`<CR>` in normal mode only) | Prompt |
| `\p` | | Paste an image | Prompt |
| `<C-v>` | i | Paste an image | Prompt |
| `<Tab>` | i | Accept the completion | Prompt |
| `]]` / `[[` | | Next / previous heading | Chat |
| `]t` / `[t` | | Next / previous tool call | Chat |
| `]c` / `[c` | | Next / previous change | Diff preview |
| `<C-n>` / `<C-p>` | | Cycle the permission options | Permission prompt |
