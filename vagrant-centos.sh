#!/bin/bash

vc_osiso=`find ./iso/CentOS* | head -n1`
vc_guestiso="./iso/VBoxGuestAdditions.iso"

vc_vboxbase="${HOME}/VirtualBox VMs"
vc_basebox="CentOS-`echo ${vc_osiso} | cut -d "-" -f 2-3`"
vc_hddbase="${vc_vboxbase}/${vc_basebox}/${vc_basebox}"
vc_hddfile="${vc_hddbase}.vdi"

checkdir() { [[ ! -d "$1" ]] && { echo "ERROR: missing $1 dir!"; exit 1; } }
checkiso() { [[ ! -e "$1" ]] && { echo "ERROR: missing $1 file!"; exit 1; } }

checkdir "$HOME"
checkdir "$vc_vboxbase"
checkiso "$vc_osiso"
checkiso "$vc_guestiso"

echo "ISO: ${vc_osiso}"
echo "Machine name: ${vc_basebox}"

mkdir "./tmp/"
mkdir "./tmp/${vc_basebox}"
7z x -o"./tmp/${vc_basebox}" "${vc_osiso}"

cp ./vagrant-centos-min.ks ./tmp/${vc_basebox}/ks.cfg
cp ./isolinux.cfg ./tmp/${vc_basebox}/isolinux/isolinux.cfg

mkisofs -o ./${vc_basebox}-ks.iso \
        -b isolinux/isolinux.bin \
        -c isolinux/boot.cat \
        -no-emul-boot \
        -boot-load-size 4 \
        -boot-info-table \
        -J -R \
        -V "${vc_basebox}" \
        ./tmp/${vc_basebox}/

rm -rf ./tmp/

vc_osiso="./${vc_basebox}-ks.iso"

VBoxManage -v &> /dev/null || { echo "ERROR: VBoxManage not in path!"; exit 1; }

VBoxManage createvm --name "$vc_basebox" --register
VBoxManage modifyvm "$vc_basebox" --ostype RedHat_64 --memory 1024 --vram 12 --rtcuseutc on --ioapic on
VBoxManage storagectl "$vc_basebox" --name ide0 --add ide
VBoxManage storageattach "$vc_basebox" --storagectl ide0 --device 0 --port 0 --type dvddrive --medium "$vc_osiso"
VBoxManage storageattach "$vc_basebox" --storagectl ide0 --device 0 --port 1 --type dvddrive --medium "$vc_guestiso"
VBoxManage storagectl "$vc_basebox" --name sata0 --add sata --portcount 1
VBoxManage createhd --filename "$vc_hddfile" --size 40960
VBoxManage storageattach "$vc_basebox" --storagectl sata0 --port 0 --type hdd --medium "$vc_hddfile"
VBoxManage modifyvm "$vc_basebox" --nic1 nat
VBoxManage startvm "$vc_basebox"

echo "Press ENTER when installation is complete and box has powered off"; read

vagrant package --base "$vc_basebox" --output "${vc_basebox}.box"

VBoxManage unregistervm "$vc_basebox" --delete
