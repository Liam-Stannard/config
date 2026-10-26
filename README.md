# config

Personal config files for nvim, kitty and git, set up for CachyOS / Arch.

## Setup

Link each config into place. Back up anything already there first.

```fish
set repo ~/data/git/config

ln -s $repo/nvim ~/.config/nvim
ln -s $repo/kitty ~/.config/kitty
ln -s $repo/git/.gitconfig ~/.gitconfig
```

Then create `~/.gitconfig.local` for your name and email (kept out of the repo):

```ini
[user]
	name = Your Name
	email = you@example.com
```

Install everything below in one go:

```fish
sudo pacman -S --needed neovim git ripgrep fd tree-sitter-cli nodejs npm \
    unzip gcc make jdk-openjdk rustup glow ttf-jetbrains-mono-nerd kitty
rustup default stable
rustup component add rustfmt rust-src
npm i -g @agentclientprotocol/claude-agent-acp
```

## nvim

Plugins are managed by [lazy.nvim](https://github.com/folke/lazy.nvim), which installs itself on first start.

### System packages

| Needed for | Package | Used by |
| --- | --- | --- |
| Neovim 0.12+ | `neovim` | Config uses `vim.lsp.enable`, `vim.lsp.config`, `vim.system` |
| Cloning plugins | `git` | lazy.nvim, fugitive, gitsigns |
| File search and grep | `ripgrep` | Telescope `live_grep` and Angular pickers, `jest.pick()` |
| Faster file finding | `fd` | Telescope `find_files` (falls back to `rg`) |
| Building parsers | `tree-sitter-cli`, `gcc` | nvim-treesitter (`main` branch) |
| Building and unpacking tools | `unzip`, `gcc`, `make` | Mason, blink.cmp |
| JS/TS tooling | `nodejs`, `npm` | Mason npm packages, jest, npm runner, js-debug-adapter |
| Java | `jdk-openjdk` (25 or newer to run jdtls) | jdtls, java-debug-adapter, java-test |
| Rust | `rustup` (+ `rustfmt`, `rust-src`) | rust-analyzer, `rustfmt` formatting via conform |
| Markdown preview | `glow` | glow.nvim (`<leader>mp`) |
| Icons | a Nerd Font | nvim-tree, nvim-web-devicons, which-key |

Optional:

- **`yarn` or `pnpm`**: the npm runner uses these when a project has a `yarn.lock` or `pnpm-lock.yaml`.
- **`claude-agent-acp`**: the default provider for agentic.nvim (`<leader>ii`). Install it with `npm i -g @agentclientprotocol/claude-agent-acp`.
- **`gitlab-duo-acp`**: the alternative agentic.nvim provider. Download the release binary into `~/.local/bin` from [gitlab-duo-acp](https://gitlab.com/reprazent/gitlab-duo-acp), and set `GITLAB_URL` and `GITLAB_AUTH_TOKEN` in the shell that launches nvim.

### Installed automatically by Mason

These are installed on first start into `~/.local/share/nvim/mason`. They only need the system packages above.

| Tool | Kind | Language |
| --- | --- | --- |
| `vtsls` | LSP | TypeScript / JavaScript |
| `angularls` | LSP | Angular (also needs `@angular/language-service` and `typescript` in the project's `node_modules`) |
| `lua_ls` | LSP | Lua |
| `bashls` | LSP | Bash |
| `rust_analyzer` | LSP | Rust |
| `jdtls` | LSP | Java |
| `prettier` | Formatter | TS, JS, HTML, CSS, SCSS, JSON |
| `stylua` | Formatter | Lua |
| `shfmt` | Formatter | Shell |
| `google-java-format` | Formatter | Java |
| `eslint_d` | Linter | TS / JS |
| `js-debug-adapter` | Debugger | Node / Chrome (Jest, `ng serve`) |
| `java-debug-adapter`, `java-test` | Debugger | Java |

### Treesitter parsers

Built on first start, which needs `tree-sitter-cli`: bash, c, elixir, groovy, html, java, javascript, lua, markdown, markdown_inline, python, rust, typescript, vim, vimdoc.

### Project-level requirements

- **Jest** (`lua/jest`): runs `node_modules/.bin/jest`, falling back to `npx jest`.
- **Jest debugging** (dap): expects `node_modules/.bin/jest` in the project.
- **Angular**: projects are detected by `angular.json` or `project.json`.

### Java paths

`nvim/ftplugin/java.lua` reads its Java paths from environment variables. Nothing machine-specific is stored in the repo.

| Variable | What it sets | Default |
| --- | --- | --- |
| `JDTLS_JAVA_HOME` | Java used to run jdtls itself. Recent jdtls needs Java 25 or newer. | Newest `/usr/lib/jvm/java-<N>-openjdk`, then `$JAVA_HOME` |
| `JDTLS_RUNTIMES` | JDKs that projects can build against | Every installed `/usr/lib/jvm/java-<N>-openjdk`, as `JavaSE-<N>` |

With pacman's `jdk-openjdk`, the defaults just work. To use other JDKs, set the variables in the shell that launches nvim, for example in fish:

```fish
set -gx JDTLS_JAVA_HOME /usr/lib/jvm/java-27-openjdk
set -gx JDTLS_RUNTIMES "JavaSE-17=~/.jdks/corretto-17,JavaSE-21=/usr/lib/jvm/java-21-openjdk"
```

Run `:checkhealth` after the first start to confirm everything is found.

## kitty

| Needed for | Package |
| --- | --- |
| Terminal | `kitty` |
| Font (`font_family JetBrainsMono Nerd Font`) | `ttf-jetbrains-mono-nerd` |

The Nerd Font also provides the icon on the active tab and the icons in nvim. Without it, kitty falls back to another font and icons show as boxes.

## git

| Needed for | Package / file |
| --- | --- |
| `core.editor`, `diff.tool` (`nvimdiff`) | `neovim` |
| Name and email | `~/.gitconfig.local` (see Setup) |

The credential helper (`cache`) is built into git.
