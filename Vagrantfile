# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'yaml'

rootDir                 = File.expand_path(File.dirname(__FILE__))
afterShPath             = rootDir + '/Provision/after.sh'
aliasesPath             = rootDir + '/Provision/aliases'
devsteadYamlPath        = rootDir + '/Provision/devstead.yaml'
userCustomizationsShPath= rootDir + '/Provision/user-customizations.sh'
homesteadClass          = rootDir + '/Basebox/Homestead.rb'
dotDevSteadFiles        = rootDir + '/Resources/.devstead'
credentialsYamlPath     = rootDir + '/_credentials.yaml'

Vagrant.require_version '>= 2.2.4'
Vagrant.configure(2) do |config|
    # Abort if developer credentials are not found
    if File.exist? credentialsYamlPath then
        credentials = YAML::load(File.read(credentialsYamlPath))

        # Abort if devstead configuration yaml file is not found
        if File.exist? devsteadYamlPath then
            devsteadConf = YAML::load(File.read(devsteadYamlPath))

            #1. Build Basebox(Homestead) and configure with Devstead conf
            require homesteadClass
            Homestead.configure(config, devsteadConf)
            
            #2. Put custom regular Aliases to the machine's bash console
            if File.exist? aliasesPath then
                config.vm.provision "file", source: aliasesPath, destination: "/tmp/bash_aliases"
                config.vm.provision "shell" do |s|
                    s.inline = "awk '{ sub(\"\r$\", \"\"); print }' /tmp/bash_aliases > /home/vagrant/.bash_aliases && chown vagrant:vagrant /home/vagrant/.bash_aliases"
                end
            end

            #3. Customize users, groups and directory ownerships of machine as per org standards  
            if File.exist? userCustomizationsShPath then
                config.vm.provision "shell", path: userCustomizationsShPath,
                name: "Customize users, groups and directory ownerships of machine as per org standards",
                :args=>[
                    credentials['DEV_FULL_NAME'],
                    credentials['DEV_EMAIL'],
                    credentials['SERVERS_DEFAULT_USER']
                ]
            end

            #4. Install important softwares, configure box initialization and regular updates
            if File.exist? afterShPath then
                config.vm.provision "shell", path: afterShPath, privileged: false,
                name: "Install important softwares, configure box initialization and regular updates",
                :args=>[
                    credentials['VC_USER'],
                    credentials['VC_PASS'],
                ]
            end

        else
            abort "Devstead conf yaml file not found in #{rootDir}"
        end
    else
        abort "Credentials yaml file not found in #{rootDir}"
    end

    # Build success message
    config.vm.post_up_message = <<MSG
    -------------------------------------------------------------
    Build complete, Wish you a merrier development !
    - SSH Login
        User        : vagrant
        Ip          : 192.168.33.10

    - System
        CPU         : 2
        Memory      : 4096mb
    
    - Shared Directory
        Host        : ~/Projects  
        Guest       : ~/Projects
    
    - Features
        Softwares   : Git, PHP 7.0, Nginx, MySQL, Composer, 
                      Node (With PM2, Bower, Grunt, and Gulp), 
                      Redis, Memcached, Docker
        Github      : https://github.com/measdot/devstead 
    -------------------------------------------------------------
MSG


end
