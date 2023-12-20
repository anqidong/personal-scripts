1. Clone this repository into `~/git/personal-scripts`.
2. Add these importation statements into the following files:

## ~/.profile, ~/.zprofile
```
source ~/git/personal-scripts/dotfiles/.profile
```

## ~/.bashrc
```
set -U fish_color_host 871394
```

## ~/.vimrc
```
source ~/git/personal-scripts/dotfiles/.vimrc
```

## ~/.config/fish/config.fish
```
source ~/git/personal-scripts/fish_conf/config.fish
```

3. If desired, run `set -U fish_color_host <rgb_color>` in fish shell.
