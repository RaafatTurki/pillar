import os
import pkgs_list
from util import *
from common import *

#region Globals
BOOT_MODE = ""
MNT_MOUNT_STATE = ""
INTERNET_CONNECTIVITY = ""
TOTAL_MEMORY = ""
CPU_VENDOR_ID = ""
HOSTNAME = ""
TIMEZONE = ""
ROOT_PASS = ""

USERS_AMOUNT = 0
USERS_NAME = []
USERS_PASS = []
REGISTERED_FEATURES = []
SELECTED_FEATURES = []
PACSTRAP_PKGS = []
#endregion


def stage_pre():
    global HOSTNAME
    global TIMEZONE
    global ROOT_PASS

    header("Partition Table")

    print(NOTE + cmd_exec("lsblk -o NAME,FSTYPE,MOUNTPOINT,FSSIZE,FSUSED"))


    header("System Information")

    BOOT_MODE = get_boot_mode()
    info("Boot Mode", BOOT_MODE)

    MNT_MOUNT_STATE = get_mount_state("/mnt")
    info("Mount state for /mnt", MNT_MOUNT_STATE)

    INTERNET_CONNECTIVITY = get_internet_connectivity()
    info("Internet Status", INTERNET_CONNECTIVITY)
    if INTERNET_CONNECTIVITY == INTERNET_CONNECTIVITIES.OFFLINE:
        err("No Internet Connection")

    TOTAL_MEMORY = get_total_memory()
    info("Total Memory", TOTAL_MEMORY)

    CPU_VENDOR_ID = get_cpu_vendor_id()
    info("CPU Vendor", CPU_VENDOR_ID)

    cmd_exec("timedatectl set-ntp true")
    info("Clock NTP", cmd_exec("date"))


    header("Inputs")

    HOSTNAME = prompt("Hostname", rules=[INPUT_RULES.NOT_EMPTY])
    TIMEZONE = prompt("Timezone (enter for Turkey)", default="Turkey")
    ROOT_PASS = prompt_confirmed("Root Password", INPUT_TYPES.PASS, rules=[INPUT_RULES.NOT_EMPTY])
    USERS_AMOUNT = int(prompt("Number Of Users (enter for 0)", default="0", rules=[INPUT_RULES.IS_DIGIT]))

    for i in range(0, USERS_AMOUNT):
        user_name = prompt("Name of user #"+str(i), rules=[INPUT_RULES.NOT_EMPTY])
        USERS_NAME.append(user_name)

        user_pass = prompt_confirmed("Password for " + USERS_NAME[i], INPUT_TYPES.PASS, rules=[INPUT_RULES.NOT_EMPTY])
        USERS_PASS.append(user_pass)


def stage_pacstrap():
    header("Package Selection")

    show_help()
    spacer()

    CLI_QUIT = False
    CLI_CLEAR = False

    while(not CLI_QUIT):
        full_cmd = prompt("command", rules=[INPUT_RULES.NOT_EMPTY])
        cmd = full_cmd.split()[0]
        params = full_cmd.split()[1:]

        if cmd == "quit" or cmd == "q":
            CLI_QUIT = True

        elif cmd == "clear" or cmd == "cls":
            CLI_CLEAR = True

        elif cmd == "help" or cmd == "h":
            show_help()
            spacer()

        elif cmd == "list" or cmd == "ls":
            show_all_features(REGISTERED_FEATURES)
            spacer()

        elif cmd == "select" or cmd == "sel":
            select_feature(params)
            spacer()

        else:
            err("Unknown Command")
            
        if CLI_CLEAR:
            CLI_CLEAR = False
            clear_scr()



REGISTERED_FEATURES = pkgs_list.start()
stage_pre()
stage_pacstrap()
