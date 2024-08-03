#!/bin/bash

sudo umount /boot
sudo mkdir /efi
sudo mount /dev/sdd1 /efi
sudo rm -rf /efi/*
paru -S linux-cachyos linux-cachyos-headers linux-cachyos-nvidia amd-ucode intel-ucode
sudo cp ./linux-cachyos.preset /etc/mkinitcpio.d/
sudo bootctl install
paru -S sbctl
sudo sed -i 's/boot/efi/g' /etc/fstab
sudo sed -i 's/ defaults / defaults,umask=0077 /g' /etc/fstab

