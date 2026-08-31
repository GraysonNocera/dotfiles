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

# Completion tweaks: case-insensitive matching, an arrow-key menu, and
# colorized matches.
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' menu select
zstyle ':completion:*' list-colors ''

# Arrow keys search history by the prefix already typed (e.g. type "git "
# then press Up to cycle only past commands starting with "git ").
autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey '^[[A' up-line-or-beginning-search
bindkey '^[[B' down-line-or-beginning-search

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

# Git segment for the prompt: prints " <glyph> <branch>" inside a repo, nothing
# otherwise. `glyph` holds the Nerd Font branch symbol (U+E0A0). To use a
# different icon, paste another Nerd Font glyph between the quotes (e.g. the
# code-branch U+F126 or git-branch U+E725) -- a literal glyph is more portable
# here than a \u escape, which errors under a non-UTF-8 locale.
git_prompt() {
  local branch
  branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null) || return
  local glyph=''
  echo " ${glyph} ${branch}"
}

HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history

# History behavior.
setopt SHARE_HISTORY        # instant history sharing across open terminals
setopt HIST_IGNORE_ALL_DUPS # drop older duplicates of a repeated command
setopt HIST_IGNORE_SPACE    # don't record commands that start with a space
setopt HIST_REDUCE_BLANKS   # tidy up superfluous whitespace
setopt EXTENDED_HISTORY     # record command start time

# Directory navigation.
setopt AUTO_CD              # `dotfiles` on its own means `cd dotfiles`
setopt AUTO_PUSHD          # every cd pushes onto the directory stack
setopt PUSHD_IGNORE_DUPS   # keep the stack free of duplicates

# Vi editing mode indicator. zsh uses the vi keymap because $VISUAL/$EDITOR
# contains "vi" (nvim), so the command line has NORMAL/INSERT modes. Show which.
export KEYTIMEOUT=1   # 10ms: switch to NORMAL mode almost instantly after ESC

vi_mode_prompt() {
  case $KEYMAP in
    vicmd) echo '%K{yellow}%F{black} CMD %f%k';;  # NORMAL (command) mode
    *)     echo '%K{green}%F{black} INS %f%k';;   # INSERT mode
  esac
}
# Redraw the prompt whenever the keymap changes or a new line starts, so the
# indicator stays current.
zle-keymap-select() { zle reset-prompt }
zle-line-init()     { zle reset-prompt }
zle -N zle-keymap-select
zle -N zle-line-init

# Prompt: two lines.
#   line 1: cwd (cyan) + git branch (yellow) + vi-mode tag, keeping line 2 clear
#   line 2: just an arrow, green after success / red after a failed command
# %~            = cwd relative to home
# $(git_prompt) = " <glyph> <branch>" when in a repo (see git_prompt above)
# $(vi_mode_prompt) = INS / CMD pill reflecting the current vi keymap
# %(?.A.B)      = A if last exit status was 0, else B
PROMPT='%F{cyan}%~%f%F{yellow}$(git_prompt)%f $(vi_mode_prompt)
%(?.%F{green}.%F{red})❯%f '

# eza: a modern ls replacement. Falls back to plain ls if eza isn't installed.
if command -v eza >/dev/null 2>&1; then
  alias ls='eza --group-directories-first'
  alias ll='eza -l --git --icons --group-directories-first'
  alias tree='eza --tree'
fi

# zoxide: a smarter cd that learns your most-used directories.
# `cd <partial>` jumps to the best match; `cd` with no args still goes home.
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh)"
  alias cd='z'
fi

alias c='clear'

export PATH="$HOME/.local/bin:$PATH"
