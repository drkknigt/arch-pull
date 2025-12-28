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
curl https://raw.githubusercontent.com/drkknigt/arch-pull/main/bootstrap.sh -o bootstrap.sh && chmod +x bootstrap.sh
./bootstrap.sh
```
This command will install the full system softwares and set up all the configuration and dependencies described in this repo


