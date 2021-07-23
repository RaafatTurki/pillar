from util import cmd_exec

def start():
    registered_features = []

    class feat:
        def __init__(self, name):
            self.name = name

            self.provides = None
            self.requires = None
            self.dependencies = None
            self.options = None
            self.post_command = None

        def reg(self):
            registered_features.append(self)
            return self

        def prov(self, p):
            self.provides = p
            return self

        def reqs(self, r):
            self.requires = r
            return self

        def deps(self, d):
            self.dependencies = d
            return self

        def opts(self, o):
            self.options = o
            return self

        def post_cmd(self, cmd):
            self.post_command = cmd
            return self


    #kernels
    lnx_hardened  = feat("linux-hardened").deps("linux-hardened linux-hardened-headers dkms")    .prov("kernel headers dkms hardened")
    lnx_lts       = feat("linux-lts")     .deps("linux-lts linux-lts-header dkms")               .prov("kernel headers dkms lts")
    lnx_zen       = feat("linux-zen")     .deps("linux-zen linux-zen-headers dkms")              .prov("kernel headers dkms zen")
    lnx           = feat("linux")         .deps("linux linux-headers dkms")                      .prov("kernel headers dkms")

    #bootloaders TODO set post_cmd
    grub        = feat("grub").deps("grub").post_cmd("")
    grub_uefi   = feat("grub").deps("grub efibootmgr").post_cmd("")

    #drivers
    nv      = feat("nvidia")        .deps("nvidia")                                 .prov("nvidia")
    nv_lts  = feat("nvidia-lts")    .deps("nvidia-lts")             .reqs("lts")    .prov("nvidia")
    nv_dkms = feat("nvidia-dkms")   .deps("nvidia-dkms")            .reqs("dkms")   .prov("nvidia")
    nvidia  = feat("nvidia")        .opts([nv, nv_lts, nv_dkms])

    #graphical sessions
    x       = feat("x")             .deps("xorg-server xorg-xinit") .prov("x")

    #fonts
    fn_noto = feat("noto")          .deps("noto-fonts noto-fonts-cjk noto-fonts-emoji")     .prov("ttf cjk emoji")

    #multi option features
    kernels     = feat("kernel")        .opts([lnx, lnx_lts, lnx_hardened, lnx_zen])    .reg()
    drivers     = feat("drivers")       .opts([nvidia])                                 .reg()
    fonts       = feat("fonts")         .opts([fn_noto])
    bootloader  = feat("bootloader", opts=[grub, grub_uefi]).reg()

    #simple features
    boot     = feat("boot")          .deps("base networkmanager")                     .prov("boot")                                   .reg()
    simple   = feat("simple")        .deps("base-devel git vim zsh pacman-contrib")   .prov("base-devel git vim zsh pacman-contrib")  .reg()
    extra    = feat("extra")         .deps("tmux tree neofetch")                      .prov("tmux tree neofetch")                     .reg()
    man      = feat("man")           .deps("man-pages man-db")                        .prov("man")                                    .reg()
    pulse    = feat("pulse")         .deps("alsa-utils pulseaudio pulseaudio-alsa")   .prov("pulse")                                  .reg()
    remote   = feat("remote")        .deps("tmate openssh")                           .prov("tmate ssh")                              .reg()
    settings = feat("settings")      .deps("lxappearance-gtk3 lxinput-gtk3 arandr")   .prov("settings")                               .reg()

    return registered_features
