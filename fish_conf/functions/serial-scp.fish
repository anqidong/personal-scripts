function serial-scp --argument-names server1 server2_spec file_path
    # You probably want to just run this directly:
    #   scp -J server1 file_path server2_spec

    if test (count $argv) -ne 3
        echo "Wrong number of arguments"
        echo ""
        echo "  Or just run directly:"
        echo "    scp -J SERVER1 FILE_PATH SERVER2_SPEC"
        return -2
    end

    read -P "Run: scp -J $server1 $file_path $server2_spec? [y/N] " -n 1 answer
    if test "$answer" != y
        return 0
    end

    scp -J $server1 $file_path $server2_spec
end
