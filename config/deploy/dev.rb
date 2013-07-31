ssh_options[:paranoid] = false
set(:deploy_via, :copy)
set(:chef_base_path, '/vagrant')

role(:rails_server, "192.168.24.100")
role(:app, "192.168.24.100")
role(:web, "192.168.24.100")
role(:db, "192.168.24.100", :primary => true)
