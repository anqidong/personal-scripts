function find-path-in-any-parent --argument-names search_path
    if test -z $search_path
        echo "Error: search_path is empty" >&2
        return -1
    end

    set -l _dir $PWD

    while true
        if test -e "$_dir/$search_path"
            echo "$_dir"
            return 0
        end

        if test "$_dir" = "/"
            return 1
        end

        # Move up one directory level
        set _dir (dirname $_dir)
    end
end
