#!/usr/bin/env bash

# AWS-CLI INSTALLER - Automated AWS CLI Installation
sudo apt-get install -y python3-dev python3-pip --fix-missing
su - ubuntu -c "pip3 install awscli --upgrade --user"

VERSION=$(aws --version 2>&1)
echo "aws-cli installed version = ${VERSION}"