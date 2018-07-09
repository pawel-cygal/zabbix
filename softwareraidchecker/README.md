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
  --zabbix         simple status for zabbix 0 = OK or 1 = ERROR
```  

## Example
```
./softraidstatus.py --device md0
```
or
```
./softraidstatus.py --device md0 --zabbix
```

## Returning values
Script is returning STATE of software raid for example active or clean in text format

when --zabbix option is passed to the script then returning value 0 or 1
* 0 mean reported state is equal to active or clean  
* 1 mean reported state is different then active or clean