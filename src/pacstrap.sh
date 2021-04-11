# Mirror ranking
print_note "Ranking mirrors" $cyan -
reflector $reflector_flags > /etc/pacman.d/mirrorlist

# Packages selection menu
print_note "Selecting packages" $cyan -
pacstrap_pkgs=""
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
    pacstrap_pkgs="$pacstrap_pkgs $entry_pkgs"
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


# NVIDIA
print_point "Install proprietary $green nvidia$nc drivers? [Y/n]:" && get_input ok_nvidia $green
if [[ ! $ok_nvidia == 'n' ]]; then
    pacstrap_pkgs="$pacstrap_pkgs nvidia-dkms lib32-nvidia-utils"
fi

# DOAS
print_point "Replace sudo with $green opendoas$nc? [Y/n]:" && get_input ok_doas $green
if [[ ! $ok_doas == 'n' ]]; then
    pacstrap_pkgs="$pacstrap_pkgs opendoas"
fi

# NOPASS
print_point "Set $green nopass$nc? [Y/n]:" && get_input ok_nopass $green

# PKGFILE
print_point "Setup $green pkgfile$nc? [Y/n]:" && get_input ok_pkgfile $green
if [[ ! $ok_pkgfile == 'n' ]]; then
    pacstrap_pkgs="$pacstrap_pkgs pkgfile"
fi

# Adding custom packages
print_point "Add more packages (enter for none):" && get_input more_pkgs $green
pacstrap_pkgs="$pacstrap_pkgs $more_pkgs"

# Pacstrap confirm
print_result "$pacstrap_pkgs" $yellow
print_point "About to pacstrap the above packages into /mnt [Y/n]:" && get_input ok_pacstrap $green

if [[ ! $ok_pacstrap == 'n' ]]; then
    print_note "installing$nc" $green -
    pacstrap /mnt $pacstrap_pkgs
else
    print_note "Aborting" $red -
    exit
fi
