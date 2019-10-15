#!/usr/bin/env bash
# install base programs

set -e

pacstrap /mnt base base-devel linux btrfs-progs snapper \
zsh mlocate htop net-tools wireless_tools wpa_supplicant \
dialog nano sudo intel-ucode grub bash-completion git \
ansible

genfstab -L -p /mnt >> /mnt/etc/fstab
