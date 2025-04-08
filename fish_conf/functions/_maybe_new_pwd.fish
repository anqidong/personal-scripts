function _attempt_source_ros
  if not functions -q bass
    return
  end

  set -l ros_setup /opt/ros/humble/setup.bash
  if not test -e "$ros_setup"
    # ROS not installed on this machine, skip everything
    return
  end

  set -l maybe_path (ancestor-having-path "install/local_setup.bash")
  if test -z "$maybe_path"
    return
  end

  # If this shell has never sourced any ROS stuff, try to also source the
  # shared utils
  if not set -q "$_auto_sourced_ros_local_setup"
    echo "Sourcing $ros_setup"
    bass source $ros_setup

    set -l tb_setup ~/tb_ws/install/local_setup.bash
    if test -e $tb_setup
      echo "Sourcing $tb_setup"
      bass source $tb_setup
    end
  end

  if test "$maybe_path" != "~/tb_ws" -a \
      "$maybe_path" != "$_auto_sourced_ros_local_setup"
    set -g _auto_sourced_ros_local_setup $maybe_path
    set -l local_setup $maybe_path"/install/local_setup.bash"
    echo "Sourcing $local_setup"
    bass source $local_setup
  end

end

function _maybe_new_pwd -d \
    "Runs interactively, when the current directory may have changed"

  # set -l fish_trace

  # Check for virtualenv
  set -l maybe_path (ancestor-having-path ".venv/bin/activate.fish")

  if test -z "$maybe_path"
    if set -q _auto_sourced_venv_path && \
       test (path normalize "$_auto_sourced_venv_path""/.venv") = $VIRTUAL_ENV
      echo "Deactivating $VIRTUAL_ENV"
      deactivate
      set --erase _auto_sourced_venv_path
    end
  else  # test -n "$maybe_path"
    if test "$maybe_path" != "$_auto_sourced_venv_path"
      set -g _auto_sourced_venv_path $maybe_path
      set -l venv_script $maybe_path"/.venv/bin/activate.fish"
      echo "Sourcing $venv_script"
      source $venv_script
    end
  end

  # Check for ROS stuff
  _attempt_source_ros
end
