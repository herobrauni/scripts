#!/usr/bin/env bash

# Formats DRIVE into boot /dev/sdX1, LUKS encrypts /dev/sdX2
# sets up btrfs with subvolumes on /dev/sdX2

set -e

DRIVE=$1
SWAPSIZE=$2

echo "HDD $DRIVE"
sleep 30
echo "Formating"

if (mount | grep /mnt); then
    umount -l /mnt
fi
sgdisk --zap-all "$DRIVE"

echo -e "n\n\n\n512M\nef00\nn\n\n\n\n\nw\ny" | gdisk "$DRIVE" &> /dev/null

BOOT="${DRIVE}1"
ROOT="${DRIVE}2"

echo "Formating Boot as fat32"
wipefs -a "$BOOT"
mkfs.vfat -F32 "$BOOT"

echo "Encrypting ROOT"  
cryptsetup luksFormat "$ROOT"
cryptsetup open "$ROOT" archlinux

ROOT="/dev/mapper/archlinux"



echo "Formating Root as btrfs"
wipefs -a "$ROOT"
mkfs.btrfs -L archlinux "$ROOT"

echo "Create Subvols"
mount -t btrfs -o compress=lzo "$ROOT" /mnt
btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@home
btrfs subvolume create /mnt/@snapshots
btrfs subvolume create /mnt/@homeshots
btrfs subvolume create /mnt/@swap

umount /mnt

echo "Mounting @"
mount -o subvol=@,ssd,compress=lzo,discard "$ROOT" /mnt
mkdir /mnt/{home,swap,.snapshots,boot}

echo "Mounting Subvols"
mount -o subvol=@home,ssd,compress=lzo,discard "$ROOT" /mnt/home
mount -o subvol=@swap,ssd,compress=lzo,discard "$ROOT" /mnt/swap
mount -o subvol=@snapshots,ssd,compress=lzo,discard "$ROOT" /mnt/.snapshots
mkdir /mnt/home/.snapshots
mount -o subvol=@homeshots,ssd,compress=lzo,discard "$ROOT" /mnt/home/.snapshots

echo "Create SWAP"
truncate -s 0 /mnt/swap/swapfile
chattr +C /mnt/swap/swapfile
dd if=/dev/zero of=/mnt/swap/swapfile bs=1M count="$SWAPSIZE" status=progress
chmod 600 /mnt/swap/swapfile
mkswap /mnt/swap/swapfile
swapon /mnt/swap/swapfile

echo "Mount boot"
mount "$BOOT" /mnt/boot

echo "DONE!"
