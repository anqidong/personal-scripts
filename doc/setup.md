1. Clone this repository into `~/git/personal-scripts`.
2. Add these importation statements into the following files:

## ~/.profile, ~/.zprofile (macOS)
```
source "$HOME/git/personal-scripts/dotfiles/.profile"
```

## ~/.bashrc
```
source ~/git/personal-scripts/dotfiles/.bashrc
```

## ~/.vimrc
```
source ~/git/personal-scripts/dotfiles/.vimrc
```

## ~/.config/fish/config.fish
```
source ~/git/personal-scripts/fish_conf/config.fish
```

## ~/.gitconfig
```
[include]
	path = ~/git/personal-scripts/git_conf/main.gitconfig
```

3. Install vundle for vim:
```
> git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
> vim +PluginInstall +qall
```

4. If desired, run `set -U fish_color_host <rgb_color>` in fish shell, to
   customize the prompt colouring.
