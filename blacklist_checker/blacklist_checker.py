#!/usr/bin/env python

import smtplib
import dns.resolver
import sys
import ConfigParser
import ast


def get_config():
    CONFIG = ConfigParser.RawConfigParser(allow_no_value=True)
    CONFIG.read('blacklists.cfg')
    bls = ast.literal_eval(CONFIG.get('blacklist_config', 'blacklist'))
    return bls


def check_blacklists(bls):
    for bl in bls:
        try:
            my_resolver = dns.resolver.Resolver()
            query = '.'.join(reversed(str(myIP).split("."))) + "." + bl
            answers = my_resolver.query(query, "A")
            answer_txt = my_resolver.query(query, "TXT")
            print 'IP: %s IS listed in %s (%s: %s)' %(myIP, bl, answers[0], answer_txt[0])
        except dns.resolver.NXDOMAIN:
            print 'IP: %s is NOT listed in %s' %(myIP, bl)


if len(sys.argv) != 2:
    print 'Usage: %s <ip>' %(sys.argv[0])
    quit()

myIP = sys.argv[1]

if __name__ == '__main__':
    bls = get_config()
    check_blacklists(bls)
