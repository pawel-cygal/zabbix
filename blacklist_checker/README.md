# blacklist_checker.py

## Purpose
This simple python script checking if your IP Address (mail server) is 
listed on blacklist.  

# Usage
./blacklist_checker.py **\<ip\>**

## Configuration
Script requires one configuration file in ini format placed in the same 
directory as blacklist_checker.py. Configuration file needs to have 
name blacklists.cfg.

## blacklists.cfg structure
Configuration file have only one section called 
**[blacklist_providers]**
in this section should be defined key called blacklist with and values 
in dict format. Each value is representing one blacklist provider.
Please see example bellow 
```
 [blacklist_providers]
 backlist = [ "zen.spamhaus.org",
              "spam.abuse.ch",
              "cbl.abuseat.org",
              "virbl.dnsbl.bit.nl",
              "dnsbl.inps.de",
              "ix.dnsbl.manitu.net",
              "dnsbl.sorbs.net",
              "bl.spamcop.net",
              "xbl.spamhaus.org",
              "pbl.spamhaus.org",
              "dnsbl-1.uceprotect.net",
              "dnsbl-2.uceprotect.net",
              "dnsbl-3.uceprotect.net",
              "db.wpbl.info",
              "b.barracudacentral.org",
              "bl.blocklist.de",
              "dnsbl.sorbs.net" ]
