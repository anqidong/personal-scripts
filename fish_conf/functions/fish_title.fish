# This overrides a builtin
function fish_title -d "Title for the terminal"
  echo $_ " "
  _prettified_path
end