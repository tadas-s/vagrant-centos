#!/bin/bash

UNIQ=`date | sha1sum | cut -c 1-7`
ISO=`find ./iso/CentOS* | head -n1`
GUEST_ISO="./iso/VBoxGuestAdditions.iso"

VMS_ROOT="${HOME}/VirtualBox VMs"
VM="CentOS-`echo ${ISO} | cut -d "-" -f 2-3`-${UNIQ}"
VM_HDD="${VMS_ROOT}/${VM}/${VM}"
VM_HDD_FILE="${VM_HDD}.vdi"

checkdir() { [[ ! -d "$1" ]] && { echo "ERROR: missing $1 dir!"; exit 1; } }
checkiso() { [[ ! -e "$1" ]] && { echo "ERROR: missing $1 file!"; exit 1; } }

wait_vm_quit() {
    echo "Waiting $1 to power-off"
    while [ `vboxmanage list runningvms | grep "$1" | wc -l` == "1" ]; do
        echo -n "."
        sleep 1
    done
    echo "...and it's gone"
}

checkdir "$HOME"
checkdir "$VMS_ROOT"
checkiso "$ISO"
checkiso "$GUEST_ISO"

echo "ISO: ${ISO}"
echo "Machine name: ${VM}"

mkdir "./tmp/"
mkdir "./tmp/${VM}"
7z x -o"./tmp/${VM}" "${ISO}"

cp ./vagrant-centos-min.ks ./tmp/${VM}/ks.cfg
cp ./isolinux.cfg ./tmp/${VM}/isolinux/isolinux.cfg

mkisofs -o ./${VM}-ks.iso \
        -b isolinux/isolinux.bin \
        -c isolinux/boot.cat \
        -no-emul-boot \
        -boot-load-size 4 \
        -boot-info-table \
        -J -R \
        -V "${VM}" \
        ./tmp/${VM}/

rm -rf ./tmp/

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
VBoxManage startvm "${VM}"

wait_vm_quit "${VM}"

rm "${ISO}"

vagrant package --base "$VM" --output "${VM}.box"

VBoxManage unregistervm "$VM" --delete
