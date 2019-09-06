# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'yaml'

rootDir                 = File.expand_path(File.dirname(__FILE__))
secretsYamlPath         = rootDir + '/_secrets.yaml'
devsteadYamlPath        = rootDir + '/Devstead.yaml'
devsteadClass           = rootDir + '/Devstead.rb'
aliasesPath             = rootDir + '/provision/aliases'
afterShPath             = rootDir + '/provision/after.sh'
userCustomizationsShPath= rootDir + '/provision/user-customizations.sh'

Vagrant.require_version '>= 2.2.4'
Vagrant.configure(2) do |config|
    [secretsYamlPath, devsteadYamlPath, devsteadClass, afterShPath, userCustomizationsShPath].each do |file|
        if !File.exist? file then
            abort "ERROR: Important configuration file '#{file}' is missing, process stopped."
        end
    end

    require devsteadClass
    secrets = YAML::load(File.read(secretsYamlPath))
    vmConf  = YAML::load(File.read(devsteadYamlPath))

    Devstead.configure(config, vmConf, secrets)
    config.vm.provision "shell", privileged: false, path: userCustomizationsShPath, name: "Personalize git"
    config.vm.provision "shell", privileged: false, path: afterShPath, name: "Configure update self on boot"
    config.vm.provision "file", source: aliasesPath, destination: "/tmp/bash_aliases"
    config.vm.provision "shell", inline: "awk '{ sub(\"\r$\", \"\"); print }' /tmp/bash_aliases > /home/vagrant/.bash_aliases && chown vagrant:vagrant /home/vagrant/.bash_aliases"
    
    config.vm.post_up_message = "Devstead is up, wish you a pleasant development! https://github.com/measdot/devstead" 
end