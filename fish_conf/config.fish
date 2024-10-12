if test -z $_PERSONAL_PROFILE_ACTIVE; and status is-interactive
  echo "Warning: .profile was not activated"
end

### install plugins via fundle, if possible
if functions -q fundle
  fundle plugin 'edc/bass'

  fundle init
else if status is-interactive
  echo "Skipping fundle packages"
end

### tell fish about extra folders of stuff
if test -d "$HOME/.local/bin"
  fish_add_path -g --path "$HOME/.local/bin"
end

if test -d "$HOME/git/personal-scripts/bin"
  fish_add_path -g "$HOME/git/personal-scripts/bin"
end

if test -d "$HOME/bin"
  fish_add_path -g "$HOME/bin"
end

begin
  set -l _fish_func_dir (status dirname)"/functions"
  if test -d $_fish_func_dir
    set -g fish_function_path \
      $fish_function_path[1] $_fish_func_dir $fish_function_path[2..]
  end

  set -l _fish_abbrs_file (status dirname)"/abbrs.fish"
  if test -f $_fish_abbrs_file
    source $_fish_abbrs_file
  end
end

if test -d "$HOME/git/work-scripts/bin"
  fish_add_path -g "$HOME/git/work-scripts/bin"
end

begin
  set -l _ws $HOME"/git/work-scripts/fish"

  set -l _fish_func_dir $_ws"/functions"
  if test -d $_fish_func_dir
    set -g fish_function_path \
      $fish_function_path[1] $_fish_func_dir $fish_function_path[2..]
  end

  set -l _fish_abbrs_file $_ws"/abbrs.fish"
  if test -f $_fish_abbrs_file
    source $_fish_abbrs_file
  end
end

### set up event listener functions
function _cd_trigger_helper --on-variable PWD # --on-event fish_prompt
  _maybe_new_pwd
end

_maybe_new_pwd  # make sure we also run this during shell init

### set up fish environment
set -g fish_color_cwd ff4175

if test $fish_color_host = "normal"
  set -g fish_color_host 0a6
end

# some extra aliases
alias ls='ls --color=auto'

alias grep='grep --color=auto'
alias rgrep='rgrep --color=auto'

alias dog='cat'
