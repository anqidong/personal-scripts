1. Clone this repository into `~/git/personal-scripts`.
2. Add these importation statements into the following files:

### ~/.profile
```
source "$HOME/git/personal-scripts/dotfiles/.profile"
```

If using zsh (e.g. macOS), symlink ~/.zprofile to ~/.profile (avoids having to
maintain two barely-used files).

Make sure rogue scripts don't try to create a ~/.bash\_profile file, since it'd
be a latent maintenance headache.

### ~/.bashrc
```
source ~/git/personal-scripts/dotfiles/.bashrc
```

### ~/.vimrc
```
source ~/git/personal-scripts/dotfiles/.vimrc
```

### ~/.config/fish/config.fish
```
source ~/git/personal-scripts/fish_conf/config.fish
```

### ~/.gitconfig
```
[include]
	path = ~/git/personal-scripts/git_conf/main.gitconfig
```

3. Install vundle for `vim`:
```
> git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
> vim +PluginInstall +qall
```

4. Install fundle for `fish` (optional):
```
> mkdir -p ~/.config/fish/functions

> wget https://git.io/fundle -O ~/.config/fish/functions/fundle.fish
# alternate:
> curl https://git.io/fundle -Lo ~/.config/fish/functions/fundle.fish

> fundle install
```

5. If desired, run `set -U fish_color_host <rgb_color>` in fish shell, to
   customize the prompt colouring.

## Optional tools

### pyenv
Make sure that config.fish uses `--no-rehash`:

```fish
pyenv init --no-rehash - fish | source
```

Otherwise the pyenv-shim lock file can lock up terminal startup. I find it's
generally not worth.

It may also be necessary to add this to .profile so that sh-based environment
readers pick up the path:

```
export PYENV_ROOT="${PYENV_ROOT:-$HOME/.pyenv}"
if [ -d "$PYENV_ROOT/shims" ] ; then
    export PATH="$PYENV_ROOT/shims:$PATH"
fi
```

Put it after the .profile `source` command, so that it's skipped if we end up
exec-ing into fish.
