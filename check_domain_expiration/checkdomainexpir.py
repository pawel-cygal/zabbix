#!/usr/bin/python3
# -*- coding: UTF-8 -*-
"""
Author: Pawel Cygal
Email: destine@poczta.fm
Date: 2018-07-05
This script is chcecking domain name expiration date
"""

import sys
import textwrap
import argparse
import validators
import whois
from datetime import datetime


def domain_is_valid(domainname):
    '''Check if domain name is valid'''
    is_valid = validators.domain(domainname)
    return is_valid


def check_expiration_date(domainname):
    '''Fucntion is checking expiration date for domain'''
    w = whois.query(domainname)
    if type(w.expiration_date) == list:
        w.expiration_date = w.expiration_date[0]

    domain_expiration_date = str(w.expiration_date)
    result = domain_expiration_date[0:10]
    return result


def days_to_expiration(ed):
    '''
    Function is calculate days between to dates
    and returning how many days left to expiration
    '''
    to_day = datetime.now().strftime('%Y-%m-%d')
    days_to_expiration = datetime.strptime(ed, '%Y-%m-%d') \
        - datetime.strptime(to_day, '%Y-%m-%d')
    return days_to_expiration.days


def main():
    """ Main program """
    parser = argparse.ArgumentParser(prog='checkdomainexpir.py',
                                     usage='%(prog)s [options]',
                                     description=textwrap.dedent('''
                                     This script is checking how many days left
                                     to expiration of domain name
                                     '''),
                                     epilog=textwrap.dedent('''Script is returning
                                     days to domain name expiration
                                     '''))
    parser.add_argument('--domain',
                        help='software raid device name for example: md0'
                        )

    args = parser.parse_args()
    domain_name = args.domain

    if len(sys.argv) == 1:
        parser.print_help()
        sys.exit(1)
    elif domain_is_valid(domain_name) is not True:
        print(domain_is_valid(domain_name))
        print('''ERR: Invalid domain name. Please provide valid
              domain name and try it again''')
        sys.exit(2)
    else:
        expiration_date = check_expiration_date(domain_name)
        print(days_to_expiration(expiration_date))


if __name__ == '__main__':
    main()
