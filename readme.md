# Dotfiles

All my dotfiles and configuration and stuff like that.

## Layout

Home-directory dotfiles live at the top level; `config/` mirrors `~/.config`.
The `install` script symlinks each one to its real home:

| Repo path                   | Symlinked to                    |
| --------------------------- | ------------------------------- |
| `zshrc`                     | `~/.zshrc`                      |
| `bashrc`                    | `~/.bashrc`                     |
| `tmux.conf`                 | `~/.tmux.conf`                  |
| `ideavimrc`                 | `~/.ideavimrc`                  |
| `vimrc`                     | `~/.vimrc`                      |
| `gitconfig`                 | `~/.gitconfig`                  |
| `ssh_rc`                    | `~/.ssh/rc`                     |
| `ssh_config`                | `~/.ssh/config`                 |
| `config/nvim/`              | `~/.config/nvim` (whole folder) |
| `config/git/ignore`         | `~/.config/git/ignore`          |
| `config/git/stack.sh`       | `~/.config/git/stack.sh`        |
| `config/lazygit/config.yml` | `~/.config/lazygit/config.yml`  |
| `config/hunk/config.toml`   | `~/.config/hunk/config.toml`    |

Only nvim is linked as a whole folder; the rest are linked file by file because
those apps keep state files next to their config (e.g. hunk's `state.json`).

`ssh_config` only holds the GitHub setup. It includes `~/.ssh/config.local`
first, so put servers and anything private or machine-specific there; it is
never committed. On a machine that already had a `~/.ssh/config`, `install`
moves it to `~/.ssh/config.bak`, so copy its hosts into `config.local`.

To add a new dotfile: put it at the repo root, or under `config/<app>/` if it
lives in `~/.config`, and add one line to the `LINKS` array in `install`.

The rule for what goes here: if a tool reads it, it belongs in this repo. Setup
that is specific to a Mac (Homebrew, macOS defaults, app preferences the apps
rewrite themselves, work tooling) lives in the private `startup` repo, which
runs this `install` as one of its steps.

`config/nvim` used to be the separate `nvim-config` repo. It was merged in with
`git subtree`, so its history is here too: `git log 6809021^2`.

## Install

```bash
git clone https://github.com/GraysonNocera/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install
```

The script creates any missing parent directories (e.g. `~/.ssh`), backs up any
existing real file to `$file.bak`, symlinks everything, and installs the tmux
plugin manager (tpm) if it's missing. It's safe to re-run.

After the first tmux launch, press `prefix + I` to install tmux plugins.

## Stacked branches

A stack is a chain of branches, one per PR, each built on the one below. The
`git stack*` aliases in `gitconfig` call `~/.config/git/stack.sh`. A layer is
any local branch between the stack base and `HEAD`, so run them from the top
layer. You name the base each time you restack; `git stack-restack <base>`
saves it as `git config stack.base` (default `master`), and the other aliases
read it from there. It is per repo, so every worktree of the repo shares it.

A **stray** is a ref holding commits the stack lacks: `origin/<layer>` with a
commit you never had locally (a GitHub "Commit suggestion"), or a local branch
that forked off a layer. Restack, fixup and absorb refuse to run while a stray
exists, so adopt strays first (restack adopts the ones GitHub only rebased
itself; see below). Those three and adopt also refuse when any local
branch sits above `HEAD`, when a layer is checked out in another worktree (the
rebase would skip it), or when the stack has merge commits. A branch forked off
the top layer's tip is flagged as a stray but cannot be adopted, because it
sits above `HEAD`; switch to it instead, since it is the new top.

| Alias | What it does |
| ----- | ------------ |
| `git stack` | Lists the layers bottom to top with each one's commit count and `+/-` lines against the layer below ("same commit as" for an empty layer), then flags every stray with the `stack-adopt` command for it. Read-only. Run from a lower layer, it reports the layers above you as strays. |
| `git stack-restack <base>` | Fetches origin, fast-forwards the local `<base>` to `origin/<base>`, saves it as `stack.base`, then moves every layer onto it with one `rebase --update-refs`. Pass the current base to pick up new commits, or a new one to move the stack, e.g. onto `master` once its integration branch merges. `<base>` must be a local branch with a copy on origin, and not the one checked out. It refuses to move off an old base that is not yet merged into `<base>` (checking `origin/<old>` if you deleted it locally), since the rebase would rewrite the old base's commits into the stack and `stack-push` would force-push them. It does not stop you from naming one of your layers, which drops it and the layers below from the stack; restacking back is then refused for the same reason, so undo it with the `git config stack.base <real base>` the error prints. The fetch and fast-forward come first, so a refused restack has usually still fast-forwarded `<base>`. `stack.base` changes once the rebase finishes or stops on a conflict (the error then says how to back out), not when the rebase fails to start. It skips the fast-forward when `<base>` already matches `origin/<base>`, so `<base>` can stay checked out in another worktree; when it is behind there, it prints the `git -C <worktree> merge --ff-only` to run, and when it has commits origin lacks, it asks you to push it first. Before rebasing it adopts every `origin/<layer>` that holds nothing new once `<base>`'s commits count (what GitHub leaves after merging a PR in a GitHub stack), so a merged batch needs only restack and push; a reviewer's commit still stops it for a manual `stack-adopt`. |
| `git stack-push` | Pushes every layer with `-u` in one atomic push with `--force-with-lease --force-if-includes`: all layers or none, and never over a remote commit you haven't seen. Extra options go to `git push`; branch names don't, since they land before `origin`. |
| `git stack-fixup <layer>` | Commits the staged changes as a fixup of that layer's tip, then autosquashes and restacks everything above it. Use it for new files, or when you want to pick the layer yourself. |
| `git stack-absorb` | Runs `git absorb`: each staged hunk becomes a fixup of the commit that last touched those lines, even another author's, then autosquashes. Needs `absorb.fixupTargetAlwaysSHA=true` because the stack repeats subjects. It can pick a lower layer when the fix belongs higher; use `stack-fixup` then. |
| `git stack-adopt <branch\|origin/branch>` | Pulls a stray's commits into the right layer. For `origin/<layer>` it skips every version of the layer you have had, so only the reviewer's commits land on that layer. A forked local branch becomes a new layer at its fork point. Run `git stack` afterwards. |

lazygit binds them in the Local branches panel (`ctrl+a` works in Files too):

| Key | Runs |
| --- | ---- |
| `ctrl+l` | `git stack`, full screen |
| `ctrl+r` | a menu of your local branches (current base first, then most recent, with layers labelled; `/` searches, Enter twice picks), then `git stack-restack` onto the one you pick |
| `B` | the same menu, then `git config stack.base` to the one you pick (no fetch, no rebase) and `git stack`; use it to undo restacking onto one of your layers |
| `ctrl+u` | `git stack-push`, after a confirm |
| `ctrl+f` | `git stack-fixup` on the selected branch, after a confirm |
| `ctrl+a` | `git stack-absorb` |
| `ctrl+b` | a menu of the strays `git stack` reports, then `git stack-adopt` on the one you pick |

`ctrl+r` and `ctrl+u` replace lazygit's recent-repos and scroll-up keys in that
panel only.

## Extra tooling

Handy install commands for a fresh machine.

### macOS

```bash
brew install nvim
brew install zoxide   # smarter cd (zshrc aliases `cd` to it)
brew install eza      # modern ls (zshrc aliases ls/ll/tree to it)
dotnet tool install -g EasyDotnet
brew tap omnisharp/omnisharp-roslyn
brew update
brew install --cask font-jetbrains-mono-nerd-font
```

### Linux

```bash
# neovim
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
sudo rm -rf /opt/nvim-linux-x86_64
sudo tar -C /opt -xzf nvim-linux-x86_64.tar.gz
export PATH="$PATH:/opt/nvim-linux-x86_64/bin"

# node + npm (via nvm)
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.4/install.sh | bash
nvm install node
nvm use node
npm install tree-sitter-cli

# ripgrep
curl -LO https://github.com/BurntSushi/ripgrep/releases/download/14.1.1/ripgrep_14.1.1-1_amd64.deb
sudo dpkg -i ripgrep_14.1.1-1_amd64.deb

# lazygit
go install github.com/jesseduffield/lazygit@latest

# zoxide (smarter cd; zshrc aliases `cd` to it)
curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh

# eza (modern ls; zshrc aliases ls/ll/tree to it)
cargo install eza   # or: apt install eza  (on recent Debian/Ubuntu)
```
