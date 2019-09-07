#!/bin/bash

# Configure Git (Bitbucket)
echo "Configuring Git client .."
git config --global user.name "$DEVSTEAD_DEV_FULL_NAME"
git config --global user.email $DEVSTEAD_DEV_EMAIL
git config --global credential.helper store
git config --global core.autocrlf input
git config --global push.default simple

# Configure SSH so it always defaults to the right user
echo -e "Host *\n  User $DEVSTEAD_SERVERS_DEFAULT_USER" >> /home/vagrant/.ssh/config