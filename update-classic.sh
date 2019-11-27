#!/usr/bin/env bash

VERS=$1

rm -rf ~/build
mkdir ~/build
cd ~/build

wget https://www.kernel.org/pub/linux/kernel/v5.x/linux-${VERS}.tar.xz
tar -xvJf linux-${VERS}.tar.xz

cd linux-${VERS}

echo "EXTRACTION DONE"
read -p "Press enter to continue"

make mrproper

wget "https://git.archlinux.org/svntogit/packages.git/plain/trunk/config?h=packages/linux" -O .config
wget https://raw.githubusercontent.com/herobrauni/scripts/master/vars.patch
wget https://raw.githubusercontent.com/herobrauni/scripts/master/quirks.patch
# wget https://raw.githubusercontent.com/herobrauni/scripts/master/pci.patch
wget https://raw.githubusercontent.com/herobrauni/scripts/master/dcn20_hwseq.patch

echo "DOWNLOADS DONE"

read -p "Press enter to continue"

echo "PATCHES"

for i in ./*.patch; do patch -p1 < $i; done

echo "PATCHES DONE"

read -p "Press enter to continue"

unset CORES
declare -i CORES
CORES="$(nproc) + 1"

echo "MAKING WITH $CORES CORES"

make -j$CORES

echo "MAKE COMPLETE - SWITCH TO SUDO"

read -p "Press enter to continue"

sudo make modules_install

echo "MODULES DONE - COPY MKINITCPIO GRUB"

read -p "Press enter to continue"

sudo cp -v arch/x86_64/boot/bzImage /boot/vmlinuz-linux-custom
sudo mkinitcpio -P
sudo grub-mkconfig -o /boot/grub/grub.cfg

echo "DONE"
