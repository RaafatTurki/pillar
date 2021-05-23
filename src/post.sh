# Genfstab
genfstab -U /mnt >> /mnt/etc/fstab

# Setting pacman config and mirrorlist
cp -f /etc/pacman.d/mirrorlist /mnt/etc/pacman.d/mirrorlist
cp -f ./assets/pacman.conf /mnt/etc/pacman.conf

# Setting automatic username entry on tty1
cp -R ./assets/getty@tty1.service.d /etc/systemd/system/

# Setting tearfree nvidia xorg configs
if $ok_nvidia ;then
  mkdir -p /etc/X11/xorg.conf.d
  cp -f ./assets/20-nvidia.conf /etc/X11/xorg.conf.d/
fi


# Archroot
cat << EOF | arch-chroot /mnt

# Pacman
pacman -Sy
if $ok_pkgfile ;then
  pkgfile -u
fi

# Timezone
ln -sf /usr/share/zoneinfo/$timezone /etc/localtime
hwclock --systohc

# Hostname
echo $hostname > /etc/hostname

# Locale
sed -i 's/#\(en_US\.UTF-8\)/\1/' /etc/locale.gen
locale-gen
echo LANG=en_US.UTF-8 > /etc/locale.conf

# Network
echo 127.0.0.1  localhost >> /etc/hosts
echo ::1        localhost >> /etc/hosts
echo 127.0.0.1  $hostname.localdomain $hostname >> /etc/hosts

# Issue
touch /etc/issue
echo :D > /etc/issue

# Services
systemctl enable NetworkManager.service
systemctl enable systemd-timesyncd.service
systemctl enable avahi-daemon.service
systemctl enable paccache.timer
# systemctl enable systemd-homed.service

# Grub
if $uefi ;then
    grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=BOOT
else
    root_disk=`mount | grep " /mnt " | cut -d " " -f 1 | sed "s/.$//"`
    grub-install --target=i386-pc /dev/$root_disk
fi
sed -i "s/GRUB_TIMEOUT=1/GRUB_TIMEOUT=2/" /etc/default/grub
sed -i "s/#GRUB_GFXMODE=auto/GRUB_GFXMODE=1920x1080x32/" /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg

# User
useradd $username -m -G wheel

# AUR helper
sed -i "s/# \(%wheel ALL=(ALL) NOPASSWD: ALL\)/\1/" /etc/sudoers
su $username -c "cd /tmp && git clone https://aur.archlinux.org/yay-bin.git && cd ./yay-bin && makepkg -si --noconfirm"
sed -i 's/\(%wheel ALL=(ALL) NOPASSWD: ALL\)/# \1/' /etc/sudoers

# Permit wheel group
if $ok_doas ;then
  pacman -Rscn --noconfirm sudo
  if $ok_nopass ;then
    echo permit :wheel > /etc/doas.conf
  else
    echo permit nopass :wheel > /etc/doas.conf
  fi
  ln -s /usr/bin/doas /usr/bin/sudo
else
  if $ok_nopass ;then
    sed -i "s/# \(%wheel ALL=(ALL) NOPASSWD: ALL\)/\1/" /etc/sudoers
  else
    sed -i "s/# \(%wheel ALL=(ALL) ALL\)/\1/" /etc/sudoers
  fi
fi

EOF
