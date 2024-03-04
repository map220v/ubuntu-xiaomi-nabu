# Ubuntu rootfs for Xiaomi Pad 5
This repo contians scripts for automatic building of ubuntu rootfs for Xiaomi Pad 5

# Install info
- rootfs.img must be flashed to partition named "linux"
- Partition for efi boot must be named "esp"
- Install grub using grub-install and grub-mkconfig -o /boot/grub/grub.cfg. If done from android make sure that efs partition mounted at /boot/efi, after generating grub.cfg change all of "/dev/block/" to "/dev/"
