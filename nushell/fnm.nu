# load env variables
fnm env --json | from json | load-env

# add dynamic fnm path
let-env PATH = ($env.PATH | split row (char esep) | prepend ([$env.FNM_MULTISHELL_PATH "bin"] | path join))

# add fnm with cd
def-env fnmcd [path?: string] {
  if ($path == null) {
    cd
  } else {
    cd ($path | path expand)
  }
  if (['.node-version' '.nvmrc'] | any {|it| $env.PWD | path join $it | path exists}) {
     fnm use --silent-if-unchanged
  }
}

alias cd = fnmcd
