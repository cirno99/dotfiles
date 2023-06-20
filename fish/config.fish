if string match -q "st-*" "$TERM"
    set -e VTE_VERSION
end

if status is-interactive
    # Commands to run in interactive sessions can go here
end

set -U fish_greeting ""
set -x TERM xterm
set -x _JAVA_AWT_WM_NONREPARENTING 1
set -x G_MIRROR https://golang.google.cn/dl/
set -x GOROOT /home/cirno99/.g/go
#set -x PATH /home/cirno99/bin $PATH
#set -x PATH /home/cirno99/go/bin $PATH
#set -x PATH /home/cirno99/.yarn/bin $PATH
#set -x PATH /home/cirno99/.npm/bin $PATH
set -Ua fish_user_paths ~/.local/bin ~/.yarn/bin ~/.npm/bin ~/go/bin ~/.g/go/bin ~/bin ~/.cargo/bin
export CPATH="$(clang -v 2>&1 | grep "Selected GCC installation" | rev | cut -d' ' -f1 | rev)/include"

function tere
    set --local result (/usr/bin/tere $argv)
    [ -n "$result" ] && cd -- "$result"
end

alias exaa "exa -ahbHl --no-user"
alias cat "bat"
alias vim "helix"
#alias zld "zellij a || zellij --layout ~/.config/zellij/layouts.yaml"
# Replace ls with exa
alias ls="exa --icons"
alias la='exa -a --icons'
alias ll='exa -la --icons'
alias du='diskus -v'
alias gu='git status'
alias ga='git add -A'
alias gc='git clone'
alias gp='git pull'
alias gck='git checkout'
starship init fish | source
zoxide init fish | source
