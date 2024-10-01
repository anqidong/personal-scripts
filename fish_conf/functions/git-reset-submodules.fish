function git-reset-submodules -d "Hard resets all submodules to HEAD"
  set -f submodule_path "."

  if count $argv
    set -f submodule_path $argv[1]
    pushd $argv[1]
  end

  git submodule foreach --recursive 'git submodule deinit -f --all' && \
  git submodule deinit -f -- "$submodule_path" && \
  git submodule sync --recursive -- "$submodule_path" && \
  git submodule update --init --recursive -- "$submodule_path"

  if count $argv
    popd
  end
end

