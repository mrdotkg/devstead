#!/bin/bash

BOOT_SCRIPT="/home/vagrant/.devstead/boot/_main.py"
BOOT_LOG_FILE="/home/vagrant/.devstead/logs/boot.log"
OLD_MOTD_NEWS_URL="homestead.joeferguson.me"
NEW_MOTD_NEWS_URL="raw.githubusercontent.com/measdot/devstead/master/Resources/motd"

# Hook bootscript on machine startup, to download and update Devstead on each boot.
chmod +x $BOOT_SCRIPT
croncmd=$(echo "$BOOT_SCRIPT >> $BOOT_LOG_FILE 2>&1" | sed -e 's,%,\\\%,g')
cronjob="@reboot $croncmd"0
# ( crontab -l | grep -v -F "$croncmd" ; echo "$cronjob" ) | crontab -

# Personalize message of the day news url
sudo sed -i "s,$OLD_MOTD_NEWS_URL,$NEW_MOTD_NEWS_URL,g" /etc/default/motd-news
sudo service motd-news restart

# $BOOT_SCRIPT >> $BOOT_LOG_FILE 2>&1
