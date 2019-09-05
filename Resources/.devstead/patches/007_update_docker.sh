#!/usr/bin/env bash

# Docker
echo "installing docker"
sudo apt-get update
sudo apt-get install -y docker-ce

# Docker Compose
echo "installing docker-compose"
sudo curl -L "https://github.com/docker/compose/releases/download/1.23.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
