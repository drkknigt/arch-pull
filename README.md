# Ansible Playbook with Roles Readme

This repository contains  Ansible playbook with roles that i use to configure and set up various components on my local system. The playbook is designed to be run on the `local` machine and covers a range of tasks including system updates, Git configuration, terminal setup, editor installation, language configurations, core utilities, addon installations, dotfile management, gaming setup, and Docker configuration. Each task is modularized into separate roles to ensure easy maintenance and reusability.  

This repository contains a bootstrap.sh file that serves as an automated system bootstrapper.  
When executed, this script will automatically set up and install all the necessary components required for Ansible to run smoothly. It streamlines the process of installing all the Ansible-related dependencies, making it effortless to get started with the playbook and roles provided in the repository.

## Getting Started

### Prerequisites

- Ansible: Make sure you have Ansible installed on the `local` machine where you intend to run this playbook or alternatievly run bootstrap.sh which will install all the dependencies and the playbook itself
- Git : Make sure you have git installed to fetch this repo and clone it locally or alternatievly run bootstrap.sh
- Linux distro : This ansible playbook runs on  arch



### Running the Playbook

Once you have the repository cloned to your local machine and Ansible installed, you can run the playbook with the following command:

```ansible

ansible-playbook local.yml -vvv --ask-become-pass 
```

### Bootstrap

To Bootstrap your pc/laptop to install all the software and configuration desribed by the ansible playbook and roles use following commands:
```bash
curl https://raw.githubusercontent.com/drkknigt/arch-pull/main/bootstrap.sh && chmod +x bootstrap.sh
./bootstrap.sh
```
This command will install the full system softwares and set up all the configuration and dependencies described in this repo


## Playbook Structure

The playbook is structured into multiple plays, each corresponding to a specific set of tasks or roles. Below is an overview of each play and its associated role:

### 1. Install System (Pre-Tasks)

- Set up the pre-tasks that are required by the configuration to run successfully
- I basically update and upgrade the system in my pre tasks 

### 2. Git Role

- Set up git configuration for personal use
    - name
    - email
    - main branch
    - git  editor
    - git pager

### 3. Terminals Role

- Install terminals 
    - alacrityy
    - kitty

### 4. Editor Role

- Install PDE's & IDE's
    - vim
    - neovim
    - vscode

### 5. Languages Role

- Install various run times and programming languages used for developing
    - Rust
    - Go
    - Clangd
    - Node
    - Python

### 6. Core Role

- Install core system software for the linux like window manager,compositor, shell etc
    - tmux
    - i3wm
    - fzf
    - picom
    - polybar
    - zsh-shell
    - shell plugins main

### 7. Addons Role

- Insall addon software required for additional tasks 
    - lazygit
    - zathura
    - brave-browser
    - zettler
    - protonvpn
    - lf
    - nnn
    - terminal search tools
    - additional utilities

### 8. Config Role

- Set up personal dotfiles and configuration for various applications
    - set up dotfiles
    - set up wallpaper
    - stow dotfiles
    - set up configs 
    - download fonts
    - set up lf

### 9. Game Role

- Set up gaming kernel and wine and lutris etc for gaming
    - set up wine
    - set up lutris
    - set up kernel

### 10. Docker Role

- Install docker and related software

## Tags

Each play in the playbook is associated with a specific tag to allow selective execution of roles. You can use the tags to run only the plays that are relevant to your requirements. Here are the available tags:

- `addons` 
- `alacritty` 
- ` brave` 
- `change_config` 
- `clangd` 
- ` config` 
- `core` 
- ` delta` 
- `docker` 
- ` dotfiles` 
- `editor` 
- ` editor_path` 
- ` fd-find` 
- ` fonts` 
- ` fzf` 
- `game` 
- `git` 
- ` git_suggestions` 
- ` go` 
- ` i3` 
- ` kernel` 
- ` kitty` 
- ` languages` 
- ` lazygit` 
- ` lf` 
- ` lts_node` 
- ` lua` 
- ` luacheck` 
- ` n` 
- ` neovim` 
- ` net-tools` 
- ` nnn` 
- ` node` 
- ` oh_my_zsh` 
- ` os-utilities` 
- ` pdf-tools` 
- ` picom` 
- ` pip_main_libraries` 
- ` poetry` 
- ` polybar` 
- ` polybar_rules` 
- ` pyenv` 
- ` python` 
- ` ripgrep` 
- ` rust` 
- ` search` 
- ` shelltheme` 
- ` social` 
- ` stow` 
- ` stylua` 
- ` terminals` 
- ` tmux` 
- ` utility` 
- ` vim` 
- ` vpn` 
- ` vscode` 
- ` wallpapers` 
- ` wine` 
- ` zathura` 
- ` zettler` 
- ` zsh` 

To execute specific roles, use the `--tags` option with the `ansible-playbook` command. For example, to run only the Git and Editor roles, use:

```ansible
ansible-playbook playbook.yml --tags "git,editor"
```

## Customization

You can customize the roles and tasks within the playbook to suit your specific needs. Each role directory in the repository contains its tasks and configurations, which can be modified as required.

