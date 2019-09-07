#! /usr/bin/python3

from subprocess import call
from urllib.parse import quote
import sys
import os
import stat

vc_user     = os.environ['DEVSTEAD_VC_USER']        # read version control user name from env vars
vc_pass     = quote(os.environ['DEVSTEAD_VC_PASS']) # read password for the version control user from env vars
boot_dir    = '/home/vagrant/.devstead/boot'        # what happens at vm boot/startup?
patch_dir   = '/home/vagrant/.devstead/patches'     # patches are minor update to the vm, applies on next boot
logs_dir    = '/home/vagrant/.devstead/logs'        # traces i)each reboot and ii)every now and then patching of the vm

#---------------------------- I/III ----------------------------
print('-- Downloading latest updates from devstead repo')

call(f'git clone https://{vc_user}:{vc_pass}@github.com/measdot/devstead.git'.split(), cwd='/tmp')
call('rsync -abviuzP --inplace devstead/Resources/.devstead/ /home/vagrant/.devstead/'.split(), cwd='/tmp')
call('rm -rf devstead'.split(), cwd='/tmp')

#---------------------------- II/III ---------------------------
print('-- Applying patches to the vm')
patch_list = (os.listdir(patch_dir))
patch_list.sort()

for patch in patch_list:
    if patch.endswith('.py') or patch.endswith('.sh') :
        if os.path.exists(f'{logs_dir}/patch_{patch}.log'):
            # Patch install log found, must have been applied earlier
            print(f'Patch {patch} is already applied, skipping...')
        else:
            # Apply the patch
            patch_cmd   = f'{patch_dir}/{patch}'
            log_file    = open(f'{logs_dir}/patch_{patch}.log', "w")
            call(f'chmod +x {patch_cmd}'.split(), cwd=patch_dir)
            call(patch_cmd.split(), stdout=log_file, stderr=log_file, cwd=patch_dir)
            print(f'Patch {patch} applied.')

#---------------------------- III/III --------------------------
print('-- Running boot scripts')

for boot_script in os.listdir(boot_dir):
    if boot_script.endswith('.py') or boot_script.endswith('.sh'):
        # Run all bootscripts,  avoid running the calling script again
        if boot_script == os.path.basename(__file__): continue 
        print('-- script name: ' + boot_script)
        call(f'{boot_dir}/{boot_script}'.split(), cwd=boot_dir)