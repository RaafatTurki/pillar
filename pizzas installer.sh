#!/bin/bash

# -=-=-=- Init -=-=-=-
timedatectl set-ntp true
fdisk -l
# ask for user input

# -=-=-=- Partitioning -=-=-=-
cfdisk /dev/vda

# -=-=-=- Formatting -=-=-=-
mkfs.ext4 /dev/vda1

# -=-=-=- Mounting -=-=-=-
mount /dev/vda1 /mnt

# -=-=-=- Installing -=-=-=-
boot=​base-devel linux linux-firmware linux intel-ucode amd-ucode networkmanager
core=sysfsutils dos2unix sxhkd e2fsprogs nano less which man-db man-pages util-linux grub openssh dkms stow strace whois git entr beep htop neofetch usbutils tree
sound=alsa-utils pavucontrol pulseaudio pulseaudio-alsa
utils=tmux nano neovim
vbox=spice-vdagent qemu
fonts=adobe-source-code-pro-fonts adobe-source-han-sans-otc-fonts adobe-source-han-serif-otc-fonts noto-fonts noto-fonts-emoji noto-fonts-cjk noto-fonts-extra
games=gnome-mahjongg gnome-mines gnome-sudoku quadrapassel
gnome=baobab cheese eog evince file-roller gdm gedit gnome-backgrounds gnome-books gnome-boxes gnome-calculator gnome-calendar gnome-characters gnome-clocks gnome-color-manager gnome-contacts gnome-control-center gnome-dictionary gnome-disk-utility gnome-documents gnome-font-viewer gnome-keyring gnome-logs gnome-maps gnome-menus gnome-photos gnome-remote-desktop gnome-screenshot gnome-session gnome-settings-daemon gnome-shell gnome-shell-extensions gnome-system-monitor gnome-terminal gnome-themes-extra gnome-todo gnome-user-docs gnome-user-share gnome-video-effects gnome-weather grilo-plugins gvfs gvfs-afc gvfs-goa gvfs-google gvfs-gphoto2 gvfs-mtp gvfs-nfs gvfs-smb mousetweaks mutter nautilus networkmanager orca rygel simple-scan sushi totem tracker tracker-miners vino xdg-user-dirs-gtk yelp
gnomeextra=accerciser dconf-editor ghex gnome-chess gnome-code-assistance gnome-devel-docs gnome-nettool gnome-recipes gnome-sound-recorder gnome-tweaks gnome-usage nautilus-sendto polari drawing lollypop
apps=firefox firefox-ublock-origin firefox-dark-reader audacity kdenlive libreoffice-fresh
aur=yay pamac-aur ice-ssb qogir-gtk-theme-git ttf-ms-fonts qogir-kvantum-git

pacstrap /mnt $boot $core $sound $utils $vbox $gnome

# -=-=-=- PostInstall -=-=-=-
genfstab -U /mnt >> /mnt/etc/fstab

rm /mnt/etc/pacman.conf
cp pacman.conf.orig /mnt/etc/pacman.conf

usermod -R /mnt root -p password
usermod -R /mnt testuser -p password


# -=-=-=- Chroot -=-=-=-
cat << EOF | arch-chroot /mnt

#timezone
ln -sf /usr/share/zoneinfo/America/Los_Angeles /etc/localtime
hwclock --systohc

#locale
sed -i 's/#\(en_US\.UTF-8\)/\1/' /etc/locale.gen
locale-gen
echo LANG=en_US.UTF-8 > /etc/locale.conf

#network
echo borderos > /etc/hostname
echo 127.0.0.1	localhost >> /etc/hosts
echo ::1		localhost >> /etc/hosts
echo 127.0.0.1  borderos.localdomain borderos

grub-install --target=i386-pc /dev/vda
grub-mkconfig -o /boot/grub/grub.cfg

systemctl enable gdm.service
systemctl set-default graphical.target
systemctl enable avahi-daemon.service
systemctl enable NetworkManager.service

EOF
