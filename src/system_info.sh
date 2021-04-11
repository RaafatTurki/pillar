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

print_point " RAM"
ram=`free -m | grep -oP '\d+' | head -n 1`
print_result "$ram MB" $green

print_point " CPU"
cpu_vendor=`cat /proc/cpuinfo | grep 'vendor_id' | head -n 1 | cut -d " " -f 2`
cpu_arch=`lscpu | grep 'Architecture' | cut -d ":" -f 2 | tr -d ' \t\n\r'`
print_result "$cpu_vendor $cpu_arch" $green

nl && lsblk=`lsblk -o NAME,FSTYPE,MOUNTPOINT,FSSIZE,FSUSED,FSAVAIL`
print_result "`echo "$lsblk" | head -n 1`" $green
print_result "`echo "$lsblk" | tail -n +2`" $white


print_note "Your disk must have the following" $cyan -
if $uefi; then
    print_desc "/mnt/boot   fat32   (>512MB)"
fi
    print_desc "SWAP        SWAP    "
    print_desc "/mnt        ext4    "
    print_desc "/mnt/home   ext4    "

if ! $uefi; then
    nl && print_note "Your /boot partition must have the bootable flag" $cyan -
fi

if ! mountpoint -q -- "/mnt" ; then
    nl && print_note "/mnt Is Not A Mountpoint" $red !
    exit
fi