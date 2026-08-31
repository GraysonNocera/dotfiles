# Dotfiles

All my dotfiles and configuration and stuff like that.

## Layout

Flat repo — every config lives at the top level and is symlinked to its real
home by the `install` script:

| Repo file    | Symlinked to    |
| ------------ | --------------- |
| `zshrc`      | `~/.zshrc`      |
| `bashrc`     | `~/.bashrc`     |
| `tmux.conf`  | `~/.tmux.conf`  |
| `ideavimrc`  | `~/.ideavimrc`  |
| `ssh_rc`     | `~/.ssh/rc`     |

To add a new dotfile: drop it at the repo root and add one line to the `LINKS`
array in `install`.

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

## Extra tooling

Handy install commands for a fresh machine.

### macOS

```bash
brew install nvim
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
```
