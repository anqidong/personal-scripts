# This overrides a builtin
function fish_prompt -d "Write out the prompt"
  # Hack: Dump this to a global variable for fish_right_prompt, whose $status
  # value is bugged and always evaluates to 0?
  set -g _hack_prompt_status $status

  set -l color_time 777
  set -l suffix '>'
  if functions -q fish_is_root_user; and fish_is_root_user
      set color_time b20
      set suffix '#'
  end

  set -l fancy_month \
    (string unescape "\u"(string sub -s 3 (math -b 16 0x245F + (date +"%-m"))))

  echo -ns (set_color $color_time) $fancy_month' ' (date +"%d %a %H:%M") '∘ ' \
    (set_color $fish_color_host) (whoami) '@' (hostname|cut -d . -f 1)

  if test -n WINDOW -a "$WINDOW" != ''
    printf '%s(%s)' (set_color white) (echo $WINDOW)
  end

  echo -ns (set_color normal) $suffix ' '
end
