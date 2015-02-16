# Basic Vagranfile to test a newly built box

Vagrant.configure("2") do |config|
  config.vm.box      = "centos66"
  config.vm.hostname = "centos66"

  config.vm.network :private_network, ip: "10.1.1.10"

  config.vm.provider :virtualbox do |v|
    v.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
    v.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
    v.customize ["modifyvm", :id, "--memory", 1024]
    v.customize ["modifyvm", :id, "--cpus"  , 1]
  end
end
