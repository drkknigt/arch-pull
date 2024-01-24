#!/bin/bash
read -p "Do you want to install rtl8821ce wifi driver ? (yes/no)" wifi_info
sudo sed -i 's/#Parallel/Parallel/g' /etc/pacman.conf
sudo pacman -Syy
read -p "Do you wish to continue ? (yes/no) " continue_script
if [ "$continue_script" = "yes" ]; then
sudo pacman -S git ansible reflector
# sudo apt install --yes ansible git
if [ ! "1" -gt "$#" ] ; then
    ansible-pull --extra-vars install_wifi="$wifi_info" -U https://github.com/drkknigt/arch-pull -vvv --ask-vault-pass --ask-become-pass -t "$(echo "$@" | tr " " ",")" --ask-pass
    exit
fi
#
if [ "$wifi_info" = "yes" ]; then
    ansible-pull --extra-vars install_wifi="$wifi_info" -U https://github.com/drkknigt/arch-pull -vvv --ask-become-pass --ask-pass
else
    ansible-pull --extra-vars install_wifi="no" -U https://github.com/drkknigt/arch-pull -vvv --ask-become-pass --ask-pass
fi
. ~/.dotfiles/sys_d/systemd-disabled
fi
