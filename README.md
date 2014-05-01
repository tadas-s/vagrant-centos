# Build your own CentOS base box for Vagrant

## Disclaimer

This is work in progress.

## Goodies

* No interaction required - installs from custom built iso image with kickstart file
* Customize time zone, locale, keyboard layout via simple configuration file
* Pick mirror, enable or disble EPEL and IUS repositories via configuration file
* Also supports installs via proxy. Reason? I have an awesome Raspberry Pi proxy server in the corner that caches rpm / deb / similar package for quick VM provisioning
* Select base pacakge set via configuration file

## Issues

* Script is bit optimistic. So in case of any issues it might not be very informative

## Requirements

* iso tools (mkisofs)
* 7zip (extracting iso)
* VirtualBox
* Vagrant (well why are you here?)

## Running

1. Download CentOS 6.5 (might work on bit lower versions, haven't tried) and suitable VirtualBox guest extensions iso
2. Put both iso files to ./iso
3. Take a peek at settings.conf file
4. ./vagrant-centos.sh
5. Get a coffee, this will take a while. No interaction should be required (it's a kickstart install) unless there's an error
6. This should produce CentOS-6.5-x86_64-*.box file

## Adding and using the box

To use it locally (assuming your project has config.vm.box = "centos65" in Vagrantfile):

```
vagrant add ./CentOS-6.5-x86_64-33cdcaa.box --name centos65 --force
cd ../your/project
vagrant destroy
vagrant up
```

This project also has a sample Vagrantfile for test-driving newly built images, so you can simply run:

```
vagrant add ./CentOS-6.5-x86_64-33cdcaa.box --name centos65 --force
vagrant destroy
vagrant up
vagrant ssh # to look around what's in the box
```

(note that "33cdcaa" part is unique to build so it will be something different)

## Credits

Forked from and inspired by [github.com/astrostl/vagrant-centos](http://github.com/astrostl/vagrant-centos).

