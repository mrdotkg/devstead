# Devstead

## Prerequisite

VirtualBox, Vagrant and Ansible

## futher modifications

- Install ansible on mac
- Insttall ansible galaxy requirement on mac
- Add example playbook main.yml from [ansible for devops](https://github.com/geerlingguy/ansible-for-devops)
- Add more tasks in main playbook.yml if needed. A shell for post provision is added

## Access VM by its name not an IP

Exposes a `devstead` command to host os

- append this to ~/.bash_profile of Host OS

```bash
function devstead() {
    ( ssh vagrant@127.0.0.1 -p 2222 $* )
}
```

## How devstead gets same ssh access as of Host OS

1. Adds a copy of **Host Private Key** to the vm as a file
2. Appends **Host Public Key** as a string onto ~/.ssh/authorized of vm
3. Adds github.com URL to known hosts `ssh-keyscan -H github.com >> ~/.ssh/known_hosts` of VM

## Devloper workflow through ssh

- SSH keygen at Host
- Add ssh public key to github accounts
- git clone this repo, cd into it
- $ vagrant up
- Clone and run a github project
  - vagrant ssh
  - cd ~/Projects
  - git clone git@github.com:*/*

## Improvements

- Differenciable Shared Folder - BOD-Projects?
- Do we need secrets?
- Remove if else from Vagrantfile and standardize vmconf

## This works

```bash
ssh -i /Users/kgaurav/Projects/Devstead/.vagrant/machines/default/virtualbox/private_key  -o PasswordAuthentication=no vagrant@127.0.0.1 -p 2222
```

## Future Extension

A cli tool on top of vm, sometime in the future. Right now we are appending a bash_profile function as a psudo cli workaround. Cli should be able to do-

- Vm Conf modification
- VM installation on mac, linux, windows
- Vm update, delete and up. State management
