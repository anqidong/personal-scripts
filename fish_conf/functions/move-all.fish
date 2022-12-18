for f in */*3.1.3.mak
    git mv "$f" (string replace -r 3.1.3 3.1 $f)
end

