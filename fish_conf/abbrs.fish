abbr -a ggrei git grep -Fin -C 5
abbr -a ggrep git grep -Fin -C 5
abbr -a --position anywhere grei grep -Fin -C 5

abbr -a ggrew git grep -Finw -C 5
abbr -a --position anywhere grew grep -Finw -C 5

# Helpers for `git grep` on projects with Xcode stuff
abbr -a --position anywhere -- xxc -- \
  "':!*.pbxproj'" "':!*.plist'" "':!*.xcconfig'" "':!*.xcodeproj/*'"

# For macOS `log` tool
abbr -a slf set log_file

# For Xcode memgraphs
abbr -a smem set memgraph

# ls helpers
abbr -a ll ls -alF
abbr -a la ls -A
abbr -a l ls -CF

