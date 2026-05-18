function docc-preview --description "Preview a DocC catalog in the browser" --argument-names docc port
    if test -z "$docc"
        echo "Usage: docc-preview <path/to/Foo.docc> [port]" >&2
        return 1
    end

    set -q port[1]; or set port 18181
    set bundle_name (basename $docc .docc)
    set bundle_id (string lower $bundle_name)

    xcrun docc preview $docc \
        --fallback-display-name $bundle_name \
        --fallback-bundle-identifier $bundle_id \
        --fallback-bundle-version 1.0 \
        --port $port &

    sleep 2
    open "http://localhost:$port/documentation/$bundle_id"
    wait
end
