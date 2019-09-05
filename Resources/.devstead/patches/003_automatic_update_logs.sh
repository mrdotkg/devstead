#!/usr/bin/env bash

sudo bash -c 'cat <<EOT > /etc/rc.local
#!/bin/sh -e
#
# rc.local
#
# This script is executed at the end of each multiuser runlevel.
# Make sure that the script will "exit 0" on success or any other
# value on error.
#
# In order to enable or disable this script just change the execution
# bits.
#
# By default this script does nothing.

exec 1>>/var/log/rc.local.log
exec 2>&1
set -x # tell sh to display commands before execution

date "+%Y-%m-%d %H:%M:%S"
/home/ubuntu/Projects/et-devbox/vagrant-devbox/box-init/run.py
exit 0
EOT'