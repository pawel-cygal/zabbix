# softwareraidchecker.py

## Purpose
This script is checking software raid STATES. It's main purpose is to integrate it with zabbix monitoring system

# Folder structure
```
.
softwareraidchecker
    ├── README.md
    └── softraidstatus.py
```

# Usage
./softraidchecker.py [options]
```
optional arguments:
  -h, --help       show this help message and exit
  --device DEVICE  software raid device name for example: md0
```  

## example
```
./softraidstatus.py --device md0
```

## Returning values

Script is returning value 0 if mdadm reported STATE is active or clean, otherwise return value 1