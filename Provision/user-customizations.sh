#!/bin/bash

PROJECTS_DIR="/home/vagrant/Projects" 

groupadd -r company --gid 9009
usermod -a -G company vagrant
chown -R vagrant:company $PROJECTS_DIR
chmod -R g+s $PROJECTS_DIR

# Copy user specific configuration to local variables
DEV_FULL_NAME=$1
DEV_EMAIL=$2
SERVERS_DEFAULT_USER=$3

# Configure Git (Bitbucket)
echo "Configuring Git client .."
git config --global user.name "$DEV_FULL_NAME"
git config --global user.email $DEV_EMAIL
git config --global credential.helper store
git config --global core.autocrlf input
git config --global push.default simple

# Configure SSH so it always defaults to the right user
echo -e "Host *\n  User $SERVERS_DEFAULT_USER" >> /home/vagrant/.ssh/config