# Print working directory but abbreviates the home dir as ~
export def exec-async [commands: string] {
    bash -c $"nu -c '($commands)' &"
}

export def app [] {
  let name = (ls /Applications/*.app | get name | path basename | fzf-cmd)
  ^open $"/Applications/($name)"
}

export def mdbat [arg] {
   mdcat $arg | bat
}

export def skmare [] {
   sk -m --ansi --regex --preview="bat {} --color=always"
}

export def psk [] {
   /usr/bin/ps aux | skmare 
}

export def netstatsk [] {
   netstat -tulnp | skmare  
}

export def ast-bat [keyword, lang] {
   ast-grep -p $keyword -l $lang | bat -l $lang
}

export def astgrep [keyword, lang] {
   ast-grep -p $keyword -l $lang
}

export def sk-vim [keyword] {
  /usr/bin/vim (fd $keyword | skmare )
}

export def sk-helix [keyword] {
  helix (fd $keyword | skmare )
}

export def sk-grep [] {
  sk -i -c 'rg --color=always --line-number "{}"' --ansi
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

def tee [] {
    let out = $in
    print $out
    $out
}

export def time-now [] {
  let time = (date format '%s %f' | split column ' ' sec ns | first)
  (($time | get sec | into int) * 1sec) + (($time | get ns | into int) * 1ns)
}


def h [arg] {
  history | rg $arg
}

def p [arg] {
  ps | rg $arg
}

def hu [arg] {
   h $"($arg)" | get command | uniq -u
}

def cargo-example [arg: string] {
  cargo run --example $arg 
}

def cargo-test-nocapture [package:string, lib: string = ""] {
  cargo test --package $package --lib -- $lib --nocapture --show-output
}

