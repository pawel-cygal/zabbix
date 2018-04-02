# cert_checker

## Purpose
This simple bash script is checking days to expiration of ssl certificates. Cert_checker can be used for checking certificates on hosts with SNI support enabled ( multiple ssl certificates on one IP/Host). Cert_checker is able to check few protocols such as https, ftp, smtp, imap, pop3, xmpp it also has option for printing simple report witch is easy to integrate with zabbix monitoring.

# Usage
./cert_checker.sh [-d|-p|-f|-x|-z|-i|-o|-h|-s]"

* -d | --domain[=]<domain name> - Specify domaina name to check
* -p | --port[=]<port number> - Specify port number to check
* -f | --ftp      - Checking ftp service
* -i | --imap   - Checking imap service
* -o | --pop3 - Checking pop3 service
* -s | --smtp  - Checking smtp service
* -x | --xmpp - Checking xmpp service
* -z | --zabbix - Prints simple report (just days to expiration) for zabbix
* -h | --help - Prints this help

* Example: ./cert_checker.sh -d domainname.com
* Example: ./cert_checker.sh  -d domainname.com -p 6363
* Example: ./cert_checker.sh  --domain=domainname.com --port=25 --smtp
* Example: ./cert_checker.sh  domainname 25 --smtp --zabbix
* Example: ./cert_checker.sh  -d dommainname.com -i --port=3232 -z

# Some outputs
Basic test for https on domainname.com
```
./cert_checker -d domainname.com

Detected runtime OS family: Linux
Checking service: https on port: 443
-----------------------REPORT----------------
FULL_EXPITARION_DATE: Nov 16 09:25:22 2018 GMT
FULL_CURRENT_DATE: pon, 2 kwi 2018, 10:30:04 CEST
EXPIRATION_SECONDS_DATE: 1542360322  |  CURRENT_SECONDS_DATE: 1522657804 |  DAYS_TO_EXPIRATION:  228 DAYS
```

Basic test for https on domainname.com with --zabbix flag enabled. This flag prints simple output which is easy to intergate this script with zabbix monitoring and continously checking all your ssl certificates 
```
./cert_checker.sh -d domainname.com --zabbix

228
```
### More examples:

```
./cert_checker.sh --domain=domainname.com -s

Detected runtime OS family: Linux
Checking service: smtp on port: 25
----------------------REPORT-----------------
FULL_EXPITARION_DATE: Nov 16 09:25:22 2018 GMT
FULL_CURRENT_DATE: pon, 2 kwi 2018, 10:35:59 CEST
EXPIRATION_SECONDS_DATE: 1542360322  |  CURRENT_SECONDS_DATE: 1522658159 |  DAYS_TO_EXPIRATION:  228 DAYS
```
The same example but with -z flag (zabbix monitoring)
```
./cert_checker.sh -d domainname.com -s -z

228
```
