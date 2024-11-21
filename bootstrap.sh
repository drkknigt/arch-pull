#!/bin/bash
# This files installs all essential software for my arch installation

# install wifi drivers rtl8821ce

read -p "Do you want to install rtl8821ce wifi driver ? (yes/no)" wifi_info

# vault , pass , become files
vault_file=/tmp/vault_file
become_file=/tmp/become_file

read -p "enter vault password: " vault_pass
echo "$vault_pass" > "$vault_file"


read -p "enter become password: " become_pass
echo "$become_pass" > "$become_file"


# set up parallel downloads for pacman and update pacman local database and install git, ansible, reflector
echo "$become_pass" | sudo -S sed -i 's/#Parallel/Parallel/g' /etc/pacman.conf
echo "$become_pass" | sudo -S pacman -Syy
read -p "Do you wish to continue ? (yes/no) " continue_script
if [ "$continue_script" = "yes" ]; then
echo "$become_pass" | sudo -S pacman -S git ansible reflector

# start ssh agent in background
eval $(ssh-agent -s)

# run this if script passed with ansible tags 
if [ "$#" -gt "0" ] ; then
    ansible-pull --become-password-file="$become_file" --vault-password-file="$vault_file" --extra-vars "install_wifi=$wifi_info" -U https://github.com/drkknigt/arch-pull -vvv -t "$(echo "$@" | tr " " ",")" 
    exit
fi

# ansible pull install everything 
ansible-pull --become-password-file="$become_file" --vault-password-file="$vault_file" --extra-vars "install_wifi=$wifi_info" -U https://github.com/drkknigt/arch-pull -vvv 
# set default applications
. ~/.dotfiles/sys_d/systemd-disabled
fi
