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

  for f in (grep -rl -E $argv[1] $file_paths)
    echo "Processing $f"

    # If user presses Ctrl-C, call cquit to exit vim with an error.
    #
    # (The try/catch is to suppress additional errors that %s throws up when
    # pressing Ctrl-C while it's running.)
    vim -c "nnoremap <C-c> :cquit<CR>" \
      -c "try | %s/$from_str/$to_str/gc | catch | cq" \
      -c "wq" $f

    if test $status -ne 0
      echo "Exiting early after $f ~"
      return -1
    end
  end
end
