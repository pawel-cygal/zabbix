# checkdomainexpir.py

## Purpose
This script is checking how many days left to expiration of domain name

# Folder structure
```
.
check_domain_expiration
    ├── README.md
    └── checkdomainexpir.py
```

# Usage
./checkdomainexpir.py [options]
```
This script is checking domain name expiration date

optional arguments:
  -h, --help       show this help message and exit
  --domain DOMAIN  software raid device name for example: md0
```  

## Example
```
./checkdomainexpir.py --domain example.com
```

## Returning values

Script is returning days to domain name expiration for example 178