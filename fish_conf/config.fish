if test -z $_PERSONAL_PROFILE_ACTIVE; and status --is-interactive
  echo "Warning: .profile was not activated"
end

### install plugins via fundle, if possible
if functions -q fundle
  fundle plugin 'edc/bass'

  fundle init
else
  echo "Skipping fundle packages"
end

### tell fish about extra folders of stuff
if test -d "$HOME/bin"
  fish_add_path -g --path "$HOME/bin"
end

if test -d "$HOME/.local/bin"
  fish_add_path -g --path "$HOME/.local/bin"
end

if test -d "$HOME/git/personal-scripts/bin"
  fish_add_path -g --path "$HOME/git/personal-scripts/bin"
end

begin
  set -l _fish_func_dir (path dirname (status -f))"/functions"
  if test -d $_fish_func_dir
    set -g -p fish_function_path $_fish_func_dir
  end

  set -l _fish_abbrs_file (path dirname (status -f))"/abbrs.fish"
  if test -f $_fish_abbrs_file
    source $_fish_abbrs_file
  end
end

if test -d "$HOME/git/work-scripts/bin"
  fish_add_path -g --path "$HOME/git/work-scripts/bin"
end

begin
  set -l _ws $HOME"/git/work-scripts/fish"

  set -l _fish_func_dir $_ws"/functions"
  if test -d $_fish_func_dir
    set -g -p fish_function_path $_fish_func_dir
  end

  set -l _fish_abbrs_file $_ws"/abbrs.fish"
  if test -f $_fish_abbrs_file
    source $_fish_abbrs_file
  end
end

### set up fish environment
set -g fish_color_cwd ff4175

if test $fish_color_host = "normal"
  set -g fish_color_host 0a6
end

function _prettified_path -d "Gets a prettified version of the current `pwd`"                       
  echo -n (pwd | sed -e "s|^$HOME|~|")                     
end                                                                                                 
                                                                                                    
function fish_title -d "Title for the terminal"                                                     
  echo $_ " "                                                  
  _prettified_path                                                                                  
end 

function fish_prompt -d "Write out the prompt"
  printf '%s%s∘ %s%s@%s' (set_color 777) (date +"%d %a %H:%M") (set_color $fish_color_host) (whoami) (hostname|cut -d . -f 1)
  if test -n WINDOW -a "$WINDOW" != ''                                                              
    printf '%s(%s)' (set_color white) (echo $WINDOW)                                                
  end                                                                                               
  printf '%s> ' (set_color normal)   
end

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

# some silly extra aliases
alias ls='ls --color=auto'

alias grep='grep --color=auto'
alias rgrep='rgrep --color=auto'

alias dog='cat'
