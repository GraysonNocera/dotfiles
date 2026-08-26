echo "hello from your .zshrc :)"

export VISUAL=nvim
export EDITOR="$VISUAL"

# dotnet macOS dumbness
export DYLD_FRAMEWORK_PATH=/System/Library/Frameworks

export PATH=$PATH:/opt/homebrew
export PATH=$PATH:$HOME/Library/Python/3.9/bin
export PATH=$PATH:$HOME/.dotnet/tools

export CPATH=/opt/homebrew/include
export LIBRARY_PATH=/opt/homebrew/lib

export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin

# android
export ANDROID_HOME=$HOME/Library/Android/sdk/
export CMDLINE_TOOLS=$ANDROID_HOME/cmdline-tools/latest/bin/
export PLATFORM_TOOLS=$ANDROID_HOME/platform-tools/
export PATH=$PATH:$CMDLINE_TOOLS
export PATH=$PATH:$PLATFORM_TOOLS

if [[ "$(uname)" == "Darwin" ]]; then
  export SECURITYSESSIONID=$(security login-keychain | tr -d '"')
fi

if [ -z "$SSH_AUTH_SOCK" ] || [ ! -S "$SSH_AUTH_SOCK" ]; then
  export SSH_AUTH_SOCK=$(ls -t /tmp/ssh-*/agent.* 2>/dev/null | head -n1)
fi

autoload -Uz compinit && compinit

# Force the terminal back onto the main screen before every prompt. If a
# program (fzf widget, pager, crashed TUI) exits without leaving the alternate
# screen, the shell gets stuck in the alt buffer -- which has NO scrollback, so
# command output can't be scrolled back to. This guarantees we're always on the
# scrollback-backed main screen whenever a prompt is drawn.
autoload -Uz add-zsh-hook
_leave_alt_screen() {
  # Only act when tmux reports THIS pane is actually stuck in the alt buffer.
  # Emitting the escape unconditionally would trigger a cursor/screen restore
  # on every prompt and wipe normal output, so guard on #{alternate_on}.
  [[ -n "$TMUX" ]] || return
  [[ "$(tmux display -p '#{alternate_on}' 2>/dev/null)" == 1 ]] && printf '\033[?1049l'
}
add-zsh-hook precmd _leave_alt_screen

setopt PROMPT_SUBST

# Function to get current git branch
parse_git_branch() {
  git rev-parse --abbrev-ref HEAD 2>/dev/null
}

HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history

# Colors
ED="%{%F{red}%}"
GREEN="%{%F{green}%}"
BLUE="%{%F{blue}%}"
YELLOW="%{%F{yellow}%}"
RESET="%{%f%}"

# Prompt:
# %n = username
# %m = host (short)
# %~ = current working directory (relative to home)
# $(parse_git_branch) = current git branch (if available)
PROMPT="${GREEN}%n@%m ${BLUE}%~${YELLOW}\$(if git rev-parse --is-inside-work-tree &>/dev/null; then echo \" (\$(parse_git_branch))\"; fi)${RESET}
$ "

export PATH="$HOME/.local/bin:$PATH"
