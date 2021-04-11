#! /bin/sh

# uefi, cpu_vendor, ram, ipv4, dns, ok_doas, hostname, username, timezone, pacstrap_pkgs
# used global vars

source ./common.sh
timezone=Turkey
username=potato
hostname=krastiva
reflector_flags="-a 24 -c de,tr -n 10 -p https,http"

print_header "System Info"
source ./system_info.sh

print_header "Pacstrap"
source ./pacstrap.sh

print_header "Post"
source ./post.sh

# finish notes
print_header "Done!"
print_note "What is left to do ?" $cyan -
print_desc "arch-chroot /mnt"
print_desc "passwd root"
print_desc "passwd $username"
