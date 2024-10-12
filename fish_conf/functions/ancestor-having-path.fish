function ancestor-having-path --argument-names search_path \
  -d "If pwd or any of its parents contains the search path, returns it"

    if test -z $search_path
        echo "Error: search_path is empty" >&2
        return -1
    end

    set -l _dir $PWD
    set -l _iter 1

    while test $_iter -le 1000
        if test -e "$_dir/$search_path"
            echo "$_dir"
            return 0
        end

        if test "$_dir" = "/"
            return 1
        end

        # Move up one directory level
        set _dir (path dirname $_dir)
        set _iter (math $_iter + 1)
    end

    echo "Error: too many iterations; $_dir still isn't the root" >&2
    return -2
end
