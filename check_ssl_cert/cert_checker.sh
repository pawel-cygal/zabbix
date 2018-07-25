#!/bin/bash
# Author: Pawel Cygal
# Contact destine@poczta.fm
# Date: 2014-07-17
# INFO: This script is checking ssl certificate expiration date.
# You can use this script even on host with SNI support
# (multiple ssl sites running on single IP address)

DATE=$(date +%Y%m%d%H%M%S)
TMPDIR="/tmp/"
FILE="cert_check_result_${DATE}.txt"


# Function print output in nice way
function _nice_output(){
    printf "\033[0;36m%s\033[m\n" "$1"
}


# Function print output in red color for errors
function _fail(){
    printf "\033[0;31m%s\033[0m\n" "$1" 1>&2
}


# Function print output in green color for success
function _success(){
    printf "\033[0;32m%s\033[0m\n" "$1"
}


# Function is detects on which OS Family is running
# It is required becouse of date command witch has different implementation for Linux and BSD systems
# based on results of this function script make decision which format of date command will be used
function recognize_os_family(){
    get_os_family="$(uname -s)"
    case "${get_os_family}" in
        Linux*)
            DETECTED_OS_FAMILY=Linux
        ;;
        Darwin*)
            DETECTED_OS_FAMILY=Mac
        ;;
        *)
            DETECTED_OS_FAMILY="UNKNOWN:${get_os_family}"
        ;;
    esac
}


# Function prints help for this script
function usage(){
    _nice_output "USAGE: $0 [-d|-p|-f|-x|-z|-i|-o|-h|-s]"
    _nice_output ""
    _nice_output "Options"
    _nice_output ""
    _nice_output " -d | --domain[=]<domain name> \t - Specify domaina name to check"
    _nice_output " -p | --port[=]<port number> \t - Specify port number to check"
    _nice_output " -f | --ftp \t\t\t - Checking ftp service" 
    _nice_output " -i | --imap \t\t\t - Checking imap service"
    _nice_output " -o | --pop3 \t\t\t - Checking pop3 service"
    _nice_output " -s | --smtp \t\t\t - Checking smtp service"
    _nice_output " -x | --xmpp \t\t\t - Checking xmpp service"
    _nice_output " -z | --zabbix \t\t\t - Prints simple report (just days to expiration) for zabbix"
    _nice_output " -h | --help \t\t\t - Prints this help"
    _nice_output ""
    _nice_output "Example: $0 -d domainname.com"
    _nice_output "Example: $0 -d domainname.com -p 6363"
    _nice_output "Example: $0 --domain=domainname.com --port=25 --smtp"
    _nice_output "Example: $0 -d dommainname.com -i --port=3232 -z"
}


# Function is checking expiration day on https domain and save results in temporary file
function check_cert(){
    echo "logout" | openssl s_client -servername "${DOMAIN}" -connect "${DOMAIN}:${PORT}" 2>/dev/null  | openssl x509 -noout -enddate 2>/dev/null > "${TMPDIR}${FILE}"
}


# Function is checking expiration day on services different than https and save results in temporary file
function check_cert_other_than_www(){
    echo "logout"|  openssl s_client -starttls "${SERVICE}" -connect "${DOMAIN}:${PORT}" 2>/dev/null | openssl x509 -noout -enddate 2>/dev/null > "${TMPDIR}${FILE}"
}


# Function is cleaning all temporary files
function clean_tmp_files(){
    rm -f  "${TMPDIR}${FILE}"
}


# Function is counting expiration date of certificate based on current date
function check_date(){
    EXPIRED=$(cut -d "=" -f 2 < "${TMPDIR}${FILE}")
    clean_tmp_files

    if [[ -z "${EXPIRED}" ]]; then
        _fail "ERR: Somthing went wrong! Can not find Expiration date."
        exit 99
    fi
    
    if [[ "${DETECTED_OS_FAMILY}" == "Linux" ]]; then
        ESD=$(date --date="${EXPIRED}" +%s)
    elif [[ "${DETECTED_OS_FAMILY}" == "Mac" ]]; then
        ESD=$(date -j -f "%b %d %T %Y %Z" "${EXPIRED}" "+%s")
    fi

    CSD=$(date +%s)
    CD=$(date)
    DATE_TO_EXP=$(( (ESD - CSD) / 86400 ))
}


