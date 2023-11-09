function git-reset-submodules -d "Hard resets all submodules to HEAD"
  if count $argv
    git submodule deinit -f -- $argv[1] && \
      git submodule update --init -- $argv[1]
  else
    git submodule deinit -f . && git submodule update --init
  end
end

