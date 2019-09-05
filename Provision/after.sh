#!/bin/bash

# Install Docker Compose
if ! [ -x "$(command -v docker-compose)" ]; then
    
    echo 'installing docker-composes'
    curl -L "https://github.com/docker/compose/releases/download/1.11.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose 2>/dev/null
    chmod +x /usr/local/bin/docker-compose
    usermod -a -G docker vagrant
    
    echo 'installing docker cleanup script'
    cd /tmp
    git clone https://gist.github.com/76b450a0c986e576e98b.git
    cd 76b450a0c986e576e98b
    mv docker-cleanup /usr/local/bin/docker-cleanup
    chmod +x /usr/local/bin/docker-cleanup
else
    echo 'skipping docker-compose and docker cleanup, already installed'
fi

# Hook run.py on machine startup, to download and update Devstead on each boot.
_encode() {
    local string="${1}"
    local strlen=${#string}
    local encoded=""
    local pos c o
    
    for (( pos=0 ; pos<strlen ; pos++ )); do
        c=${string:$pos:1}
        case "$c" in
            [-_.~a-zA-Z0-9] ) o="${c}" ;;
            * )               printf -v o '%%%02x' "'$c"
        esac
        encoded+="${o}"
    done
    echo "${encoded}"
}
VC_USER=$( _encode $1 )
VC_PASS=$( _encode $2 )

chmod +x /home/vagrant/.devstead/boot/*.py
croncmd=$(echo "/home/vagrant/.devstead/boot/_main.py '${VC_USER}' '${VC_PASS}' >> /home/vagrant/.devstead/logs/reboot.log 2>&1" | sed -e 's,%,\\\%,g')
cronjob="@reboot $croncmd"
( crontab -l | grep -v -F "$croncmd" ; echo "$cronjob" ) | crontab -


## Change message of the day
sudo sed -i "s,homestead.joeferguson.me,raw.githubusercontent.com/measdot/devstead/master/Resources/motd,g" /etc/default/motd-news
sudo service motd-news restart