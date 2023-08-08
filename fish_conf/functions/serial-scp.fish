function serial-scp --argument-names server1 server2_spec file_path
  if test (count $argv) -ne 3
    echo "Wrong number of arguments"
    return -2
  end

  if not set -f temp_path (ssh -t $server1 "mktemp -d")
    echo "Could not set up temporary path"
    return -1
  end
  # For some reason this has a trailing carriage return otherwise
  set temp_path (string trim $temp_path)

  set -f file_name (path basename $file_path)

  set fish_trace 1

  scp $file_path $server1":"$temp_path &&
    ssh -t $server1 "scp $temp_path/$file_name $server2_spec"

  ssh -t $server1 "rm -rf $temp_path"
end
