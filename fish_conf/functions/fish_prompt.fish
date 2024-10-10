# This overrides a builtin
function fish_prompt -d "Write out the prompt"
  printf '%s%s∘ %s%s@%s' (set_color 777) (date +"%d %a %H:%M") (set_color $fish_color_host) (whoami) (hostname|cut -d . -f 1)
  if test -n WINDOW -a "$WINDOW" != ''
    printf '%s(%s)' (set_color white) (echo $WINDOW)
  end
  printf '%s> ' (set_color normal)
end
