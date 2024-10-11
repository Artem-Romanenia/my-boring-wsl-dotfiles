#!/bin/bash


read -p "Do you want to update apt? (y/n): " apt_update

if [ $apt_update = y ]
then
	sudo apt update
fi

read -p "Do you want to upgrade apt? (y/n): " apt_upgrade

if [ $apt_upgrade = y ]
then
	sudo apt upgrade
fi



read -p "Do you want to update /etc/wsl.conf to include generateResolvConf=false setting? (y/n): " mod_wsl_conf

if [ $mod_wsl_conf = y ]
then
	echo "========== Modifying wsl.conf"

	if grep -q "\[network\]" /etc/wsl.conf
	then
		if grep -q "generateResolvConf" /etc/wsl.conf
		then
			echo "wsl.conf seems to be properly configured"
		else
			read -p "Modify wsl.conf and add generateResolvConf = false to the [network] section. Ready? (y/n): " wsl_ready
			if [ $wsl_ready = y ]
			then
				sudo vim /etc/wsl.conf
			else
				echo "Skipping wsl.conf configuration"
			fi
		fi
	else
		echo "[network]" | sudo tee -a /etc/wsl.conf >> /dev/null
		echo "generateResolvConf=false" | sudo tee -a /etc/wsl.conf >> /dev/null
		echo "Modifying wsl.conf done"
	fi
fi



read -p "Do you want to modify /run/resolvconf/resolv.conf? (y/n): " mod_resolv_conf

if [ $mod_resolv_conf = y ]
then
	echo "========== Modifying resolv.conf"

	if [ -d /run/resolvconf ]
	then
		echo "===== Dir /run/resolvconf already exists"
	else
		echo "===== Creating /run/resolvconf dir"
		sudo mkdir /run/resolvconf
	fi

	echo "===== Add nameserver 1.1.1.1"
	echo "nameserver 1.1.1.1" | sudo tee /run/resolvconf/resolv.conf > /dev/null
	echo "Modifying resolv.conf done"
fi



echo "========== Installing Midnight Commander"
sudo apt install mc



echo "========== Installing YADM"
sudo apt install yadm



echo "========== Cloning YADM repo"
if [ -d .local/share/yadm/repo.git ]
then
	echo "YADM is already cloned"
else
	echo "===== Cloning dotfiles"
	yadm clone "https://github.com/Artem-Romanenia/my-boring-wsl-dotfiles"
	echo "===== Overriding original files"
	yadm restore .
	echo "Installing YADM done"
fi



echo "========== Installing Python stuff"
sudo apt install python3-pip
sudo apt install python3-virtualenv

if ! [ -d /home/artem/.mainvenv ]
then
	virtualenv -p python3 /home/artem/.mainvenv
fi



echo "========== Installing Npm"
sudo apt install npm



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



echo "========== Installing Neovim"

if [ -f /usr/bin/nvim ]
then
	echo "Neovim is already installed"
else
	echo "===== Getting the AppImage file"
	curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim.appimage
	echo "===== Making executable"
	sudo chmod u+x nvim.appimage
	echo "===== Extract AppImage"
	./nvim.appimage --appimage-extract
	echo "===== Move extracted files to root"
	sudo mv squashfs-root /
	echo "===== Create symlink in /usr/bin"
	sudo ln -s /squashfs-root/AppRun /usr/bin/nvim
	echo "===== Clone packer.nvim"
	git clone --depth 1 https://github.com/wbthomason/packer.nvim ~/.local/share/nvim/site/pack/packer/start/packer.nvim
	read -p "Now Neovim will run. Run ':PackerSync'. Ready? (y/n): " nvim_ready
	if [ $nvim_ready = y ]
	then
		nvim
	else
		echo "Skipping Neovim configuration"
	fi
	echo "Installing Neovim done"
fi
