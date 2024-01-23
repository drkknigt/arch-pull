#!/bin/bash
read -p "Do you want to install rtl8821ce wifi driver ? (yes/no)" wifi_info
sudo sed -i 's/#Parallel/Parallel/g' /etc/pacman.conf
sudo pacman -Syy
sudo pacman -S reflector
sudo cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bkp-"$(date +'%F_T_%H:%M:%S')"
read -p "please type country for mirrors: " country_selected
sudo reflector --verbose --latest 12 --protocol https --country $country_selected --save /etc/pacman.d/mirrorlist
sudo pacman -Syyu
read -p "Do you wish to continue ? (yes/no) " continue_script
if [ "$continue_script" = "yes" ]; then
sudo pacman -S git ansible
# sudo apt install --yes ansible git
if [ ! "1" -gt "$#" ] ; then
    ansible-pull --extra-vars install_wifi="$wifi_info" -U https://github.com/drkknigt/arch-pull -vvv --ask-vault-pass --ask-become-pass -t "$(echo "$@" | tr " " ",")"
    exit
fi
#
if [ "$wifi_info" = "yes" ]; then
    ansible-pull --extra-vars install_wifi="$wifi_info" -U https://github.com/drkknigt/arch-pull -vvv --ask-become-pass
else
    ansible-pull --extra-vars install_wifi="no" -U https://github.com/drkknigt/arch-pull -vvv --ask-become-pass
fi
. ~/.dotfiles/sys_d/systemd-disabled
fi
