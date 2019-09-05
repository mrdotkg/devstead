#!/usr/bin/env bash

cd /home/ubuntu
wget https://releases.hashicorp.com/terraform/0.11.10/terraform_0.11.10_linux_amd64.zip
unzip terraform_0.11.10_linux_amd64.zip
sudo mv terraform /usr/sbin/terraform
export PATH=$PATH:/usr/sbin/

# cleanup of zip and old executable
sudo rm /usr/local/bin/terraform
rm /home/ubuntu/terraform_0.11.10_linux_amd64.zip
