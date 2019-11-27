#!/usr/bin/env bash

rm -rf ~/build
mkdir ~/build
cd ~/build

asp update linux
asp export linux

cd linux

wget https://raw.githubusercontent.com/herobrauni/scripts/master/vars.patch
wget https://raw.githubusercontent.com/herobrauni/scripts/master/quirks.patch
wget https://raw.githubusercontent.com/herobrauni/scripts/master/pci.patch


# change PKGBUILD to include vars.patch

sed 's/pkgbase=linux/pkgbase=linux-custom/' PKGBUILD >> PKGBUILD-custom
mv PKGBUILD PKGBUILD.bak
mv PKGBUILD-custom PKGBUILD
sed 's/the main kernel config file/the main kernel config file\n  vars.patch\n  quirks.patch\n  pci.patch/' PKGBUILD >> PKGBUILD-custom
mv PKGBUILD-custom PKGBUILD

updpkgsums

export MAKEFLAGS="-j$(nproc)"
MAKEFLAGS="-j$(nproc)"

makepkg -s

sudo pacman -U linux-custom*

sudo grub-mkconfig -o /boot/grub/grub.cfg

echo "DONE"
