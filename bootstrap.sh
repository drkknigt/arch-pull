#!/bin/bash
read -p "Do you want to install rtl8821ce wifi driver ? (yes/no)" wifi_info
sudo sed -i 's/#Parallel/Parallel/g' /etc/pacman.conf
sudo pacman -Syy
sudo pacman -S reflector
if [ ! -f /etc/pacman.d/mirrorlist.bkp ]; then
    sudo cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bkp
fi
sudo reflector --verbose --latest 12 --protocol https --country 'India' --save /etc/pacman.d/mirrorlist
sudo pacman -Syyu
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
