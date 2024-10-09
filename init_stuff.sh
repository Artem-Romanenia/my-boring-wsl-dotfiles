#!/bin/bash


read -p "You need to run me as sudo. Are you running me as sudo? (y/n): " as_sudo

if [ $as_sudo = y ]
then
	echo "Ok, continuing..."
else
	exit
fi

read -p "Do you want to update apt? (y/n): " apt_update

if [ $apt_update = y ]
then
	apt update
fi

read -p "Do you want to upgrade apt? (y/n): " apt_upgrade

if [ $apt_upgrade = y ]
then
	apt upgrade
fi



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
			vim /etc/wsl.conf
		else
			echo "Skipping wsl.conf configuration"
		fi
	fi
else
	echo "[network]" >> /etc/wsl.conf
	echo "generateResolvConf=false" >> /etc/wsl.conf
	echo "Modifying wsl.conf done"
fi



echo "========== Modifying resolv.conf"

if [ -d /run/resolvconf ]
then
	echo "===== Dir /run/resolvconf already exists"
else
	echo "===== Creating /run/resolvconf dir"
	mkdir /run/resolvconf
fi

echo "===== Empty or create /run/resolvconf/resolv.conf"
> /run/resolvconf/resolv.conf
echo "===== Add nameserver 1.1.1.1"
echo "nameserver 1.1.1.1" > /run/resolvconf/resolv.conf
echo "Modifying resolv.conf done"



echo "========== Installing build essentials"
apt-get install build-essential



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



echo "========== Installing YADM"
apt install yadm



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



echo "========== Installing Midnight Commander"
apt install mc



echo "========== Installing Neovim"

if [ -f /usr/bin/nvim ]
then
	echo "Neovim is already installed"
else
	echo "===== Getting the AppImage file"
	curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim.appimage
	echo "===== Making executable"
	chmod u+x nvim.appimage
	echo "===== Extract AppImage"
	./nvim.appimage --appimage-extract
	echo "===== Move extracted files to root"
	mv squashfs-root /
	echo "===== Create symlink in /usr/bin"
	ln -s /squashfs-root/AppRun /usr/bin/nvim
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
