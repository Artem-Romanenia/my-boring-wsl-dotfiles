#!/bin/bash

cat << 'EOF' > init_stuff_apt_update.sh
sudo apt update
sudo apt upgrade
EOF


cat << 'EOF' > init_stuff_install_basics.sh
echo "========== Installing Midnight Commander"
sudo apt install mc

echo "========== Installing Neovim"
sudo snap install nvim --classic

echo "========== Installing YADM"
sudo apt install yadm
EOF


cat << 'EOF' > init_stuff_clone_dotfiles.sh
echo "========== Cloning YADM repo"
if [ -d .local/share/yadm/repo.git ]
then
	echo "YADM is already cloned"
else
	echo "===== Cloning dotfiles"
	yadm clone "https://github.com/Artem-Romanenia/my-boring-wsl-dotfiles"
	echo "===== Overriding original files"
	yadm restore .
	echo "===== Installing YADM done"
fi
EOF


cat << 'EOF' > init_stuff_install_python.sh
echo "========== Installing Python stuff"
sudo apt install python3-pip
sudo apt install python3-virtualenv

if ! [ -d /home/artem/.mainvenv ]
then
	virtualenv -p python3 /home/artem/.mainvenv
fi
EOF


cat << 'EOF' > init_stuff_install_npm.sh
echo "========== Installing Npm"
sudo apt install npm
EOF


cat << 'EOF' > init_stuff_install_rust.sh
echo "========== Installing build essentials"
sudo apt-get install build-essential


echo "========== Installing Rust"

if [ -d .rustup ]
then
	echo "Rust is already installed"
else
	echo "===== Dowloading"
	curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
	echo "===== Update env"
	. "$HOME/.cargo/env"
fi
EOF


cat << 'EOF' > init_stuff_install_docker.sh
echo "========== Installing Docker"
if command -v docker &> /dev/null; then
	echo "Docker is already installed"
else
	wget -O docker_install.sh https://get.docker.com/
	chmod +x docker_install.sh
	echo "===== Changing to legacy sudo"
	echo "SELECT SUDO.WS WHEN ASKED"
	sudo update-alternatives --config sudo
	./docker_install.sh
	echo "===== Switch to rootless mode"
	sudo apt-get install -y uidmap
	/usr/bin/dockerd-rootless-setuptool.sh install
	rm docker_install.sh
	echo "===== Changing back to new sudo mode"
	echo "SELECT AUTO MODE WHEN ASKED"
	sudo update-alternatives --config sudo
fi
EOF


chmod +x init_stuff_apt_update.sh
chmod +x init_stuff_install_basics.sh
chmod +x init_stuff_clone_dotfiles.sh
chmod +x init_stuff_install_rust.sh
chmod +x init_stuff_install_docker.sh
chmod +x init_stuff_install_npm.sh
chmod +x init_stuff_install_python.sh


# Set Session Name
SESSION="init_stuff"
SESSIONEXISTS=$(tmux list-sessions | grep $SESSION)

# Only create tmux session if it doesn't already exist
if [ "$SESSIONEXISTS" = "" ]
then
	tmux new-session -d -s $SESSION

	# Window 1

	tmux rename-window -t 1 'First Time'
	tmux send-keys -t 'First Time' 'sleep 0.2 && clear' Enter 'cat init_stuff_apt_update.sh' Enter './init_stuff_apt_update.sh'
	tmux split-window -v
	tmux send-keys -t 'First Time' 'sleep 0.2 && clear' Enter 'cat init_stuff_clone_dotfiles.sh' Enter './init_stuff_clone_dotfiles.sh'
	tmux select-pane -t 1
	tmux split-window -h
	tmux send-keys -t 'First Time' 'sleep 0.2 && clear' Enter 'cat init_stuff_install_basics.sh' Enter './init_stuff_install_basics.sh'
	tmux select-pane -t 1

	# Window 2

	tmux new-window -t $SESSION:2 -n 'Rust'
	tmux send-keys -t 'Rust' 'sleep 0.2 && clear' Enter 'cat init_stuff_install_rust.sh' Enter './init_stuff_install_rust.sh'
	tmux select-pane -t 1

	# Window 3

	tmux new-window -t $SESSION:3 -n 'Docker'
	tmux send-keys -t 'Docker' 'sleep 0.2 && clear' Enter 'cat init_stuff_install_docker.sh' Enter './init_stuff_install_docker.sh'
	tmux select-pane -t 1

	# Window 4

	tmux new-window -t $SESSION:4 -n 'Npm'
	tmux send-keys -t 'Npm' 'sleep 0.2 && clear' Enter 'cat init_stuff_install_npm.sh' Enter './init_stuff_install_npm.sh'
	tmux select-pane -t 1

	# Window 5

	tmux new-window -t $SESSION:5 -n 'Python'
	tmux send-keys -t 'Python' 'sleep 0.2 && clear' Enter 'cat init_stuff_install_python.sh' Enter './init_stuff_install_python.sh'
	tmux select-pane -t 1
fi

tmux attach-session -t $SESSION:1

rm init_stuff_apt_update.sh
rm init_stuff_install_basics.sh
rm init_stuff_clone_dotfiles.sh
rm init_stuff_install_rust.sh
rm init_stuff_install_docker.sh
rm init_stuff_install_npm.sh
rm init_stuff_install_python.sh
