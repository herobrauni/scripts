#!/usr/bin/env bash


set -e

pacstrap /mnt base base-devel linux btrfs-progs snapper \
zsh mlocate htop net-tools wireless_tools wpa_supplicant \
dialog nano sudo intel-ucode grub bash-completion git \
ansible

genfstab -L -p /mnt >> /mnt/etc/fstab

echo "KEYMAP=de" > /mnt/etc/vconsole.conf

cp ./grub.conf /mnt/etc/default/grub


UUID=$(cryptsetup status /dev/mapper/archlinux | grep device)
UUID=$(echo ${UUID:9})
UUID=$(cryptsetup luksUUID "$UUID")

echo "GRUB_CMDLINE_LINUX=cryptdevice=UUID=$UUID:archlinux:allow-discards"