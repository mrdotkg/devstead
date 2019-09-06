#!/usr/bin/env bash

if ! [ -x "$(command -v docker)" ]; then    
    # Install docker-ce
    echo 'installing docker-ce'
    curl -fsSL https://get.docker.com | bash -s
else
    echo "docker already installed."
fi

if ! [ -x "$(command -v docker-compose)" ]; then
    # Install Docker Compose
    echo 'installing docker-compose'
    curl -L "https://github.com/docker/compose/releases/download/1.11.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose 2>/dev/null
    chmod +x /usr/local/bin/docker-compose
    usermod -a -G docker vagrant
else
    echo 'docker-compose already installed.'
fi

if ! [ -x "$(command -v docker-cleanup)" ]; then
    echo 'installing docker cleanup script'
    cd /tmp
    git clone https://gist.github.com/76b450a0c986e576e98b.git
    cd 76b450a0c986e576e98b
    mv docker-cleanup /usr/local/bin/docker-cleanup
    chmod +x /usr/local/bin/docker-cleanup
else
    echo 'docker-cleanup already installed.'
fi

# Enable vagrant user to run docker commands
usermod -aG docker vagrant