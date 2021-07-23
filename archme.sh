#! /bin/sh
#                ___              __    __  ___
#               /   |  __________/ /_  /  |/  /__
#              / /| | / ___/ ___/ __ \/ /|_/ / _ \
#             / ___ |/ /  / /__/ / / / /  / /  __/
#            /_/  |_/_/   \___/_/ /_/_/  /_/\___/
#
#   a personal minimal archlinux net-installer that is designed to
#   give full control over all packages installed
#
#
# Globals
# uefi, cpu_vendor, ram, ipv4, dns, users_count, usernames, passwords

#kernels=( "linux" "linux-lts" "linux-hardened" "linux-zen" )
#headers=( "linux-headers" "linux-lts-headers" "linux-hardened-headers" "linux-zen-headers" )
#shells=( "zsh" "fish" "dash" "ksh" "bash" )


timezone=Turkey

pkgs=(
    "boot       linux linux-firmware base grub networkmanager zsh"
    "minimal    pacman-contrib git base-devel neovim htop"
    "remote     tmate wormwhole openssh sshfs"
    "xorg       xorg-server xorg-xinit"
    "pulse      alsa-utils pulseaudio pulseaudio-alsa"
    "extras     tmux tree neofetch which less man-db man-pages"
    "dkms       dkms linux-headers"
)
# + user specified pkgs
# + efibootmgr if uefi
# + proper cpu micro code


# Color escapes
black=$'\e[1;30m'
red=$'\e[1;31m'
green=$'\e[1;32m'
yellow=$'\e[1;33m'
blue=$'\e[1;34m'
purple=$'\e[1;35m'
cyan=$'\e[1;36m'
white=$'\e[1;37m'
nc='\e[0m'

# Markup funcs
print_header() { printf "\n$purple$1$nc\n" ;}
print_point() { printf "$nc$1 " ;}
print_result() { printf "$2$1\n" ;}
print_note() { printf "$nc$3 $2$1\n" ;}
print_desc() { printf "\t$nc$1\n" ;}
nl() { printf "\n" ;}
nc() { printf "$nc" ;}
get_input() { printf "$2" && read $1 ;}
has_to_be_a_number() {
    case $1 in
        ''|*[!0-9]*) {
            print_note "Input Is Not A Number" $red !
            exit
        };;
    esac
}



# -=-=-=-= System Checks =-=-=-=-
print_header "System Checks:"
ipv4=false
dns=false

print_point "Mode"
if [ -d "/sys/firmware/efi" ]; then
    print_result "UEFI" $green
    uefi=true
else
    print_result "BIOS (LEGACY)" $green
    uefi=false
fi

print_point "IPv4"
if nc -zw1 8.8.8.8 443 &>/dev/null; then
    print_result "ON" $green
else
    print_result "OFF" $red
    print_note "No IPv4 Internet Connectivity Available" $red ! && exit
fi

print_point " DNS"
if nc -zw1 google.com 443 &>/dev/null; then
    print_result "Available" $green
else
    print_result "Missing" $red
    print_note "No DNS Resolving Ability Available" $red ! && exit
fi

print_point " RAM"
ram=`free -m | grep -oP '\d+' | head -n 1`
print_result "$ram MB" $green

print_point " CPU"
cpu_vendor=`cat /proc/cpuinfo | grep 'vendor_id' | head -n 1 | cut -d " " -f 2`
print_result "$cpu_vendor" $green

nl && lsblk=`lsblk -o NAME,FSTYPE,MOUNTPOINT,FSSIZE,FSUSED`
print_result "`echo "$lsblk" | head -n 1`" $green
print_result "`echo "$lsblk" | tail -n +2`" $white




# -=-=-=-= Notes =-=-=-=-
print_header "You should have already taken care of:"

print_note "Downloading, Burning and Booting" $cyan -
    print_desc "if you're not on the arch live iso you're in the wrong place"
nl
print_note "Partitioning, Formating, Mounting" $cyan -
if $uefi; then
    print_desc "/mnt/boot   fat32   (>512MB)"
fi
    print_desc "SWAP        SWAP    (optional)"
    print_desc "/mnt        ext4"
    print_desc "/mnt/home   ext4    (optional)"
if ! $uefi; then
nl
print_note "Setting the partition containing /boot as bootable" $cyan -
fi

if ! mountpoint -q -- "/mnt"; then
    nl && print_note "/mnt Is Not A Mountpoint" $red !
    exit
fi

# Notes confirm
nl && print_point "I understand [y/N]:" && get_input ok_notes $green
if [[ $ok_notes == 'y' ]]; then
    print_note "Lets hope you know what you're doing" $cyan -
else
    print_note "Aborting" $red -
    exit
fi




# -=-=-=-= Pre-installation =-=-=-=-
print_header "Pre-installation:"

# Clock NTP
print_point "Clock NTP"
timedatectl set-ntp true
print_result "True" $green


