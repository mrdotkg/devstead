#! /usr/bin/python3

from subprocess import call
import sys
import os
import stat

vc_user     = sys.argv[1]                       # version control user name
vc_pass     = sys.argv[2]                       # password for the version control user
boot_dir    = '/home/vagrant/.devstead/boot'    # what happens at vm boot/startup?
patch_dir   = '/home/vagrant/.devstead/patches' # patches are minor update to the vm, applies on next boot
logs_dir    = '/home/vagrant/.devstead/logs'    # traces i)each reboot and ii)every now and then patching of the vm

#---------------------------- I/III ----------------------------
print('-- Downloading latest updates from devstead repo')

call(f'git clone https://{vc_user}:{vc_pass}@github.com/measdot/devstead.git'.split(), cwd='/tmp')
call('rsync -abviuzP devstead/Resources/.devstead/ /home/vagrant/.devstead/'.split(), cwd='/tmp')
call('rm -rf devstead'.split(), cwd='/tmp')

#---------------------------- II/III ---------------------------
print('-- Applying patches to the vm')
patch_list = (os.listdir(patch_dir))
patch_list.sort()

for patch in patch_list:
    if os.path.exists(f'{logs_dir}/patch_{patch}.log'):
        # Patch install log found, must have been applied earlier
        print(f'Patch {patch} is already applied, skipping...')
    else:
        # Apply the patch
        patch_cmd = f'{patch_dir}/{patch}'
        os.chmod(patch_cmd, os.stat(patch_cmd).st_mode | stat.S_IEXEC) # existing permission+= OWNER_CAN_EXECUTE
        call(f'{patch_cmd} >> {logs_dir}/patch_{patch}.log 2>&1'.split(), cwd=patch_dir)
        print(f'Patch {patch} applied.')

#---------------------------- III/III --------------------------
print('-- Running boot scripts')

for boot_script in os.listdir(boot_dir):
    if boot_script.endswith('.py') or boot_script.endswith('.sh') :
        print('-- script name: ' + boot_script)
        call(f'{boot_dir}/{boot_script}'.split(), cwd=boot_dir)