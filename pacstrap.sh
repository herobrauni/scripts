#!/usr/bin/env bash

set -e

pacstrap /mnt base base-devel linux btrfs-progs snapper \
zsh mlocate htop net-tools wireless_tools wpa_supplicant \
dialog nano sudo intel-ucode grub bash-completion git \
ansible efibootmgr yay neofetch zsh-completions \
ripgrep fd bat diskus pdfpc sl

#xfce + customizations

pacstrap /mnt xfce4 xfce4-goodies \
xdg-user-dirs xorg-server xorg-apps xorg-xinit xterm \
ttf-dejavu gvfs gvfs-smb gvfs-mtp \
pulseaudio pavucontrol pulseaudio-alsa alsa-utils unzip \
gvfs arc-gtk-theme elementary-icon-theme numix-icon-theme-git \
numix-circle-icon-theme-git htop lynx \
libreoffice-fresh vlc gnome-packagekit pantheon-music
# xcp
