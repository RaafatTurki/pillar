#! /bin/sh

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

# Markup
print_header() { printf "\n$purple$1$nc\n" ;}
print_point() { printf "$nc$1 " ;}
print_result() { printf "$2$1\n" ;}
print_note() { printf "$nc$3 $2$1\n" ;}
print_desc() { printf "\t$nc$1\n" ;}
nl() { printf "\n" ;}
nc() { printf "$nc" ;}

# Input
get_input() { printf "$2" && read -r $1 ;}
get_pass() { printf "$2" && read -r -s $1 && printf "\n";}
has_to_be_a_number() {
    case $1 in
        ''|*[!0-9]*) {
            print_note "Input Is Not A Number" $red !
            exit
        };;
    esac
}

# Packages
pkgs=(
    "boot           linux linux-firmware base grub networkmanager"

    "main           linux-zen linux-firmware linux-zen-headers dkms base base-devel grub networkmanager git"
	"qof			man-db man-pages pkgfile pacman-contrib fish usbutils"
    "xorg           xorg-xinit xorg-server xorg-xset xorg-xsetroot xwallpaper xgetres xsettingsd"
    "sound          pipewire pipewire-alsa pipewire-pulse pipewire-jack pulsemixer mpd ncmpcpp mpc"
    "wm             bspwm sxhkd rofi pcmanfm-gtk3 udiskie transmission-gtk unclutter wmname xclip maim bc engrampa p7zip unrar unace keepassxc imv mpv firefox papirus-icon-theme xcursor-vanilla-dmz slock zathura{,-ps,-pdf-mupdf}"
    "fonts          terminus-font ttf-ibm-plex ttf-joypixels"
    "dev	        neovim nodejs yarn python python-pynvim xclip"
    "fs_utils       ffmpegthumbnailer gvfs gvfs-gphoto2 gvfs-mtp trash-cli"

    # xst,
    # "apps_base    lxsession-gtk3 lxappearance-gtk3 lxinput-gtk3"
    # "apps         libreoffice-fresh"
    # "remote       tmate openssh"

    # "aur          tbsm xdg-sound polybar chameleon-git twmn-git code-marketplace downgrade pacolog font-manager exe-thumbnailer"

    # ly is another nice tbsm
    # make a libvirt list
)
