#!/usr/bin/python
# -*- coding: UTF-8 -*-
"""
Author: Pawel Cygal
Email: destine@poczta.fm
Date: 2018-07-02
This script is chcecking status of software raid
"""

import sys
import subprocess
import argparse
import shlex
import textwrap


def checkraid(device_name):
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
    result = output.strip()

    if (result == 'active') or (result == 'clean'):
        is_ok = 0
    else:
        is_ok = 1

    return is_ok


def main():
    parser = argparse.ArgumentParser(prog='softraidchecker.py',
                                     usage='%(prog)s [options]',
                                     description=textwrap.dedent('''
                                     This script is checking software raid
                                     STATES. Its main purpose is to integrate
                                     it with zabbix monitoring system
                                     '''),
                                     epilog=textwrap.dedent('''Script is returning
                                     value 0 if mdadm report STATE is active or
                                     clean, otherwise return value 1
                                     '''))
    parser.add_argument('--device',
                        help='software raid device name for example: md0'
                        )

    args = parser.parse_args()
    device_name = args.device

    if len(sys.argv) == 1:
        parser.print_help()
        sys.exit(1)
    else:
        print checkraid(device_name)

if __name__ == '__main__':
    main()
