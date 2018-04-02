#!/usr/bin/env python

import smtplib
import dns.resolver
import sys

bls = ["zen.spamhaus.org", "spam.abuse.ch", "cbl.abuseat.org", "virbl.dnsbl.bit.nl", "dnsbl.inps.de",
    "ix.dnsbl.manitu.net", "dnsbl.sorbs.net", "bl.spamcannibal.org", "bl.spamcop.net",
    "xbl.spamhaus.org", "pbl.spamhaus.org", "dnsbl-1.uceprotect.net", "dnsbl-2.uceprotect.net",
    "dnsbl-3.uceprotect.net", "db.wpbl.info","b.barracudacentral.org","bl.blocklist.de","dnsbl.sorbs.net"]

if len(sys.argv) != 2:
    print 'Usage: %s <ip>' %(sys.argv[0])
    quit()

myIP = sys.argv[1]

for bl in bls:
    try:
        my_resolver = dns.resolver.Resolver()
        query = '.'.join(reversed(str(myIP).split("."))) + "." + bl
        answers = my_resolver.query(query, "A")
        answer_txt = my_resolver.query(query, "TXT")
        print 'IP: %s IS listed in %s (%s: %s)' %(myIP, bl, answers[0], answer_txt[0])
    except dns.resolver.NXDOMAIN:
        print 'IP: %s is NOT listed in %s' %(myIP, bl)

