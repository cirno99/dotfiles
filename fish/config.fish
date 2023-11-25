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
set -x GOROOT /home/cirno99/.g/go/
set -x DOCKER_HOST unix:///run/user/1000/podman/podman.sock
#set -x PATH /home/cirno99/bin $PATH
#set -x PATH /home/cirno99/go/bin $PATH
#set -x PATH /home/cirno99/.yarn/bin $PATH
#set -x PATH /home/cirno99/.npm/bin $PATH
set -Ua fish_user_paths ~/.local/bin ~/.yarn/bin ~/.npm/bin ~/go/bin ~/bin ~/.cargo/bin
export CPATH="$(clang -v 2>&1 | grep "Selected GCC installation" | rev | cut -d' ' -f1 | rev)/include"

function tere
    set --local result (/usr/bin/tere $argv)
    [ -n "$result" ] && cd -- "$result"
end


# --- uutils 
alias wc "uu-wc"
alias chown "uu-chown"
alias chmod "uu-chmod"
alias date "uu-date"
alias mv "uu-mv"
alias cp "uu-cp"
alias head "uu-head"
alias tail "uu-tail"
alias rm "uu-rm"
alias pwd "uu-pwd"
alias more "uu-more"
alias mkdir "uu-mkdir"
alias kill "uu-kill"
alias sleep "uu-sleep"
alias touch "uu-touch"
alias uname "uu-uname"


alias df  "dysk -a -s filesystem"
alias gitui  "gitui -t macchiato.ron"
alias mold-cargo-build  "mold -run cargo build"
alias docker "podman"
alias docker-compose "podman-compose"


alias exaa "exa -ahbHl --no-user"
alias cat "bat --style plain"
alias vim "helix"
# alias hx "helix"
alias helix "hx"
#alias zld "zellij a || zellij --layout ~/.config/zellij/layouts.yaml"
# Replace ls with exa
alias ls="exa --icons"
alias la='exa -a --icons'
alias ll='exa -la --icons'
# alias du='diskus -v'
alias du='dust'
alias gu='git status'
alias ga='git add -A'
alias gc='git clone'
alias gp='git pull'
alias gck='git checkout'
starship init fish | source
zoxide init fish | source


# set -x RUSTUP_UPDATE_ROOT https://mirrors.tuna.tsinghua.edu.cn/rustup/rustup
# set -x RUSTUP_DIST_SERVER https://mirrors.tuna.tsinghua.edu.cn/rustup

set -gx GOPATH $HOME/go; set -gx GOROOT $HOME/.g/go; set -gx PATH $GOPATH/bin $PATH; # g-install: do NOT edit, see https://github.com/stefanmaric/g
