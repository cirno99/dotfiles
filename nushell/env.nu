# Nushell Environment Config File

def create_left_prompt [] {
    let path_segment = if (is-admin) {
        $"(ansi red_bold)($env.PWD)"
    } else {
        $"(ansi green_bold)($env.PWD)"
    }

    $path_segment
}

def create_right_prompt [] {
    let time_segment = ([
        (date now | format date '%m/%d/%Y %r')
    ] | str join)

    $time_segment
}

# Use nushell functions to define your right and left prompt
$env.PROMPT_COMMAND = { || create_left_prompt }
$env.PROMPT_COMMAND_RIGHT = { || create_right_prompt }

# The prompt indicators are environmental variables that represent
# the state of the prompt
$env.PROMPT_INDICATOR = { || "〉" }
$env.PROMPT_INDICATOR_VI_INSERT = { || ": " }
$env.PROMPT_INDICATOR_VI_NORMAL = { || "〉" }
$env.PROMPT_MULTILINE_INDICATOR = { || "::: " }
# Specifies how environment variables are:
# - converted from a string to a value on Nushell startup (from_string)
# - converted from a value back to a string when running external commands (to_string)
# Note: The conversions happen *after* config.nu is loaded
$env.ENV_CONVERSIONS = {
  "PATH": {
    from_string: { |s| $s | split row (char esep) | path expand -n }
    to_string: { |v| $v | path expand -n | str join (char esep) }
  }
  "Path": {
    from_string: { |s| $s | split row (char esep) | path expand -n }
    to_string: { |v| $v | path expand -n | str join (char esep) }
  }
}

# Directories to search for scripts when calling source or use
#
# By default, <nushell-config-dir>/scripts is added
$env.NU_LIB_DIRS = [
    ($nu.config-path | path dirname | path join 'scripts')
]

# Directories to search for plugin binaries when calling register
#
# By default, <nushell-config-dir>/plugins is added
$env.NU_PLUGIN_DIRS = [
    ($nu.config-path | path dirname | path join 'plugins')
]

# To add entries to PATH (on Windows you might use Path), you can use the following pattern:
# $env.PATH = ($env.PATH | split row (char esep) | prepend '/some/path')


$env.GOPATH = (echo [$env.HOME go] | path join)
$env.GOROOT = (echo [$env.HOME .g/go] | path join)
$env.PATH = (
    echo $env.PATH |
    append '/usr/local/bin' |
    append '/usr/local/bin/php' |
    append '/usr/local/go/bin' |
    append '/home/cirno99/.yarn/bin' |
    append '/home/cirno99/.npm/bin' |
    append '/home/cirno99/go/bin' |
    append '/home/cirno99/.local/bin' |
    append '/home/cirno99/bin' |
    append '/home/cirno99/.cargo/bin' |
    append '/home/cirno99/kit/x86_64-linux-musl-cross/bin' |
    append (echo [$env.HOME '.composer/vendor/bin'] | path join) | 
    # append (echo [$env.GOROOT 'bin'] | path join) | 
    append (echo [$env.GOPATH 'bin'] | path join)
)

if not (which fnm | is-empty) {
  ^fnm env --json | from json | load-env
  $env.PATH = ($env.PATH | prepend [
    $"($env.FNM_MULTISHELL_PATH)/bin"
  ])
}



$env.TERM = 'xterm'
# $env.TERM = 'foot'
# $env.RUSTUP_UPDATE_ROOT = 'https://mirrors.tuna.tsinghua.edu.cn/rustup/rustup'
# $env.RUSTUP_DIST_SERVER = 'https://mirrors.tuna.tsinghua.edu.cn/rustup'
# To add entries to PATH (on Windows you might use Path), you can use the following pattern:
# $env.PATH = ($env.PATH | split row (char esep) | prepend '/some/path')

starship init nu | save --force ~/.starship1.nu
zoxide init nushell | str replace "$env.PWD -- $rest" "$env.PWD -- ...$rest" --all | save -f ~/.zoxide1.nu 
# generate cmd to batch alias
# ["wc","chown", "chmod", "date", "mv", "cp", "head", "tail", "rm", "pwd", "more", "mkdir", "du", "df", "kill", "sleep", "touch", "uname"] | each {|command_name| $"alias ($command_name) = uu-($command_name)" } | str join "\n" | save --force ~/.config/nushell/uutils-alias.nu
