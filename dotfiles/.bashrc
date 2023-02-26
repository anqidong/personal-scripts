# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

if [ -z $NO_AUTO_FISH ]; then
  WHICH_FISH=`which fish`
  if echo $- | grep -q 'i' && \
      [[ -x $WHICH_FISH ]] && ! [[ $SHELL -ef $WHICH_FISH ]]; then
    export SHELL=$WHICH_FISH
    exec $WHICH_FISH -i
  fi
fi

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|xterm-256color) color_prompt=yes;;
esac

_color_str() {
  echo "\[\e[38;5;$1m\]"
}

_color_white="\[\e[00m\]"

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
  if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
      # We have color support; assume it's compliant with Ecma-48
      # (ISO/IEC-6429). (Lack of such support is extremely rare, and such
      # a case would tend to support setf rather than setaf.)
      color_prompt=yes
  else
      color_prompt=
  fi
fi

set_bash_prompt() {
  if [ $SHLVL -ge 2 ]; then
    subshell_str='⑂'
  else
    subshell_str=' '
  fi

  if [[ "$VIRTUAL_ENV" != "" ]]; then
    virtualenv_str=" ($(basename "$VIRTUAL_ENV"))"
  else
    virtualenv_str=$(python3 -c 'import sys; sys.stdout.write(" <virtualenv>" if hasattr(sys, "real_prefix") else "")')
  fi

  if [ "$color_prompt" = yes ]; then
      PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w'
      PS1+=$(_color_str 54)
      PS1+=$virtualenv_str
      PS1+="${_color_white}\n${subshell_str}> "
      # PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\n'
  else
      PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\n${subshell_str}> '
  fi

  # If this is an xterm set the title to user@host:dir
  case "$TERM" in
  xterm*|rxvt*)
      PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
      ;;
  *)
      ;;
  esac
}



# PROMPT_COMMAND=set_bash_prompt  ## (this is the wrong way to use PROMPT_COMMAND)
set_bash_prompt
unset color_prompt force_color_prompt

# set fancy title
# trap 'echo -ne "\033]0;\w\$: $BASH_COMMAND\007"' DEBUG

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

if [ -f ~/git/work-scripts/dotfiles/bash_aliases.sh ]; then
    . ~/git/work-scripts/dotfiles/bash_aliases.sh
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

################ user added

alias dog='cat'

# makes git SSH keys work better
# command gnome-keyring-daemon --start

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert_notify='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

run_and_notify() {
  eval "$*"

  set +m
  if [$# -gt 3]; then
    zenity --notification --text "Finished running $1 $2 $3 (truncated…)" >/dev/null 2>/dev/null & disown;
  else
    zenity --notification --text "Finished running $@" >/dev/null 2>/dev/null & disown;
  fi
  set -m
}
