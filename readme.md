# Dotfiles

All my dotfiles and configuration and stuff like that.  

Included:
- `.zshrc`
- `.ideavimrc`
- `.tmux.conf`

# Install
1. Clone the repo:
```bash
git clone https://github.com/GraysonNocera/dotfiles.git && cd ./dotfiles
```
2. Install the dotfiles by symlinking them to the appropriate location:
```bash
chmod +x ./install && ./install
```
In the event of a conflict, the script will create a `$file.bak` backup in the same location.

## Installing TMUX
1. Install the package manager:
```bash 
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```


## Random commands run

```
### Mac
brew install nvim

dotnet tool install -g EasyDotnet

brew tap omnisharp/omnisharp-roslyn
brew update

brew tap homebrew/cask-fonts
brew install --cask font-jetbrains-mono-nerd-font
```

### Linux
```
# install nvim
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
sudo rm -rf /opt/nvim-linux-x86_64
sudo tar -C /opt -xzf nvim-linux-x86_64.tar.gz
export PATH="$PATH:/opt/nvim-linux-x86_64/bin"

# install nodejs and npm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.4/install.sh | bash
nvm install node
nvm use node

npm install tree-sitter-cli

# install ripgrep
curl -LO https://github.com/BurntSushi/ripgrep/releases/download/14.1.1/ripgrep_14.1.1-1_amd64.deb
sudo dpkg -i ripgrep_14.1.1-1_amd64.deb

# install lazygit
go install github.com/jesseduffield/lazygit@latest
```
