function fish_user_key_bindings
  # Execute this once per mode that emacs bindings should be used in
  fish_default_key_bindings -M insert

  # Then execute the vi-bindings so they take precedence when there's a conflict.
  # The argument specifies the initial mode (insert, "default" or visual).
  fish_vi_key_bindings --no-erase insert

  # Use old behaviour for Ctrl-C that retains what was typed
  # https://github.com/fish-shell/fish-shell/issues/10935#issuecomment-2809853239
  for mode in (bind --list-modes)
    bind -M $mode ctrl-c cancel-commandline
  end
end
