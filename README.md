# Git Worktree Wrapper

Shell functions to simplify git worktree management.

## Setup

Add this to your shell rc file: 

```bash
source /path/to/worktree.sh
```

Worktrees are stored in `~/.worktrees/` by default.

## Commands

- `wt <branch>` - Switch to an existing worktree or creates one
- `wt_del <branch>...` - Delete worktree(s) and branch(es)
- `wt_done` - Run this inside a worktree dir to switch back to main and cleanup the branch + worktree
- `wt_switch <branch>` - Switch to existing worktree

