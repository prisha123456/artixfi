#! /bin/bash
echo welcome to my Artix Install Script
read -p "What Is Your Name " NAME
echo "Hello $NAME "
lsblk
read -p "What Disk Do You Want To Use $NAME.(eg. /dev/sda)" DISK
parted -a optimal $DISK --script mklabel gpt
parted $DISK --script mkpart primary 1MiB 512MiB
parted $DISK --script name 1 boot
parted $DISK --script mkpart primary 3MiB 28610MiB
parted $DISK --script name 2 rootfs
parted $DISK --script mkpart primary 28610MiB -1
parted $DISK --script name 3 homefs
parted $disk_chk --script set 1 boot on
part_1=("${DISK}1")
part_2=("${DISK}2")
part_3=("${DISK}3")
mkfs.fat -F 32 $part_1
mkfs.ext4 $part_2
mkfs.ext4 $part_3
mkdir /mnt
mkdir /mnt/boot
mkdir /mnt/home
mount $part_2 /mnt
mount $part_1 /mnt/boot
mount $part_3 /mnt/home
basestrap /mnt base base-devel openrc linux linux-firmware
fstabgen -U /mnt >> /mnt/etc/fstab
artix-chroot /mnt 
read -p "What Is Your TimeZone $NAME (eg. Asia/Kolkata for India) " TIME
ln -sf /usr/share/zoneinfo/$TIME /etc/localtime
hwclock --systohc
cd /etc
uncomment 14 locale.gen 
locale-gen
export LANG="en_US.UTF-8"
export LC_COLLATE="C"
pacman -S grub os-prober efibootmgr dhcpcd connman-openrc connman-gtk
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=grub
grub-mkconfig -o /boot/grub/grub.cfg
read -p "What Is Going To Be Your Username $NAME " USER
useradd -m $USER
passwd $USER
usermod -aG wheel,audio,video,optical.storage $USER
read -p "What Do You Want Your Hostname To Be $NAME " HOSTNAME
rc-update add connmand
touch /etc/hostname
echo "$HOSTNAME" > /etc/hostname
