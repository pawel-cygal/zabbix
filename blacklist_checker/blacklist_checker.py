#!/usr/bin/env python
# Author: Pawel Cygal
# Contact destine@poczta.fm
# Date: 2016-07-17
# INFO: This script is checking that provided ipv4 address is listed on email blacklist.
# You can configure own blacklist provider which will be used for checking

import smtplib
import dns.resolver
import sys
import ConfigParser
import ast
import socket


def usage():
    """just prints help"""
    print 'Usage: %s <ipv4>\n' % (sys.argv[0])


def ip_is_valid(ip):
    """Function validate provide ip address """
    try:
        socket.inet_aton(ip)
    except socket.error:
        print("ERR: Provided IP Address is not valid")
        print("Please provide valid ipv4 address for example: 198.43.19.44\n")
        usage()
        exit(1)
    else:
        return ip


def get_config():
    """Function is checking if configuration file exist and has required section"""
    CONFIG = ConfigParser.RawConfigParser(allow_no_value=True)
    try:
        CONFIG.read('blacklists.cfg')
        blacklist = ast.literal_eval(CONFIG.get('blacklist_providers', 'blacklist'))
    except (IOError, ConfigParser.NoSectionError):
        print "ERR: Somthing went wrong. Looks like configuration file is missing or has wrong structure" 
    else:
        return blacklist


def check_blacklists(blacklist):
    """Function is checking if your ip is listed on mailing blacklist configured in blacklist.cfg"""
    if blacklist:
        for blacklist_provider in blacklist:
            try:
                my_resolver = dns.resolver.Resolver()
                query = '.'.join(reversed(str(myIP).split("."))) + "." + blacklist_provider
                answers = my_resolver.query(query, "A")
                answer_txt = my_resolver.query(query, "TXT")
                print 'IP: %s is listed in %s (%s: %s)' % (myIP, blacklist_provider, answers[0], answer_txt[0])
            except dns.resolver.NXDOMAIN:
                print 'IP: %s is NOT listed in %s' % (myIP, blacklist_provider)


if len(sys.argv) != 2:
    usage()
    quit()

if __name__ == '__main__':
    myIP = ip_is_valid(sys.argv[1])
    blacklist = get_config()
    check_blacklists(blacklist)
