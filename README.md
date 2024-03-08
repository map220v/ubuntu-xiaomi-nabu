# Ubuntu for Xiaomi Pad 5
This repo contians scripts for automatic building of ubuntu rootfs and kernel for Xiaomi Pad 5

# Where do i get needed files?
Actually just go to the "Actions" tab, find one of latest builds and download file named **rootfs_(Desktop Environment you want)_(Kernel version you want)** 
<br>for update download file named **xiaomi-nabu-debs_(Kernel version you want)**

# Update info
- Unpack .zip you downloaded
- Run dpkg -i *-xiaomi-nabu.deb
- P.S. if you moving to another kernel version make that after installing .deb's
  <br>**First method**: just replace your old kernel version with new kernel version in /boot/grub/grub.cfg
  <br>**Second method**: grub-install and grub-mkconfig -o /boot/grub/grub.cfg

# Install info
- Unpack .zip you downloaded
- Unpack extracted .7z (there you take rootfs.img)
- rootfs.img must be flashed to partition named "linux"
- Partition for efi boot must be named "esp"
- Install grub using grub-install and grub-mkconfig -o /boot/grub/grub.cfg. If done from android make sure that efs partition mounted at /boot/efi, after generating grub.cfg change all of "/dev/block/" to "/dev/"
