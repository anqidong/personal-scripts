function move-all --argument from_str to_str
  for f in $argv[3..-1]
      git mv "$f" (string replace -r $from_str $to_str $f)
  end
end
