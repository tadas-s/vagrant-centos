# Basic Vagranfile to test a newly built box

VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  config.vm.box_url  = "CentOS-6.5-x86_64.box"
  config.vm.box      = "centos65"
  config.vm.hostname = "text-centos-65"

  config.vm.network :private_network, ip: "10.1.1.10"

  config.vm.provider :virtualbox do |v|
    v.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
    v.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
    v.customize ["modifyvm", :id, "--memory", 1024]
    v.customize ["modifyvm", :id, "--cpus"  , 1]
  end
end
