function logless -d "autocolor pipe `log show` into less"
  log show --color=always $argv | less -R
end

