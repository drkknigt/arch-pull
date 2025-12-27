#!/bin/bash

# Exit on error, undefined vars, or pipe failures
set -euo pipefail

# --- Configuration & Globals ---
REPO_URL="https://www.github.com/drkknigt/arch-pull"
REPO_DIR="/tmp/arch-pull"
BOOTSTRAP_LOCK="/tmp/bootstrap.lock"
VAULT_FILE="/tmp/vault_file"
BECOME_FILE="/tmp/become_file"


# --- Functions ---

setup_passwords() {
    echo "--- Credentials Setup ---"
    if [[ ! -f "$BOOTSTRAP_LOCK" ]]; then
        read -p "Enter Vault Password: " vault_pass; echo
        read -p "Enter sudo (become) Password: " become_pass; echo
        echo "$vault_pass" > "$VAULT_FILE"
        echo "$become_pass" > "$BECOME_FILE"
        chmod 600 "$VAULT_FILE" "$BECOME_FILE"
    fi
    read -p "Enter SSH Passphrase: " PASS_PHRASE
    export PASS_PHRASE
}

edit_pacman() {
    echo "Optimizing Pacman configuration..."
    # Enable Parallel downloads
    sudo sed -i 's/^#ParallelDownloads/ParallelDownloads/g' /etc/pacman.conf
    
    # Enable multilib if not present
    if ! grep -qP "^\[multilib\]" /etc/pacman.conf; then
        echo -e "\n[multilib]\nInclude = /etc/pacman.d/mirrorlist" | sudo tee -a /etc/pacman.conf
    fi
}

# --- Main Execution ---

read -p "Install rtl8821ce wifi driver? (y/n): " wifi_choice
install_wifi=$([[ "$wifi_choice" =~ ^[Yy]$ ]] && echo "yes" || echo "no")

setup_passwords
# 1. Bootstrap Phase
if [[ ! -f "$BOOTSTRAP_LOCK" ]]; then
    edit_pacman
    
    echo "Installing core dependencies..."
    # Passing password via stdin to sudo
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

# 4. Handle Tags
TAGS_ARG=""
if [[ $# -gt 0 ]]; then
    TAGS_ARG="--tags $(IFS=,; echo "$*")"
fi

# 5. Run Playbook
ansible-playbook local.yml \
    --become-password-file="$BECOME_FILE" \
    --vault-password-file="$VAULT_FILE" \
    --extra-vars "install_wifi=$install_wifi" \
    -vvv $TAGS_ARG

# 6. Post-installation Hooks
if [[ -f ~/.dotfiles/sys_d/systemd-disabled ]]; then
    source ~/.dotfiles/sys_d/systemd-disabled
fi
