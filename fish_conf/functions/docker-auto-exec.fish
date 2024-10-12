function docker-auto-exec
  if test (count $argv) -eq 0
    echo "Can't exec into docker with no args"
    return -5
  end

  set -l _containers (docker ps --format "{{.Names}}")
  if test (count $_containers) -ne 1
    if test (count $_containers) -eq 0
      echo "No containers"
      return 5
    else
      echo "(FIXME) Not sure which container to pick amongst these:"
      echo $_containers
      return -3
    end
  end

  docker exec -it "$_containers" $argv
end