# All Users
usernames=(root)
passwords=()

# Root
print_point "Root Password:" && get_input root_pass $green
passwords[0]=$root_pass

# Other Users
print_point "Count of users to add:" && get_input users_count $green
has_to_be_a_number $users_count
for ((n=1; n < $users_count+1; n++)); do
    print_note "User #$n" $cyan -
    print_point "Username:" && get_input username $green
    usernames[$n]="$username"
    while true; do
        print_point "Password:" && get_input pass1 $green
        print_point "Password Again:" && get_input pass2 $green
        if [ $pass1 == $pass2 ]; then break; fi
        print_note "Passwords Mismatch, Try Again" $red !
    done
    passwords[$n]="$pass1"
done

#TODO hostname
print_point "Hostname:" && get_input hostname $green




# -=-=-=-= Installation =-=-=-=-
print_header "Installation:"

# Packages selection menu
print_note "Selecting packages" $cyan -
i=-1
for entry in "${pkgs[@]}"; do
    ((i=$i+1))
    entry_name=`echo $entry | head -n1 | cut -d ' ' -f1`
    entry_pkgs=`echo $entry | cut -d ' ' -f 2-`
    print_note "$entry_name   \t$entry_pkgs " $nc "$green$i"
done
nl && print_point "packages:" && get_input sel_pkgs $green

# Constructing pacstrap command
for n in $sel_pkgs; do
    has_to_be_a_number $n
    entry_pkgs=`echo ${pkgs[$n]} | cut -d ' ' -f 2-`
    pacstrap_pkgs="$pacstrap_pkgs$entry_pkgs"
done

# Auto adding extra packages
nl && print_note "Auto adding extra packages" $cyan -

# UEFI efibootmgr
if [ $uefi ]; then
    print_point "UEFI detected, add$green efibootmgr$nc? [Y/n]:" && get_input ok_efibootmgr $green
    if [[ ! $ok_efibootmgr == 'n' ]]; then
        pacstrap_pkgs="$pacstrap_pkgs efibootmgr"
    fi
fi

# CPU microcode
if [ $cpu_vendor == "AuthenticAMD" ]; then
    print_point "AMD CPU detected, add$green amd-ucode$nc? [Y/n]:" && get_input ok_amducode $green
    if [[ ! $ok_amducode == 'n' ]]; then
        pacstrap_pkgs="$pacstrap_pkgs amd-ucode"
    fi
elif [ $cpu_vendor == "GenuineIntel" ]; then
    print_point "Intel CPU detected, add$green intel-ucode$nc? [Y/n]:" && get_input ok_intelucode $green
    if [[ ! $ok_intelucode == 'n' ]]; then
        pacstrap_pkgs="$pacstrap_pkgs intel-ucode"
    fi
fi
nl


# Adding custom packages
print_point "Add more packages (enter for none):" && get_input more_pkgs $green
pacstrap_pkgs="$pacstrap_pkgs $more_pkgs"

# Pacstrap confirm
print_result "$pacstrap_pkgs" $yellow
print_point "About to pacstrap the above packages into /mnt [y/N]:" && get_input ok_pacstrap $green

if [[ $ok_pacstrap == 'y' ]]; then
    print_note "installing" $green -
#    pacstrap /mnt $pacstrap_pkgs
else
    print_note "Aborting" $red -
    exit
fi




# -=-=-=-= Post-installation =-=-=-=-
print_header "Post-installation:"

# Genfstab
genfstab -U /mnt >> /mnt/etc/fstab

# Archroot
cat << EOF | arch-chroot /mnt

    # Timezone
    ln -sf /usr/share/zoneinfo/$timezone /etc/localtime
    hwclock --systohc

    # Hostname
    echo $hostname > /etc/hostname

    # Create non-root users with (useradd ${usernames[$n]} -m -G wheel)
    # Set users passwords and shells
    for ((n=0; n < $users_count+1; n++)); do
        useradd ${usernames[$n]} -m -G wheel -p ${passwords[$n]}
        chsh -s /usr/bin/zsh ${usernames[$n]}
    done

    # Locale
    sed -i 's/#\(en_US\.UTF-8\)/\1/' /etc/locale.gen
    locale-gen
    echo LANG=en_US.UTF-8 > /etc/locale.conf

    # Network
    echo 127.0.0.1  localhost >> /etc/hosts
    echo ::1        localhost >> /etc/hosts
    echo 127.0.0.1  $hostname.localdomain $hostname >> /etc/hosts

    # Services
    systemctl enable NetworkManager.service

    # Grub
    if $uefi ;then
        grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=BOOT
    else
        root_disk=`mount | grep " /mnt " | cut -d " " -f 1 | sed "s/.$//"`
        grub-install --target=i386-pc /dev/$root_disk
    fi
    grub-mkconfig -o /boot/grub/grub.cfg

    # Environment variables
    # Pacman Configs
    # AUR helper
EOF
