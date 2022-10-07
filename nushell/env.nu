# Nushell Environment Config File

let-env GOPATH = (echo [$env.HOME go] | path join)
let-env PATH = (
    echo $env.PATH |
    append '/usr/local/bin' |
    append '/usr/local/bin/php' |
    append '/usr/local/go/bin' |
    append '/home/cirno99/.yarn/bin' |
    append '/home/cirno99/.npm/bin' |
    append '/home/cirno99/go/bin' |
    append '/home/cirno99/.local/bin' |
    append '/home/cirno99/.g/go/bin' |
    append '/home/cirno99/bin' |
    append '/home/cirno99/.cargo/bin' |
    append (echo [$env.HOME '.composer/vendor/bin'] | path join) | 
    # append (echo [$env.GOROOT 'bin'] | path join) | 
    append (echo [$env.GOPATH 'bin'] | path join)
)

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
        (date now | date format '%m/%d/%Y %r')
    ] | str join)

    $time_segment
}

# Use nushell functions to define your right and left prompt
let-env PROMPT_COMMAND = { create_left_prompt }
let-env PROMPT_COMMAND_RIGHT = { create_right_prompt }

# The prompt indicators are environmental variables that represent
# the state of the prompt
let-env PROMPT_INDICATOR = { "〉" }
let-env PROMPT_INDICATOR_VI_INSERT = { ": " }
let-env PROMPT_INDICATOR_VI_NORMAL = { "〉" }
let-env PROMPT_MULTILINE_INDICATOR = { "::: " }

# Specifies how environment variables are:
# - converted from a string to a value on Nushell startup (from_string)
# - converted from a value back to a string when running external commands (to_string)
# Note: The conversions happen *after* config.nu is loaded
let-env ENV_CONVERSIONS = {
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
let-env NU_LIB_DIRS = [
    ($nu.config-path | path dirname | path join 'scripts')
]

# Directories to search for plugin binaries when calling register
#
# By default, <nushell-config-dir>/plugins is added
let-env NU_PLUGIN_DIRS = [
    ($nu.config-path | path dirname | path join 'plugins')
]
let-env CDPATH = [".", $env.HOME, "/", ([$env.HOME, ".config"] | path join)]

let-env TERM = 'xterm'
# To add entries to PATH (on Windows you might use Path), you can use the following pattern:
# let-env PATH = ($env.PATH | split row (char esep) | prepend '/some/path')

mkdir ~/.cache/starship
starship init nu | save ~/.cache/starship/init.nu

mkdir ~/.cache/zoxide
zoxide init nushell | save ~/.cache/zoxide/init.nu
source ~/.cache/starship/init.nu
source ~/.cache/zoxide/init.nu

