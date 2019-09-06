class Devstead
  def self.configure(config, settings, secrets)
    script_dir                = File.dirname(__FILE__)
    config.ssh.forward_agent  = true
    config.vm.box             = settings['box'] ||= 'laravel/homestead'
    config.vm.hostname        = settings['hostname'] ||= 'devstead'
    config.vm.provider 'virtualbox' do |vb|
      vb.name = settings['name'] ||= 'Devstead'
      vb.customize ['modifyvm', :id, '--memory', settings['memory'] ||= '2048']
      vb.customize ['modifyvm', :id, '--cpus', settings['cpus'] ||= '1']
      vb.customize ['modifyvm', :id, '--natdnsproxy1', 'on']
      vb.customize ['modifyvm', :id, '--natdnshostresolver1', settings['natdnshostresolver'] ||= 'on']
      vb.customize ['modifyvm', :id, '--ostype', 'Ubuntu_64']
    end

    # ---- I / VIII ---- Setup private nerwork ip
    if settings.include? 'ip'
      config.vm.network :private_network, ip: settings['ip'] ||= '192.168.10.10'
    else
      config.vm.network :private_network, ip: '0.0.0.0', auto_network: true
    end
    
    # ---- II / VIII --- Forward default guest ports to host
    {80=> 8000, 443=> 44300, 3306=> 33060}.each do |guest, host|
      config.vm.network 'forwarded_port', guest: guest, host: host, auto_correct: true
    end

    # ---- III / VIII -- Destroy exisitng secrets and insert new
    config.vm.provision 'shell', inline: "sed -i '/# Devstead secret/,+1d' /home/vagrant/.profile", name: "destroy secrets"
    secrets.each do |secret|
        config.vm.provision 'shell' do |s|
            s.inline = "echo \"\n# Devstead secret\nexport DEVSTEAD_$1=\'$2\'\" >> /home/vagrant/.profile"
            s.args = [secret['key'], secret['value']]
        end
    end

    # ---- IV / VIII --- Configure public key for SSH access
    if settings.include? 'authorize'
      if File.exist? File.expand_path(settings['authorize'])
        config.vm.provision 'shell' do |s|
          s.inline = "echo $1 | grep -xq \"$1\" /home/vagrant/.ssh/authorized_keys || echo \"\n$1\" | tee -a /home/vagrant/.ssh/authorized_keys"
          s.args = [File.read(File.expand_path(settings['authorize']))]
        end
      end
    end

    # ---- V / VIII ---- Copy SSH private keys to the box
    if settings.include? 'keys'
      if settings['keys'].to_s.length.zero?
        puts 'Check your Devstead.yaml file, you have no private key(s) specified.'
        exit
      end
      settings['keys'].each do |key|
        if File.exist? File.expand_path(key)
          config.vm.provision 'shell' do |s|
            s.privileged = false
            s.inline = "echo \"$1\" > /home/vagrant/.ssh/$2 && chmod 600 /home/vagrant/.ssh/$2"
            s.args = [File.read(File.expand_path(key)), key.split('/').last]
          end
        else
          puts 'Check your Devstead.yaml file, the path to your private key does not exist.'
          exit
        end
      end
    end

    # ---- VI / VIII --- Copy user files over to VM
    if settings.include? 'copy'
      settings['copy'].each do |file|
        config.vm.provision 'file' do |f|
          f.source = File.expand_path(file['from'])
          f.destination = file['to'].chomp('/') + '/' + file['from'].split('/').last
        end
      end
    end

    # ---- VII / VIII -- Register shared folders
    if settings.include? 'folders'
      settings['folders'].each do |folder|
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

    # ---- VIII / VIII - Install opt-in toolkits
    if settings.has_key?('toolkits')
      settings['toolkits'].each do |toolkit|
        name = toolkit.keys[0]
        enabled = toolkit[name]
        path = script_dir + "/provision/toolkits/" + name + ".sh"

        # Check for boolean parameters
        if enabled == false
          config.vm.provision "shell", inline: "echo Ignoring toolkit: #{name} because it is set to false \n"
        elsif enabled == true          
          # Check if toolkit really exists
          if !File.exist? File.expand_path(path)
            config.vm.provision "shell", inline: "echo Invalid toolkit: #{name} \n"
          else
          # install toolkit
          config.vm.provision "shell" do |s|
              s.name = "Install toolkit " + name
              s.path = path
            end
          end
        end
      end
    end
  end
end