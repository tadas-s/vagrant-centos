#!/bin/bash

. ./functions.sh

# Read configuration variable file if it is present
[ -r "./settings.conf" ] && . ./settings.conf

UNIQ=`date | sha1sum | cut -c 1-7`
ISO=`find ./iso/CentOS* | head -n1`
GUEST_ISO="./iso/VBoxGuestAdditions.iso"

VMS_ROOT="${HOME}/VirtualBox VMs"
VM="CentOS-`echo ${ISO} | cut -d "-" -f 2-3`-${UNIQ}"
VM_HDD="${VMS_ROOT}/${VM}/${VM}"
VM_HDD_FILE="${VM_HDD}.vdi"

# Some config variables require rewriting / resolving
if [ ${ENABLE_EPEL_REPOSITORY} == "1" ]; then
    ENABLE_EPEL_REPOSITORY="repo --name=epel --baseurl=http://download.fedoraproject.org/pub/epel/6/x86_64"
else
    ENABLE_EPEL_REPOSITORY=""
fi

if [ ${ENABLE_IUS_REPOSITORY} == "1" ]; then
    ENABLE_IUS_REPOSITORY="repo --name=ius  --baseurl=http://dl.iuscommunity.org/pub/ius/stable/CentOS/6/x86_64"
else
    ENABLE_IUS_REPOSITORY=""
fi

if [ -z ${PROXY} ]; then
    PROXY=""
else
    PROXY=" proxy=\"${PROXY}\" "
fi

shout "Setting up"

# Some dependency checks
directory_exists "${VMS_ROOT}" "Cannot find VirtualBox VM directory ${VMS_ROOT}"
file_exists "${ISO}" "Cannot find CentOS iso ${ISO}"
file_exists "${GUEST_ISO}" "Cannot find VirtualBox guest extensions iso ${GUEST_ISO}"
is_runnable "vboxmanage --version" "Cannot find/run vboxmanage"
is_runnable "mkisofs --help" "Cannot find/run mkisofs"
is_runnable "7z -?" "Cannot find/run 7z"
is_runnable "vagrant --version" "Cannot find/run vagrant"

mkdir "./tmp/"
mkdir "./tmp/${VM}"

shout "Extracting ${ISO}"

7z x -o"./tmp/${VM}" "${ISO}"

shout "Copying configuration"

render_template ./centos.ks.template > ./tmp/${VM}/ks.cfg
render_template ./isolinux.cfg.template > ./tmp/${VM}/isolinux/isolinux.cfg

shout "Building custom iso"

mkisofs -o ./${VM}-ks.iso \
        -b isolinux/isolinux.bin \
        -c isolinux/boot.cat \
        -no-emul-boot \
        -boot-load-size 4 \
        -boot-info-table \
        -J -R \
        -V "${VM}" \
        ./tmp/${VM}/

shout "Cleanup"

rm -rf ./tmp/

shout "Booting VM to start install"

ISO="./${VM}-ks.iso"
VBoxManage -v &> /dev/null || { echo "ERROR: VBoxManage not in path!"; exit 1; }
VBoxManage createvm --name "${VM}" --register
VBoxManage modifyvm "${VM}" --ostype RedHat_64 --memory 1024 --vram 12 --rtcuseutc on --ioapic on
VBoxManage storagectl "${VM}" --name ide0 --add ide
VBoxManage storageattach "${VM}" --storagectl ide0 --device 0 --port 0 --type dvddrive --medium "${ISO}"
VBoxManage storageattach "${VM}" --storagectl ide0 --device 0 --port 1 --type dvddrive --medium "${GUEST_ISO}"
VBoxManage storagectl "${VM}" --name sata0 --add sata --portcount 1
VBoxManage createhd --filename "${VM_HDD_FILE}" --size 40960
VBoxManage storageattach "${VM}" --storagectl sata0 --port 0 --type hdd --medium "${VM_HDD_FILE}"
VBoxManage modifyvm "${VM}" --nic1 nat
VBoxManage startvm --type=headless "${VM}"

shout "Will now wait until it's finished"

wait_vm_quit "${VM}"

rm "${ISO}"

shout "Packaging Vagrant box to '${VM}.box'"

vagrant package --base "$VM" --output "${VM}.box"

VBoxManage unregistervm "$VM" --delete

shout "And we're done. Box file: ${VM}.box"
