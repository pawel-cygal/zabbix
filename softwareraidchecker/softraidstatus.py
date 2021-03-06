#!/usr/bin/python3
# -*- coding: UTF-8 -*-
'''
Author: Pawel Cygal
Email: destine@poczta.fm
Date: 2018-07-02
This script is chcecking status of software raid
'''

import sys
import subprocess
import argparse
import shlex
import textwrap
from shutil import which


def check_dependencies(programs):
    ''' Check if program is installed in PATH and mark as executablie '''
    is_installed = []
    is_not_installed = []

    for program in programs:
        if which(program) is not None:
            is_installed.append(program)
        else:
            is_not_installed.append(program)

    if len(is_not_installed) != 0:
        print('ERR: Please install required program: %s' % is_not_installed)
        sys.exit(666)


def checkraid(device_name):
    '''
    This function is checking software raid STATES if mdamd report
    active or clean STATE script will return value 0, otherwise
    return value 1
    '''
    command_line = '/usr/bin/sudo /sbin/mdadm --detail /dev/' + device_name
    arg = shlex.split(command_line)

    mdadm = subprocess.Popen(arg,
                             stdout=subprocess.PIPE
                             )

    grep = subprocess.Popen(['grep', '-i', 'state'],
                            stdin=mdadm.stdout,
                            stdout=subprocess.PIPE
                            )

    head = subprocess.Popen(['head', '-n1'],
                            stdin=grep.stdout,
                            stdout=subprocess.PIPE
                            )

    cut = subprocess.Popen(['cut', '-d:', '-f2'],
                           stdin=head.stdout,
                           stdout=subprocess.PIPE
                           )

    output = cut.communicate()[0]
    result = output.decode('utf-8').strip()
    return result


def show_raport(cr_result, arg):
    if arg is False:
        if (cr_result == 'active') or (cr_result == 'clean'):
            is_ok = cr_result
        else:
            is_ok = cr_result
        return is_ok
    else:
        if (cr_result == 'active') or (cr_result == 'clean'):
            is_ok = 0
        else:
            is_ok = 1
    return is_ok


def main():
    ''' Main program '''
    parser = argparse.ArgumentParser(prog='softraidchecker.py',
                                     usage='%(prog)s [options]',
                                     description=textwrap.dedent('''
                                     This script is checking software raid
                                     STATES. Its main purpose is to integrate
                                     it with zabbix monitoring system
                                     '''),
                                     epilog=textwrap.dedent('''Script is by
                                     default returning STATE of software raid.
                                     When --zabbix option is passed then script
                                     will return value 0 if state is active
                                     or clean, otherwise return value 1
                                     '''))
    parser.add_argument('--device',
                        help='software raid device name for example: md0'
                        )
    parser.add_argument('--zabbix',
                        help='''simple status for zabbix 0 = active or clean
                        value of 1 mean other status''',
                        default=False,
                        action='store_true'
                        )

    args = parser.parse_args()
    device_name = args.device
    program_dep = ['mdadm', 'grep', 'head', 'cut']
    check_dependencies(program_dep)

    if len(sys.argv) == 1:
        parser.print_help()
        sys.exit(1)
    else:
        status = checkraid(device_name)
        print(show_raport(status, args.zabbix))


if __name__ == '__main__':
    main()
