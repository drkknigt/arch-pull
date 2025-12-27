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


read -p "enter pass phrase: " PASS_PHRASE
export PASS_PHRASE

# set up parallel downloads for pacman and update pacman local database and install git, ansible, reflector
echo "$become_pass" | sudo -S sed -i 's/#Parallel/Parallel/g' /etc/pacman.conf
echo "[multilib]" | sudo tee -a /etc/pacman.conf
echo "Include = /etc/pacman.d/mirrorlist" | sudo tee -a /etc/pacman.conf

echo "$become_pass" | sudo -S pacman -Syy
read -p "Do you wish to continue ? (yes/no) " continue_script
if [ "$continue_script" = "yes" ]; then
sudo -S pacman -S git ansible reflector --noconfirm

# install kewlfft.aur for installing yay packages
ansible-galaxy collection install kewlfft.aur

# start ssh agent in background
eval $(ssh-agent -s)

# clone arch-pull for setting up arch linux
git clone https://www.github.com/drkknigt/arch-pull /tmp/arch-pull
cd /tmp/arch-pull

# run this if script passed with ansible tags 
if [ "$#" -gt "0" ] ; then
    ansible-playbook local.yml --become-password-file="$become_file" --vault-password-file="$vault_file" --extra-vars "install_wifi=$wifi_info"  -vvv -t "$(echo "$@" | tr " " ",")" 
    exit
fi

# ansible  install everything 
ansible-playbook local.yml --become-password-file="$become_file" --vault-password-file="$vault_file" --extra-vars "install_wifi=$wifi_info"  -vvv 
# set default applications
. ~/.dotfiles/sys_d/systemd-disabled
fi
