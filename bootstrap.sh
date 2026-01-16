#!/bin/bash

# Exit on error, undefined vars, or pipe failures
set -euo pipefail

# --- Configuration & Globals ---
REPO_URL="https://www.github.com/drkknigt/arch-pull"
REPO_DIR="/tmp/arch-pull"
BOOTSTRAP_LOCK="/tmp/bootstrap.lock"
VAULT_FILE="/tmp/vault_file"
BECOME_FILE="/tmp/become_file"

# New Global Variables for Args
TAGS_ARG=""
HIDE_INPUT=false

# --- Functions ---

show_help(){
    echo "Usage: $0 [-t \"tag1 tag2\"] [-s] [-h] [-c]"
    echo "Usage: $0 [OPTIONS]

    Arch Linux Development Environment Setup Script.
    This script automates Pacman optimization, dependency installation, and Ansible playbook execution.

    Options:
    -t, --tags 'tag1 tag2'  Run only specific Ansible tags (provide as a quoted, 
                            space-separated list).
    -s, --hide              Enable 'silent' mode for password prompts. Input will 
                            not be echoed to the terminal (recommended for security).
    -h, --help              Display this help message and exit.
    -p, --print-tags        Print all availabe ansible tags
    -c, --clear-cache       Removes all the temperoray files created

    Examples:
    $0 -s
    $0 --tags 'dotfiles packages'
    $0 -s -t 'aur'"
}


clear_cache(){
    [[ -f "$BECOME_FILE" ]] &&  rm "$SUDO_FILE" && echo "removed $SUDO_FILE";echo
    [[ -f "$VAULT_FILE" ]] && rm "$VAULT_FILE" && echo "removed $VAULT_FILE";echo
    [[ -f "$BOOTSTRAP_LOCK" ]] && rm "$BOOTSTRAP_LOCK" && echo "removed $BOOTSTRAP_LOCK";echo
}

print_tags(){
    echo -e "availabe tags: \n\n"
    echo "addons  alacritty  audio  brave  brave-config  budgie  build-tools  change_config  chmod_lf "
    echo "clangd  config  core  delta  directory  disable-systemd  disk-utility  docker  dotfiles  downgrade "
    echo "dunst  editor  editor_path  enable-systemd  firefox  fonts  fzf  game  git  glow  go  graphics  "
    echo "grimshot  hypr  i3  idle  kernel  kitty  languages  lazygit  lf  lf-command  lf-wrapper  lfrun  "
    echo "lts_node  lua  luacheck  media-utility-images  media-utility-videos  n  neovide  neovim  "
    echo "net-tools  network_manager  nnn  node  openvpn_config  pacman  picom  pip_main_libraries  "
    echo "poetry  polybar  polybar_rules  pyenv  python  qemu  remove_iptables  router  rust  screenshot  "
    echo "sddm  search  shelltheme  social  ssh  ssh_test  stow  suggestions-zsh  sway  system-utility  "
    echo "system  temp-power-utility  termfilechooser  terminals  tmux  ufw-net-filter  update-man  "
    echo "user-utility  utility  vim  virt  virt-manager  vpn  vscode  wallpapers  wayland"
    echo "wifi  wine  wlr-randr  xorg-friends  yay  zathura  zsh  zsh-defer remove_aur_builder remove_sudo_line"
}

parse_args() {
    # If no arguments, just return
    [[ $# -eq 0 ]] && return

    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help)
                show_help 
                exit 0
                ;;
            -p|--print-tags)
                print_tags 
                exit 0
                ;;
            -c|--clear-cache) 
                clear_cache
                ;;
            -t|--tags)
                # Check if the next argument exists and doesn't start with a '-'
                if [[ -n "${2:-}" && ! "$2" =~ ^- ]]; then
                    TAGS_ARG="--tags ${2// /,}"
                    shift 2 # Move past both the flag and the value
                else
                    echo "Error: $1 requires a space-separated list of tags in quotes."
                    exit 1
                fi
                ;;
            -s|--hide)
                HIDE_INPUT=true
                shift # Move past the flag
                ;;
            *)
                # If any other argument is found, throw an error
                echo "Error: Invalid argument '$1'"
                echo "Usage: $0 [-t \"tag1 tag2\"] [-s] [-h] [-p]"
                exit 1
                ;;
        esac
    done
}

setup_passwords() {
    echo "--- Credentials Setup ---"
    
    # Determine which read flag to use based on -s/--hide
    local read_flags="-rp"
    if [[ "$HIDE_INPUT" == true ]]; then
        read_flags="-rsp" # Added 's' for silent/hide
    fi

    if [[ ! -f "$BOOTSTRAP_LOCK" ]]; then
        read $read_flags "Enter Vault Password: " vault_pass; echo
        read $read_flags "Enter sudo (become) Password: " become_pass; echo
        echo "$vault_pass" > "$VAULT_FILE"
        echo "$become_pass" > "$BECOME_FILE"
        chmod 600 "$VAULT_FILE" "$BECOME_FILE"
    fi
    read $read_flags "Enter SSH Passphrase: " PASS_PHRASE; echo
    export PASS_PHRASE
}

edit_pacman() {
    echo "Optimizing Pacman configuration..."
    sudo sed -i 's/^#ParallelDownloads/ParallelDownloads/g' /etc/pacman.conf
    if ! grep -qP "^\[multilib\]" /etc/pacman.conf; then
        echo -e "\n[multilib]\nInclude = /etc/pacman.d/mirrorlist" | sudo tee -a /etc/pacman.conf
    fi
}

# --- Main Execution ---

# 0. Parse Arguments first
parse_args "$@"

read -p "Install rtl8821ce wifi driver? (y/n): " wifi_choice
install_wifi=$([[ "$wifi_choice" =~ ^[Yy]$ ]] && echo "yes" || echo "no")

setup_passwords

# 1. Bootstrap Phase
if [[ ! -f "$BOOTSTRAP_LOCK" ]]; then
    edit_pacman
    echo "Installing core dependencies..."
    cat "$BECOME_FILE" | sudo -S pacman -Syy --noconfirm
    cat "$BECOME_FILE" | sudo -S pacman -S --needed --noconfirm git ansible reflector
    ansible-galaxy collection install kewlfft.aur
    touch "$BOOTSTRAP_LOCK"
fi

# 2. Confirmation
read -p "Proceed with Ansible playbook? (y/n): " continue_script
[[ "$continue_script" =~ ^[Yy]$ ]] || exit 0

# 3. Environment Setup
eval $(ssh-agent -s -t 3600)

if [[ -d "$REPO_DIR" ]]; then
    rm -rf "$REPO_DIR"
fi

echo "Cloning repository..."
git clone "$REPO_URL" "$REPO_DIR"
cd "$REPO_DIR"

# 4. Run Playbook
# $TAGS_ARG is already formatted by parse_args
ansible-playbook local.yml \
    --become-password-file="$BECOME_FILE" \
    --vault-password-file="$VAULT_FILE" \
    --extra-vars "install_wifi=$install_wifi" \
    -vvv $TAGS_ARG

# 5. Post-installation Hooks
if [[ -f ~/.dotfiles/sys_d/systemd-disabled ]]; then
    source ~/.dotfiles/sys_d/systemd-disabled
fi
