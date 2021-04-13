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
  if [ -d ./.git ]; then
    echo "Deleting worktree $WORKTREE_DIR/$1"
    if [ -d "$WORKTREE_DIR/$1" ]; then
        echo "Removing directory $WORKTREE_DIR/$1"
        rm -rf "$WORKTREE_DIR/$1";
    fi
    git worktree prune;
    echo 'Do you want to delete the branch too? (y/n)'
    read -r delete_branch
    if [[ "$delete_branch" == "y" ]]; then
        echo "Deleting branch $1"
        git branch -D "$1";
    else
        echo "Branch not deleted, you can delete later with git branch -D $1";
    fi
  fi;
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

autoload bashcompinit
bashcompinit
complete -F _git_worktree_completions worktree
complete -F _git_worktree_completions del_worktree

