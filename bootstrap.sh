#!/bin/bash
# This files installs all essential software for my arch installation

# install wifi drivers rtl8821ce

read -p "Do you want to install rtl8821ce wifi driver ? (yes/no)" wifi_info


# set up parallel downloads for pacman and update pacman local database and install git, ansible, reflector
sudo sed -i 's/#Parallel/Parallel/g' /etc/pacman.conf
sudo pacman -Syy
read -p "Do you wish to continue ? (yes/no) " continue_script
if [ "$continue_script" = "yes" ]; then
sudo pacman -S git ansible reflector

# start ssh agent in background
eval $(ssh-agent -s)

# run this if script passed with ansible tags 
if [ "$#" -gt "0" ] ; then
    ansible-pull --extra-vars install_wifi="$wifi_info" -U https://github.com/drkknigt/arch-pull -vvv --ask-vault-pass --ask-become-pass -t "$(echo "$@" | tr " " ",")" --ask-pass
    exit
fi

# ansible pull install everything 
ansible-pull --extra-vars install_wifi="$wifi_info" -U https://github.com/drkknigt/arch-pull -vvv --ask-become-pass --ask-pass
# set default applications
. ~/.dotfiles/sys_d/systemd-disabled
fi
