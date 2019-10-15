#!/usr/bin/env bash


set -e

pacstrap /mnt base base-devel linux btrfs-progs snapper \
zsh mlocate htop net-tools wireless_tools wpa_supplicant \
dialog nano sudo intel-ucode grub bash-completion git \
ansible efibootmgr yay neofetch zsh-completion

genfstab -L -p /mnt > /mnt/etc/fstab

cp ./grub.conf /mnt/etc/default/grub

UUID=$(cryptsetup status /dev/mapper/archlinux | grep device)
UUID=$(echo ${UUID:9})
UUID=$(cryptsetup luksUUID "$UUID")

echo "GRUB_CMDLINE_LINUX=cryptdevice=UUID=$UUID:archlinux:allow-discards" >> /mnt/etc/default/grub

cp ./mkinitcpio.conf /mnt/etc/mkinitcpio.conf

arch-chroot /mnt grub-install --efi-directory=/boot --target=x86_64-efi --bootloader-id=boot
arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg

arch-chroot /mnt mkinitcpio -P
