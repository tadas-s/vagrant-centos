require 'yaml'

dir = File.dirname(File.expand_path(__FILE__))

settings = YAML.load_file("#{dir}/build_box.yaml")

Vagrant.configure("2") do |config|
  config.vm.box      = "#{settings['VAGRANT_BOX_NAME']}-intermediate"
  config.vm.hostname = "#{settings['HOSTNAME']}"

  config.vm.network :private_network, ip: "10.1.1.10"

  config.vm.provider :virtualbox do |v|
    v.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
    v.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
    v.customize ["modifyvm", :id, "--memory", 1024]
    v.customize ["modifyvm", :id, "--cpus"  , 1]
  end

  config.vm.provision 'puppet' do |puppet|
    puppet.manifest_file = 'box.pp'
    puppet.manifests_path = 'puppet/manifests'
    puppet.module_path = 'puppet/modules'
    puppet.options = '--verbose --hiera_config /vagrant/puppet/hiera.yaml'
  end
end
