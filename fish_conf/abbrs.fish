abbr -a ggrei git grep -Fin -C 5
abbr -a ggrep git grep -Fin -C 5
abbr -a --position anywhere grei grep -Fin -C 5

abbr -a ggrew git grep -Finw -C 5
abbr -a --position anywhere grew grep -Finw -C 5

# Helpers for `git grep` on projects with Xcode stuff
abbr -a --position anywhere -- xxc -- \
  "':!*.pbxproj'" "':!*.plist'" "':!*.xcconfig'" "':!*.xcodeproj/*'"

abbr -a --position anywhere -- --fuller --format=fuller

# For macOS `log` tool
abbr -a slf set log_file

# For Xcode memgraphs
abbr -a smem set memgraph

# Misc macOS
abbr -a caf caffeinate

# ls helpers
if command -q eza
  abbr -a lgit eza --git -A
  abbr -a ll eza -AgHlF
  abbr -a la eza -AF
  abbr -a l eza -GF
else
  abbr -a ll ls -AClF
  abbr -a la ls -AF
  abbr -a l ls -CF
end
