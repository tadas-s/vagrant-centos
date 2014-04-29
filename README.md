# Build your own CentOS base box for Vagrant

## Disclaimer

This is work in progress and is bit specific for my setup.

## Requirements

* iso tools (mkisofs)
* 7zip (extracting iso)
* VirtualBox
* Vagrant (well why are you here?)

## Running

1. Download CentOS 6.5 (might work on bit lower versions, haven't tried) and suitable VirtualBox guest extensions iso
2. Put both iso files to ./iso
3. ./vagrant-centos.sh
4. Get a coffee, this will take a while. No interaction should be required (it's a kickstart install) unless there's an error.
5. This should produce CentOS-6.5-x86_64-*-ks.box file
