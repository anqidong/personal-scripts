function multi-sed-vim
  if test (count $argv) -lt 2
    echo "usage: $_ <old_patt> <new_patt> [<files>]"
    return -1
  else if test (count $argv) -eq 2
    set -l file_paths "."
  else
    set -l file_paths $argv[3..-1]
  end

  set -l from_str (string replace -a '/' '\/' $argv[1])
  set -l to_str (string replace -a '/' '\/' $argv[2])

  echo $from_str → $to_str

  set fish_trace 1

  # for i in (grep -rl -Pz $argv[1] $file_paths);
  for i in (grep -rl -E $argv[1] $file_paths);
    vim -c "%s/"$argv[1]"/"$argv[2]"/gc" -c "wq" $i
    # sed -E "s/"$from_str"/"$to_str"/g" $i > $i.tmp; mv $i.tmp $i
    # perl -0777 -i -p -e "s/"$from_str"/"$to_str"/smg" $i
  end
end
