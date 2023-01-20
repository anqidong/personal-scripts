# ~/.profile: executed by the command interpreter for login shells.
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login
# exists.
# see /usr/share/doc/bash/examples/startup-files for examples.
# the files are located in the bash-doc package.

# the default umask is set in /etc/profile; for setting the umask
# for ssh logins, install and configure the libpam-umask package.
#umask 022

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
    export PATH="$HOME/bin:$PATH"
fi

if [ -d "$HOME/.local/bin" ] ; then
    export PATH="$HOME/.local/bin:$PATH"
fi

if [ -d "$HOME/git/personal-scripts/bin" ] ; then
    export PATH="$HOME/git/personal-scripts/bin:$PATH"
fi

if [ -d "$HOME/git/work-scripts/bin" ] ; then
    export PATH="$HOME/git/work-scripts/bin:$PATH"
fi

# TODO: Remove this after you re-log-in everywhere and .profile changes are
# picked up???
export _PROFILE_CHANGES_SEEM_TO_BE_SET_=42

export EDITOR=vim

export GTK_IM_MODULE=ibus
export XMODIFIERS=@im=ibus
export QT_IM_MODULE=ibus

export IBUS_ENABLE_SYNC_MODE=1

# For gcc auto-color
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# If running bash:
if [ -n "$BASH_VERSION" ]; then
    # Include .bashrc if it exists. Do this after everything else, because the
    # .bashrc file may eventually exec into fish, and we don't want to lose all
    # of the stuff above, should that happen.
    if [ -f "$HOME/.bashrc" ]; then
        . "$HOME/.bashrc"
    fi
fi