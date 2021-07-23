from common import *
import getpass
import subprocess
import os
import socket



#region Markup
def spacer(n=1):
    print("\n" * n, end='')


def header(txt):
    print('\n\t' + HEAD + txt + RESET + '\n')


def prompt(prmpt, mode=INPUT_TYPES.TEXT, default="", rules=[]):
    prompt_txt = NOTE + prmpt + ':' + RESET + ' ' + INFO
    cin = ""
    invalid_input = True

    while(invalid_input):
        if mode == INPUT_TYPES.TEXT:
            cin = input(prompt_txt)
        elif mode == INPUT_TYPES.PASS:
            cin = getpass.getpass(prompt_txt)
        print(RESET, end='')
 
        if len(cin) == 0:
            cin = default

        invalid_input = False
        for rule in rules:
            if rule(cin) == False:
                err("Invalid Input")
                invalid_input = True

    return cin


def prompt_confirmed(prmpt, mode=INPUT_TYPES.TEXT, default="", rules=[]):
    invalid_input = True
    while(invalid_input):
        cin1 = prompt(prmpt, mode, default, rules)
        cin2 = prompt(prmpt + " (again)", mode, default, rules)

        if cin1 != cin2:
            err("Mismatched Input")
        else:
            invalid_input = False

    return cin1


def info(prmpt, info):
    print(NOTE + prmpt + ': ' + INFO + info + RESET)


def desc(txt):
    print(DESC + txt + RESET)


def err(msg):
    print(ERR + msg + RESET)

def help_entry(usage, desc, short="", tabs=1):
    print(NOTE + usage + ': ' + ('\t' * tabs) + NOTE + '('+short+')' + '\t' + INFO + desc + RESET)
#endregion


#region General Utils
def cmd_exec(cmd):
    return str(subprocess.Popen(cmd, shell=True, stdout=subprocess.PIPE).stdout.read().decode('UTF-8').rstrip())

def clear_scr():
    os.system('clear')
#endregion


#region Getters
def get_boot_mode():
    if os.path.isdir("/sys/firmware/efi"):
        return BOOT_MODES.UEFI
    else:
        return BOOT_MODES.BIOS

def get_mount_state(path):
    if os.path.ismount(path):
        return MOUNT_STATES.MOUNTED
    else:
        return MOUNT_STATES.UNMOUNTED

def get_internet_connectivity():
    try:
        socket.create_connection(("1.1.1.1", 53))
        return INTERNET_CONNECTIVITIES.ONLINE
    except OSError:
        pass
    return INTERNET_CONNECTIVITIES.OFFLINE


def get_total_memory():
    total_mem = cmd_exec("free -m | grep -oP '\d+' | head -n 1")
    return str(int(total_mem) / 1000) + " GB"


def get_cpu_vendor_id():
    extracted_cpu_vendor_id = cmd_exec("cat /proc/cpuinfo | grep 'vendor_id' | head -n 1 | cut -d ' ' -f 2")

    for cpu_vendor_id in CPU_VENDOR_IDS.ALL:
        if extracted_cpu_vendor_id.lower() == cpu_vendor_id.lower():
            return cpu_vendor_id

    return CPU_VENDOR_IDS.UNKNOWN
#endregion


#region Pacstraping
def show_deps(f):
	deps_line = ""
	if f.dependencies:
		deps = f.dependencies.split()
		for i in range(0, len(deps)):
			dep = deps[i]
			deps_line += dep + ' '
	return WARN + deps_line


def show_opts_recursive(f, depth):
	if f.options:
		for i in range(0, len(f.options)):
			opt = f.options[i]
			info(('  ' * depth) + INFO + str(i) + ' ' + NOTE + opt.name, show_deps(opt))
			if opt.options:
				show_opts_recursive(opt, depth + 1)


def show_all_features(f_arr):
    for i in range(0, len(f_arr)):
        f = f_arr[i]
        info(RESET + f.name, show_deps(f))
        show_opts_recursive(f, 0)

def select_feature(params):
	if not len(params):
		err("No Argument Given")
	print(params)


def show_help():
    help_entry("quit",              "quit the package selection cli",       "q",    3)
    help_entry("clear",             "clear the screen",                     "cls",  3)
    help_entry("help",              "show this message",                    "h",    3)
    help_entry("pacstrap",          "pacstrap the selected packages",       "pac",  2)
    spacer()
    help_entry("list",              "list all available features",          "ls",   3)
    help_entry("select <feature>",  "select a feature by name",             "sel",  1)
    spacer()
    help_entry("add <pkg>",         "add packages",                         "add",  2)
    help_entry("del <pkg>",         "removes packages",                     "rm",   2)
#endregion
