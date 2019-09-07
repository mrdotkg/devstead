#!/bin/bash

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
VC_USER=$( _encode $DEVSTEAD_VC_USER )
VC_PASS=$( _encode $DEVSTEAD_VC_PASS )
ARGS="'$VC_USER' '$VC_PASS'"
BOOT_SCRIPT="/home/vagrant/.devstead/boot/_main.py"
BOOT_LOG_FILE="/home/vagrant/.devstead/logs/boot.log"
OLD_MOTD_NEWS_URL="homestead.joeferguson.me"
NEW_MOTD_NEWS_URL="raw.githubusercontent.com/measdot/devstead/master/Resources/motd"

# Hook bootscript on machine startup, to download and update Devstead on each boot.
chmod +x $BOOT_SCRIPT
croncmd=$(echo "$BOOT_SCRIPT $ARGS >> $BOOT_LOG_FILE 2>&1" | sed -e 's,%,\\\%,g')
cronjob="@reboot $croncmd"
( crontab -l | grep -v -F "$croncmd" ; echo "$cronjob" ) | crontab -

# Personalize message of the day news url
sudo sed -i "s,$OLD_MOTD_NEWS_URL,$NEW_MOTD_NEWS_URL,g" /etc/default/motd-news
sudo service motd-news restart