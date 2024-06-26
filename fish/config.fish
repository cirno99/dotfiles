if string match -q "st-*" "$TERM"
    set -e VTE_VERSION
end

if status is-interactive
    # Commands to run in interactive sessions can go here
end

fish_add_path ~/.local/share/mise/shims

set -U fish_greeting ""
set -x TERM xterm
set -x _JAVA_AWT_WM_NONREPARENTING 1

set -x CHROME_EXECUTABLE /usr/bin/google-chrome-unstable
set -x ANDROID_HOME /home/cirno99/Android/Sdk
set -x ANDROID_NDK /home/cirno99/Android/Sdk/ndk/26.1.10909125
set -x ANDROID_NDK_HOME /home/cirno99/Android/Sdk/ndk/26.1.10909125
set -x NDK_HOME /home/cirno99/Android/Sdk/ndk/26.1.10909125
# set -x ANDROID_NDK_HOME /home/cirno99/Android/Sdk/ndk/23.1.7779620
# set -x NDK_HOME /home/cirno99/Android/Sdk/ndk/23.1.7779620
set -x REPO_OS_OVERRIDE linux

set -x QUICKJS_WASM_SYS_WASI_SDK_PATH /opt/wasi-sdk
set -x DOCKER_HOST unix:///run/user/1000/podman/podman.sock

set -x G_MIRROR https://golang.google.cn/dl/

# go
set -gx GOBIN "$HOME/go/bin"
set -gx PATH "$GOBIN" $PATH
set -gx GOPATH $HOME/go
set -gx GOROOT $HOME/.local/share/mise/installs/go/1.22.4/
# g-install: do NOT edit, see https://github.com/stefanmaric/g

# pnpm
set -gx PNPM_HOME "/home/cirno99/.local/share/pnpm"
if not string match -q -- $PNPM_HOME $PATH
    set -gx PATH "$PNPM_HOME" $PATH
end
# pnpm end

set -Ua fish_user_paths ~/.local/bin ~/.yarn/bin ~/.npm/bin ~/bin ~/.cargo/bin /opt/flutter/bin /opt/dart-sdk/bin $ANDROID_HOME/tools $ANDROID_HOME/tools/bin $ANDROID_HOME/platform-tools ~/.local/share/pnpm /usr/lib/jvm/default
export CPATH="$(clang -v 2>&1 | grep "Selected GCC installation" | rev | cut -d' ' -f1 | rev)/include"
export GTK_CSD=0
export LD_PRELOAD=/usr/lib/libgtk3-nocsd.so.0

function tere
    set --local result (/usr/bin/tere $argv)
    [ -n "$result" ] && cd -- "$result"
end

# --- uutils 
alias wc uu-wc
alias chown uu-chown
alias chmod uu-chmod
alias date uu-date
alias mv uu-mv
alias cp uu-cp
alias head uu-head
alias tail uu-tail
alias rm uu-rm
alias pwd uu-pwd
alias more uu-more
alias mkdir uu-mkdir
alias kill uu-kill
alias sleep uu-sleep
alias touch uu-touch
alias uname uu-uname

alias psthread='ps -T -p'

alias df "dysk -a -s filesystem"
alias gitui "gitui -t macchiato.ron"
alias mold-cargo-build "mold -run cargo build"
alias docker podman
alias docker-compose podman-compose

alias http-proxy "export https_proxy=http://127.0.0.1:7890 http_proxy=http://127.0.0.1:7890 all_proxy=socks://127.0.0.1:7890"

alias exaa "exa -ahbHl --no-user"
alias cat "bat --style plain"
alias vim helix
# alias hx "helix"
alias helix hx
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

alias get_idf='. $HOME/.espressif/esp-idf/v5.1.2/export.fish'

starship init fish | source
zoxide init fish | source
mise activate fish | source

# set -x RUSTUP_UPDATE_ROOT https://mirrors.tuna.tsinghua.edu.cn/rustup/rustup
# set -x RUSTUP_DIST_SERVER https://mirrors.tuna.tsinghua.edu.cn/rustup
