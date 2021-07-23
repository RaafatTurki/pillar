#Const Values
RESET = '\033[0m'
BOLD = '\033[01m'
DISABLE = '\033[02m'
ITALIC = '\033[3m'
UNDERLINE = '\033[04m'
BLINK = '\033[05m'
# 6 ?
REVERSE = '\033[07m'
INVISIBLE = '\033[08m'
STRIKETHROUGH = '\033[09m'

BLACK = '\033[30m'
RED = '\033[31m'
GREEN = '\033[32m'
ORANGE = '\033[33m'
BLUE = '\033[34m'
PURPLE = '\033[35m'
CYAN = '\033[36m'
LIGHTGREY = '\033[37m'
GREY = '\033[90m'
LIGHTRED = '\033[91m'
LIGHTGREEN = '\033[92m'
YELLOW = '\033[93m'
LIGHTBLUE = '\033[94m'
PINK = '\033[95m'
LIGHTCYAN = '\033[96m'

BG_BLACK = '\033[40m'
BG_RED = '\033[41m'
BG_GREEN = '\033[42m'
BG_ORANGE = '\033[43m'
BG_BLUE = '\033[44m'
BG_PURPLE = '\033[45m'
BG_CYAN = '\033[46m'
BG_LIGHTGREY = '\033[47m'

OK = GREEN
INFO = BLUE
WARN = YELLOW + ITALIC
ERR = RED

HEAD = RESET + BOLD
NOTE = GREY
DESC = GREY

#Enums
class INPUT_TYPES:
    PASS = 1
    TEXT = 2

class INPUT_RULES:
    IS_DIGIT = lambda cin: cin.isdigit()
    NOT_EMPTY = lambda cin: len(cin) != 0

class BOOT_MODES:
    BIOS = "BIOS (Legacy)"
    UEFI = "UEFI"

class INTERNET_CONNECTIVITIES:
    ONLINE = "Online"
    OFFLINE = "Offline"

class MOUNT_STATES:
    MOUNTED = "Mounted"
    UNMOUNTED = "Unmounted"

# class IP_VERSIONS:
#     FOUR = "IPv4"
#     SIX = "IPv6"

# class DNS_RESOLVINGS:
#     AVAILABLE = "Available"
#     MISSING = "Missing (No DNS Resolving Ability Available)"

class CPU_VENDOR_IDS:
    INTEL = "GenuineIntel"
    AMD = "AuthenticAMD"
    AMD_OLD = "AMDisbetter!"
    VIA = "CentaurHauls"
    TRANSMETA_OLD = "TransmetaCPU"
    TRANSMETA = "GenuineTMx86"
    CYRIX = "CyrixInstead"
    CENTAUR = "CentaurHauls"
    NEXGEN = "NexGenDriven"
    UMC = "UMC UMC UMC "
    SIS = "SiS SiS SiS "
    NSC = "Geode by NSC"
    RISE = "RiseRiseRise"
    VORTEX = "Vortex86 SoC"
    VIA = "VIA VIA VIA "

    VMWARE = "VMwareVMware"
    XENHVM = "XenVMMXenVMM"
    MICROSOFT_HV = "Microsoft Hv"
    PARALLELS = " lrpepyh vr"

    UNKNOWN = "Unknown"

    ALL = [INTEL, AMD, AMD_OLD, VIA, TRANSMETA_OLD, TRANSMETA, CYRIX, CENTAUR, NEXGEN, UMC, SIS, NSC, RISE, VORTEX, VIA, VMWARE, XENHVM, MICROSOFT_HV, PARALLELS]