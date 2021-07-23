#! /bin/bash

# uefi, cpu_vendor, ram, ipv4, dns, ok_doas

source ./common.sh
source ./utils.sh
source ./banner.sh

# TIMEZONE=$(input "Timezone" "Turkey")
# USERNAME=$(input "Username" "potato")
# HOSTNAME=$(input "Hostname" "krastiva")
# REFLECTOR_FLAGS=$(input "Reflector Flags" "-a 24 -c de,tr -n 10 -p https,http")

PKGS=(
    "boot       linux linux-firmware base grub networkmanager"

	"A			b a c"
	"B			c b a"
    "main       linux-zen linux-firmware linux-zen-headers dkms base base-devel grub networkmanager git"
	"qof        man-db man-pages pacman-contrib reflector fish"
)

source ./pacstrap.sh

echo $PACSTRAP_PGKS

# test=$(yesno "Hi?" $N)
# test=$(input_valid "prmpt" "" "is_not_empty")
 
# print_header "System Info"
# source ./system_info.sh
# 
# print_header "Pacstrap"
# source ./pacstrap.sh
# 
# print_header "Post"
# source ./post.sh
# 
# # finish notes
# print_header "Done!"
# print_note "What is left to do ?" $cyan -
# print_desc "arch-chroot /mnt"
# print_desc "passwd root"
# print_desc "passwd $username"
