# This is a variant on the builtin prompt_pwd function
function _prettified_path -d "Gets a prettified version of the current `pwd`"
  # echo -n (pwd | sed -e "s|^$HOME|~|")
  prompt_pwd -d 3 -D 5
end
