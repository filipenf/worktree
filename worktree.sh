WORKTREE_DIR="${HOME}/.worktrees"

function worktree() {
    ## create or switch to a worktree
    WTDIR="${WORKTREE_DIR}/$1"
    branch=$(git branch -a | grep -Eo -m 1 "$1$")
    if [ $? -eq 0 ]; then
        git worktree list |grep -m 1 "\[$1\]$" || \
          git worktree add "$WTDIR" "$branch" ;
    else
        echo "Creating new worktree $WTDIR from existing branch $branch"
        git worktree add -b "$1" "$WTDIR" origin/HEAD
    fi
    worktree_switch "$1"
}

function del_worktree() {
  if [[ -z "$1" ]]; then
    echo "Please specify the worktree name";
    return;
  fi
  if [[ ! -d ./.git ]]; then
    echo "Need to be in a git repository";
    return
  fi;

  for wt in $@; do
    echo "Deleting worktree $WORKTREE_DIR/${wt}"
    if [ -d "$WORKTREE_DIR/${wt}" ]; then
        echo "Deleting directory directory $WORKTREE_DIR/${wt}"
        rm -rf "$WORKTREE_DIR/${wt}";
    fi
    echo "Deleting branch ${wt}"
    git worktree prune;
    git branch -D "${wt}";
  done;
}

function worktree_switch() {
    wt=$(git worktree list |grep -m 1 "\[$1\]$")
    if [ $? -eq 0 ]; then
        wtdir=$(echo $wt |awk '{ print $1 }')
        echo "Switching to $wtdir"
        cd "$wtdir"
    else
        return 1
    fi
}

_git_worktree_completions()
{
  if [ "${#COMP_WORDS[@]}" != "2" ]; then
    return
  fi

  # keep the suggestions in a local variable
  local suggestions=($(compgen -W "$(git branch --sort=committerdate)" -- "${COMP_WORDS[1]}"))

  if [ "${#suggestions[@]}" == "1" ]; then
    # if there's only one match, we remove the command literal
    # to proceed with the automatic completion of the worktree name

    local exact_match=$(echo ${suggestions[0]/%\ */})
    COMPREPLY=("$exact_match")
  else
    # more than one suggestions resolved,
    # respond with the suggestions intact
    COMPREPLY=("${suggestions[@]}")
  fi
}

_git_del_worktree_completions() {
  # keep the suggestions in a local variable
  local suggestions=($(compgen -W "$(git worktree list | awk '{gsub(/\[|\]/, "", $3); print $3 }')" -- "${COMP_WORDS[1]}"))

  COMPREPLY=("${suggestions[@]}")
}



autoload bashcompinit
bashcompinit
complete -F _git_worktree_completions worktree
complete -F _git_del_worktree_completions del_worktree