# Function is printing full report 
function show_full_report(){
    _success ""
    _nice_output "Detected runtime OS family: ${DETECTED_OS_FAMILY}"

    if [[ -z "${SERVICE}" ]]; then
        _nice_output "Checking service: https on port: ${PORT}"
    else
        _nice_output "Checking service: ${SERVICE} on port: ${PORT}"
    fi

    _success "-------------------------------------------------REPORT---------------------------------------------------"
    _success "FULL_EXPITARION_DATE: ${EXPIRED}"
    _success "FULL_CURRENT_DATE: ${CD}"
    _success "EXPIRATION_SECONDS_DATE: ${ESD}  |  CURRENT_SECONDS_DATE: ${CSD} |  DAYS_TO_EXPIRATION:  ${DATE_TO_EXP} DAYS"
    _success ""
}


# Function prints days to expiration for zabbix monitoring
function zabbix(){
    echo "${DATE_TO_EXP}"
}


# Main function
function main(){
    if [[ -n "${SERVICE}" ]]; then
        check_cert_other_than_www
        if [[ "${ZABBIX_REPORT}" == "yes" ]]; then
            check_date
            zabbix
        else
            check_date
            show_full_report
        fi
    elif [[ "${ZABBIX_REPORT}" == "yes" ]]; then
        check_cert
        check_date
        zabbix
    else
        check_cert
        check_date
        show_full_report
    fi
}


# Start main program
recognize_os_family

OPTSPEC="hsiofxzrwtd:p:-:"
while getopts "$OPTSPEC" OPTCHAR; do
    case "${OPTCHAR}" in 
        h)
            usage
        ;;
        d)
            DOMAIN=${OPTARG}
            if ! [[ "$*" =~ -p ]] || ! [[ "$*" =~ --port ]]; then
                PORT=443
            fi
        ;;
        s)
            SERVICE="smtp"
            if ! [[ "$*" =~ -p ]] || ! [[ "$*" =~ --port ]]; then
                PORT=25
            fi
        ;;
        i)
            SERVICE="imap"
            if ! [[ "$*" =~ -p ]] || ! [[ "$*" =~ --port ]]; then
                PORT=143
            fi
        ;;
        o)
            SERVICE="pop3"
            if ! [[ "$*" =~ -p ]] || ! [[ "$*" =~ --port ]]; then
                PORT=110
            fi
        ;;
        f)
            SERVICE="ftp"
            if ! [[ "$*" =~ -p ]] || ! [[ "$*" =~ --port ]]; then
                PORT=21
            fi
        ;;
        x)
            SERVICE="xmpp"
            if ! [[ "$*" =~ -p ]] || ! [[ "$*" =~ --port ]]; then
                PORT=5222
            fi
        ;;
        z)
            ZABBIX_REPORT="yes"
        ;;
        p)
            PORT=${OPTARG}
        ;;
        -)
            case "${OPTARG}" in
                port)
                    PORT="${!OPTIND}"; OPTIND=$(( OPTIND + 1 ))
               ;;
                port=*)
                    PORT=${OPTARG#*=}
               ;;
                domain)
                    PORT="${!OPTIND}"; OPTIND=$(( OPTIND + 1 ))
               ;;
                domain=*)
                    DOMAIN=${OPTARG#*=}
               ;;
                smtp)
                    SERVICE="smtp"
                    if ! [[ "$*" =~ -p ]] || ! [[ "$*" =~ --port ]]; then
                        PORT=25
                    fi
                ;;
                imap)
                    SERVICE="imap"
                    if ! [[ "$*" =~ -p ]] || ! [[ "$*" =~ --port ]]; then
                        PORT=143
                    fi
                ;;
                pop3)
                    SERVICE="pop3"
                    if ! [[ "$*" =~ -p ]] || ! [[ "$*" =~ --port ]]; then
                        PORT=110
                    fi
                ;;
                xmpp)
                    SERVICE="xmpp"
                    if ! [[ "$*" =~ -p ]] || ! [[ "$*" =~ --port ]]; then
                        PORT=5222
                    fi
                ;;
                ftp)
                    SERVICE="ftp"
                    if ! [[ "$*" =~ -p ]] || ! [[ "$*" =~ --port ]]; then
                        PORT=21
                    fi
                ;;
                zabbix)
                    ZABBIX_REPORT="yes"
                ;;
                help)
                    usage
                ;;
                *)
                    if [ "$OPTERR" = 1 ] && [ "${OPTSPEC:0:1}" != ":" ]; then
                        echo "Unknown option --${OPTARG}" >&2
                    fi
                ;;
            esac
    esac
done

if [[ "$*" =~ -h ]] || [[ "$*" =~ --help ]]; then
    exit 1
elif [[ "$#" -lt 2 ]]; then
    _fail "ERR: You need to specify at least one option. "
    usage
    exit 2
else
    main
fi
