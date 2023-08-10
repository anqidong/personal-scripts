function hex-to-utc -d "converts hex Weave timestamp to UTC"
  date -u --date="@"(math $argv / 1000)
end

