#!/usr/bin/env bash


set -e

pacstrap /mnt base base-devel linux btrfs-progs snapper \
zsh mlocate htop net-tools wireless_tools wpa_supplicant \
dialog nano sudo intel-ucode grub bash-completion git \
ansible efibootmgr yay neofetch zsh-completions \
ripgrep fd xcp bat diskus pdfpc sl
