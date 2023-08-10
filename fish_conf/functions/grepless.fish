function grepless -d "autocolor pipe grep into less"
  grep --color=always $argv | less -R
end

