#!/bin/sh

if [ "$(id -u)" -ne 0 ]
then
  echo "rootfs can only be built as root"
  exit
fi

VERSION="23.10"

truncate -s 6G rootfs.img
mkfs.ext4 rootfs.img
mkdir rootdir
mount -o loop rootfs.img rootdir

wget https://cdimage.ubuntu.com/ubuntu-base/releases/$VERSION/release/ubuntu-base-$VERSION-base-arm64.tar.gz
tar xzvf ubuntu-base-$VERSION-base-arm64.tar.gz -C rootdir
#rm ubuntu-base-$VERSION-base-arm64.tar.gz

mount --bind /dev rootdir/dev
mount --bind /dev/pts rootdir/dev/pts
mount --bind /proc rootdir/proc
mount --bind /sys rootdir/sys

echo "nameserver 1.1.1.1" | tee rootdir/etc/resolv.conf
echo "xiaomi-nabu" | tee rootdir/etc/hostname
echo "127.0.0.1 localhost
127.0.1.1 xiaomi-nabu" | tee rootdir/etc/hosts

if uname -m | grep -q aarch64
then
  echo "cancel qemu install for arm64"
else
  wget https://github.com/multiarch/qemu-user-static/releases/download/v7.2.0-1/qemu-aarch64-static
  install -m755 qemu-aarch64-static rootdir/

  echo ':aarch64:M::\x7fELF\x02\x01\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x02\x00\xb7:\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xfe\xff\xff:/qemu-aarch64-static:' | tee /proc/sys/fs/binfmt_misc/register
  #ldconfig.real abi=linux type=dynamic
  echo ':aarch64ld:M::\x7fELF\x02\x01\x01\x03\x00\x00\x00\x00\x00\x00\x00\x00\x03\x00\xb7:\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xfe\xff\xff:/qemu-aarch64-static:' | tee /proc/sys/fs/binfmt_misc/register
fi


#chroot installation
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:\$PATH
export DEBIAN_FRONTEND=noninteractive

chroot rootdir apt update
chroot rootdir apt upgrade -y

#u-boot-tools breaks grub installation
chroot rootdir apt install -y bash-completion sudo ssh nano u-boot-tools- $1

#chroot rootdir gsettings set org.gnome.shell.extensions.dash-to-dock show-mounts-only-mounted true



#Device specific
chroot rootdir apt install -y rmtfs protection-domain-mapper tqftpserv

#Remove check for "*-laptop"
sed -i '/ConditionKernelVersion/d' rootdir/lib/systemd/system/pd-mapper.service

cp /home/runner/work/ubuntu-xiaomi-nabu/ubuntu-xiaomi-nabu/xiaomi-nabu-debs_$2/*-xiaomi-nabu.deb rootdir/tmp/
chroot rootdir dpkg -i /tmp/linux-xiaomi-nabu.deb
chroot rootdir dpkg -i /tmp/firmware-xiaomi-nabu.deb
chroot rootdir dpkg -i /tmp/alsa-xiaomi-nabu.deb
rm rootdir/tmp/*-xiaomi-nabu.deb


#EFI
chroot rootdir apt install -y grub-efi-arm64

sed --in-place 's/^#GRUB_DISABLE_OS_PROBER=false/GRUB_DISABLE_OS_PROBER=false/' rootdir/etc/default/grub
sed --in-place 's/GRUB_CMDLINE_LINUX_DEFAULT="quiet splash"/GRUB_CMDLINE_LINUX_DEFAULT=""/' rootdir/etc/default/grub

#this done on device for now
#grub-install
#grub-mkconfig -o /boot/grub/grub.cfg

#create fstab!
echo "PARTLABEL=linux / ext4 errors=remount-ro,x-systemd.growfs 0 1
PARTLABEL=esp /boot/efi vfat umask=0077 0 1" | tee rootdir/etc/fstab

mkdir rootdir/var/lib/gdm
touch rootdir/var/lib/gdm/run-initial-setup

chroot rootdir apt clean

if uname -m | grep -q aarch64
then
  echo "cancel qemu install for arm64"
else
  #Remove qemu emu
  echo -1 | tee /proc/sys/fs/binfmt_misc/aarch64
  echo -1 | tee /proc/sys/fs/binfmt_misc/aarch64ld
  rm rootdir/qemu-aarch64-static
  rm qemu-aarch64-static
fi

umount rootdir/sys
umount rootdir/proc
umount rootdir/dev/pts
umount rootdir/dev
umount rootdir

rm -d rootdir

echo 'cmdline for legacy boot: "root=PARTLABEL=linux"'

7zz a rootfs.7z rootfs.img
