export def remotes [] {
	git remote | lines
}

export def branches [] {
	git branch | lines | str trim | each {
		if ($in | str starts-with '* ') {
			{ cur: ' * ', name: ($in | str substring '2,') }
		} else {
			{ cur: '', name: $in }
		}
	}
}

export def remote-branches [remote: string] {
	git branch -a | lines | str trim | each {
		{ name: $in } 
	} | where name =~ $remote
}
export def switch [index: int] {
	git switch ($in.name | select $index)
}

export def add [] {
	let not_staged = ($in | where stage != 'staged')
	$not_staged | where changes == 'deleted' | each { git rm $in.file }
	$not_staged | where changes != 'deleted' | each { git add $in.file }
}

export def pr [] {
	git push --set-upstream (current_remote) (branches | where cur == ' * ').0.name
}

def current_remote [] {
	let from_env = (env | where name == 'nugit_remote')
	if ($from_env | length) == 1 {
		$from_env.0.value
	} else {
		let rem = remotes
		if 'origin' in $rem {
			'origin'
		} else {
			if ($rem | length) == 1 { $rem.0 } else { 'error' }
		}
	}
}

export def git-rebase-interactive [arg] {
  let commit = if ($arg | describe) == int {
    $"HEAD~($arg)"
  } else {
    $arg
  }
  git rebase --interactive $commit
}

export def git-show [commitId] {
  git difftool $"($commitId)~1" $commitId
}

export def git-logn [arg] {
  git log -n $arg --oneline
}

export def git-logn-pretty [arg] {
  git log --pretty=%h»¦«%aN»¦«%s»¦«%aD | lines | split column "»¦«" sha1 committer desc merged_at | first $arg
}

export def git-diff-log [] {
  DFT_BYTE_LIMIT=20000 git log --oneline -p --ext-diff
}

export def git-diff-logn [arg] {
  DFT_BYTE_LIMIT=20000 git log -n $arg --oneline -p --ext-diff
}

export def git-diff-logn-r [arg] {
  DFT_BYTE_LIMIT=20000 git log -n $arg --oneline -p --ext-diff --reverse
}

export def git-diff-logn-author [num, author] {
  DFT_BYTE_LIMIT=20000 git log -n $num --author $author --oneline -p --ext-diff
}

export def git-diff-logn-author-r [num, author] {
  DFT_BYTE_LIMIT=20000 git log -n $num --author $author --oneline -p --ext-diff --reverse
}

export def git-reset [arg, --hard] {
  let commit = if ($arg | describe) == int {
    $"HEAD~($arg)"
  } else {
    $arg
  }
  if $hard {
    git reset --hard $commit
  } else {
    git reset $commit
  }
}


