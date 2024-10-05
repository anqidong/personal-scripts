#!/bin/bash

# Set options for better command logging and error handling
set -euxo pipefail

# Set locale (UTF-8)
echo "Locale is $(locale)"
if ! locale | grep -q UTF-8; then
  echo "Installing locales..."
  sudo apt update && sudo apt install -y locales
  sudo locale-gen en_US en_US.UTF-8
  sudo update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
  export LANG=en_US.UTF-8  

  echo "Verifying locale settings..."
  locale
fi

# Setup ROS2 sources
echo "Setting up ROS2 sources..."
sudo apt install software-properties-common -y
sudo add-apt-repository universe -y
sudo apt update && sudo apt install curl -y
sudo rm -f /usr/share/keyrings/ros-archive-keyring.gpg
sudo curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key \
  -o /usr/share/keyrings/ros-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) \
  signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] \
  http://packages.ros.org/ros2/ubuntu \
  $(. /etc/os-release && echo $UBUNTU_CODENAME) main" | \
  sudo tee /etc/apt/sources.list.d/ros2.list > /dev/null  


# Update and upgrade system
echo "Updating system..."
sudo apt update && sudo apt upgrade -y

# Install ROS2 packages (choose one)
# Option 1: Desktop Install (Recommended)
# echo "Installing ROS2 Desktop (recommended)..."
# sudo apt install ros-humble-desktop

# Option 2: ROS-Base Install (Bare Bones)
echo "Installing ROS2 Base (bare bones)..."
sudo apt install -y ros-humble-ros-base

# Install development tools
echo "Installing development tools..."
sudo apt install -y ros-dev-tools


# Install Gazebo Garden dependencies
echo "Installing Gazebo Garden dependencies..."
sudo apt update && sudo apt install -y lsb-release wget gnupg

# Setup Gazebo keys and sources
echo "Setting up Gazebo keys and sources..."
sudo rm -f /usr/share/keyrings/pkgs-osrf-archive-keyring.gpg
sudo wget https://packages.osrfoundation.org/gazebo.gpg \
  -O /usr/share/keyrings/pkgs-osrf-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) \
  signed-by=/usr/share/keyrings/pkgs-osrf-archive-keyring.gpg] \
  http://packages.osrfoundation.org/gazebo/ubuntu-stable \
  $(lsb_release -cs) main" | \
  sudo tee /etc/apt/sources.list.d/gazebo-stable.list > /dev/null  


# Install Gazebo Garden 
echo "Installing Gazebo Garden..."
sudo apt update && sudo apt install -y gz-garden

# Initialize rosdep (optional)
echo "Initializing rosdep (skip if done earlier)..."
rosdep init || true

# Create ROS2 workspace
echo "Setting up ROS2 workspace..."
# Install git dependency
sudo apt install git -y

# Create workspace directory
mkdir -p ~/tb_ws/src

# Clone ROS packages
cd ~/tb_ws/src

clone_if_missing() {
  local repo_url="$1"
  # Extract the last path component as the target directory
  local target_dir="${repo_url##*/}"

  shift  # Remove the first argument (repo_url)

  if [[ ! -d "$target_dir" ]]; then
    git clone "$repo_url" "$target_dir" "$@"
  fi
}

clone_if_missing "https://github.com/gazebosim/ros_gz.git" -b humble
clone_if_missing "https://github.com/StanfordASL/asl-tb3-driver.git"
clone_if_missing "https://github.com/StanfordASL/asl-tb3-utils.git"

# Install dependencies  

echo "Installing dependencies..."
{
  # The ROS setup.bash script typically will have some uncaught failing commands,
  # so we wrap it in a subshell to shield it from the stricter bash setup so that
  # everything is happy.
  source /opt/ros/humble/setup.bash  # Use setup.zsh if using zsh
  set -euxo pipefail

  rosdep update && rosdep install --from-paths ~/tb_ws/src -r -i -y

  # Build the code  

  echo "Building the code (might take a few minutes)..."
  export GZ_VERSION=garden
  cd ~/tb_ws && colcon build --symlink-install
}

# Update shell configuration (modify for zsh)
echo "Updating shell configuration..."
# echo "source /opt/ros/humble/setup.bash" >> ~/.bashrc
# echo "source \$HOME/tb_ws/install/local_setup.bash" >> ~/.bashrc
# echo "alias update_tb_ws=\$HOME/tb_ws/src/asl-tb3-utils/scripts/update.sh" >> ~/.bashrc
# source ~/.bashrc  

echo "Gazebo Garden and ROS2 workspace setup complete!"

exit 0
