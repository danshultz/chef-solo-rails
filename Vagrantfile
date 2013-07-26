# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

  name = "rails-server"
  config.vm.define(name) { |c|
    c.vm.hostname = "#{name}-vagrant"
    c.vm.box = 'precise64'
    c.vm.box_url = 'http://cloud-images.ubuntu.com/precise/current/precise-server-cloudimg-vagrant-amd64-disk1.box'
    c.vm.network(:private_network, :ip => "192.168.24.100")
    c.vm.network(:forwarded_port, :guest => 22, :host => 2299)
    c.ssh.forward_agent = true
  }

end
