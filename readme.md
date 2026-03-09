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
brew install nvim

dotnet tool install -g EasyDotnet

brew tap omnisharp/omnisharp-roslyn
brew update
```
