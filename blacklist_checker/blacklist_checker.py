#!/usr/bin/env python

import smtplib
import dns.resolver
import sys
import ConfigParser
import ast


def usage():
    """just prints help"""
    print 'Usage: %s <ip>\n' % (sys.argv[0])


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
                print 'IP: %s IS listed in %s (%s: %s)' % (myIP, blacklist_provider, answers[0], answer_txt[0])
            except dns.resolver.NXDOMAIN:
                print 'IP: %s is NOT listed in %s' % (myIP, blacklist_provider)


if len(sys.argv) != 2:
    usage()
    quit()

myIP = sys.argv[1]

if __name__ == '__main__':
    blacklist = get_config()
    check_blacklists(blacklist)
