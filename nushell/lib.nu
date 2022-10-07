# Print working directory but abbreviates the home dir as ~
def pwd-short [] {
  $env.PWD | str replace $nu.home-path '~' -s
}

def f [arg] {
  ls **/*($arg)*
}

export def chrome [path: string] {
  ^open -a `/Applications/Google Chrome.app/` $path
}

export def exec-async [commands: string] {
    bash -c $"nu -c '($commands)' &"
}

export def do-async [block: block] {
  # block may call bultins and external commands only
  bash -c $"nu -c 'do (view-source $block)' &"
}

export def fzf-cmd [] {
  str join "\n" | ^fzf --info=hidden | str trim -r
}

export def app [] {
  let name = (ls /Applications/*.app | get name | path basename | fzf-cmd)
  ^open $"/Applications/($name)"
}

export def mdbat [arg] {
   mdcat $arg | bat
}

export def help-find [pattern: string] {
  help --find $pattern
}

# export def kill-all [name: string] {
#   ps | where name == $name | get pid | each { |it| kill -9 $it }
# }

export def pid [] {
  pstree | rg -B 5 $nu.pid
}

def collect-args [] { # List[Tuple2] -> String
  $in | where -b {|flag__arg| $flag__arg.0} | each {|it| $it.1} | str join ' ' 
}

def tee [] {
    let out = $in
    print $out
    $out
}

export def time-now [] {
  let time = (date format '%s %f' | split column ' ' sec ns | first)
  (($time | get sec | into int) * 1sec) + (($time | get ns | into int) * 1ns)
}

export def time [block: block] {
  let t0 = (time-now)
  do $block
  let t1 = (time-now)
  $t1 - $t0
}

export def which-follow [name: string] {
  which -a $name | each {|it| echo $it | path expand -c ['path'] }
}


def h [arg] {
  history | find $arg
}

def p [arg] {
  ps | find $arg
}

def hu [arg] {
   h $"($arg)" | get command | uniq -u
}

def cargo-example [arg: string] {
  cargo run --example $arg 
}

def cargo-test-nocapture [arg : string = ""] {
  cargo test $arg -- --nocapture
}

