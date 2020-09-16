# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'yaml'

rootDir     = File.expand_path(File.dirname(__FILE__))
vmConfYaml  = rootDir + '/VMConf.yaml'
vmConf      = YAML::load(File.read(vmConfYaml))

Vagrant.require_version '>= 2.2.10'
Vagrant.configure(2) do |config| 

    # Configure and bring up the VM
    config.ssh.forward_agent  = true
    config.vm.box             = vmConf['box'] ||= 'laravel/homestead'
    config.vm.hostname        = vmConf['hostname'] ||= 'devstead'
    config.vm.provider 'virtualbox' do |vb|
      vb.name = vmConf['name'] ||= 'Devstead'
      vb.customize ['modifyvm', :id, '--memory', vmConf['memory'] ||= '2048']
      vb.customize ['modifyvm', :id, '--cpus', vmConf['cpus'] ||= '1']
      vb.customize ['modifyvm', :id, '--natdnsproxy1', 'on']
      vb.customize ['modifyvm', :id, '--natdnshostresolver1', vmConf['natdnshostresolver'] ||= 'on']
      vb.customize ['modifyvm', :id, '--ostype', 'Ubuntu_64']
    end

    # ---- I / VI ---- Setup private nerwork ip
    if vmConf.include? 'ip'
      config.vm.network :private_network, ip: vmConf['ip'] ||= '192.168.10.10'
    else
      config.vm.network :private_network, ip: '0.0.0.0', auto_network: true
    end
    
    # ---- III / VI --- Configure public key for SSH access
    config.vm.provision "file", source: "~/.ssh/id_rsa", destination: "~/.ssh/me"
    config.vm.provision "file", source: "~/.ssh/id_rsa.pub", destination: "~/.ssh/me.pub"
    config.vm.provision "shell", inline: "cat /home/vagrant/.ssh/me.pub >> /home/vagrant/.ssh/authorized_keys"

    # ---- IV / VI --- Copy user files over to VM
    if vmConf.include? 'copy'
      vmConf['copy'].each do |file|
        config.vm.provision 'file' do |f|
          f.source = File.expand_path(file['from'])
          f.destination = file['to'].chomp('/') + '/' + file['from'].split('/').last
        end
      end
    end

    # ---- V / VI -- Register shared folders
    if vmConf.include? 'folders'
      vmConf['folders'].each do |folder|
        if File.exist? File.expand_path(folder['map'])
          mount_opts = []

          if folder['type'] == 'nfs'
            mount_opts = folder['mount_options'] ? folder['mount_options'] : ['actimeo=1', 'nolock']
          elsif folder['type'] == 'smb'
            mount_opts = folder['mount_options'] ? folder['mount_options'] : ['vers=3.02', 'mfsymlinks']

            smb_creds = {smb_host: folder['smb_host'], smb_username: folder['smb_username'], smb_password: folder['smb_password']}
          end

          # For b/w compatibility keep separate 'mount_opts', but merge with options
          options = (folder['options'] || {}).merge({ mount_options: mount_opts }).merge(smb_creds || {})

          # Double-splat (**) operator only works with symbol keys, so convert
          options.keys.each{|k| options[k.to_sym] = options.delete(k) }

          config.vm.synced_folder folder['map'], folder['to'], type: folder['type'] ||= nil, **options

          # Bindfs support to fix shared folder (NFS) permission issue on Mac
          if folder['type'] == 'nfs' && Vagrant.has_plugin?('vagrant-bindfs')
            config.bindfs.bind_folder folder['to'], folder['to']
          end
        else
          config.vm.provision 'shell' do |s|
            s.inline = ">&2 echo \"Unable to mount one of your folders. Please check your folders in Devstead.yaml\""
          end
        end
      end
    end

    # ---- VI / VI -- Provision features
    config.vm.provision "ansible" do |ansible|
        ansible.playbook = "features/playbook.yml"
    end
    
    config.vm.post_up_message = "Devstead is up, wish you a pleasant development! https://github.com/measdot/devstead" 
end