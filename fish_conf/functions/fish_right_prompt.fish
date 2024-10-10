# This overrides a builtin
function fish_right_prompt -d "Write out the right prompt"
  set -l last_status $status

  # Print a red dot for failed commands.
  if test $last_status -ne 0
    set_color red;    echo -n "⚑"
  end

  # if not gcertstatus -quiet
  #   set_color red;    echo -n '⏏'
  # end

  # Print a fork symbol when in a subshell
  if test $SHLVL -gt 2
    set_color red;    echo -n "⑂"
    # set_color normal; echo -n " "
  else if test $SHLVL -eq 2
    set_color yellow; echo -n "⑂"
  end

  set_color normal; echo -n " "

  # Print the username when the user has been changed.
  if set -q LOGNAME; and test $USER != $LOGNAME
    set_color black; echo -n "$USER@"
    set_color normal
  end

  # Print the current directory.
  set_color $fish_color_cwd; _prettified_path

  # Print the checked out branch name or commit hash of a git repository.
  set -l is_git_repository (git rev-parse --is-inside-work-tree 2>/dev/null)
  if test -n "$is_git_repository"
    set_color --bold --underline black
    echo -n ":"
    set_color normal

    set -l branch (git symbolic-ref --short HEAD 2>/dev/null;
                   or git rev-parse HEAD 2>/dev/null | cut -b 1-9)

    git diff-files --quiet --ignore-submodules 2>/dev/null; or set -l has_unstaged_files
    git diff-index --quiet --ignore-submodules --cached HEAD 2>/dev/null; or set -l has_staged_files

    if set -q has_unstaged_files
      set_color red
    else if set -q has_staged_files
      set_color 962
    else
      set_color green
    end

    echo -n $branch
  end

  set_color normal
end