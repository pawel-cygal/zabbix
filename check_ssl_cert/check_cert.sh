#!/bin/bash
# Author: Pawel Cygal
# Contact destine@poczta.fm
# Date: 2014-07-17
# INFO: This script is checking ssl certificate expiration date.
# You can use this script even on host with SNI support
# (multiple ssl sites running on single IP address)

############ USTAWIENIA i ZMIENNE GLOBALNE!!!###############
#
function usage(){
        echo -e "\e[0;31m\e[1m\e[4m\e[5mYou don't specified domain name!!!!\e[0m"
        echo -e "\e[0;31mPlease type domain name and port if is other than 443\e[0m"
        echo -e "\e[0;32m     \e[4mUSAGE: ./check_cert.sh domainname.com or ./check_cert.sh domainname.com 6363\e[0m"
        echo -e "\e[0;32myou can also check other protocol e.g \"--smtp,--imap,--pop3,--ftp, --xmpp\"\e[0m"
        echo -e "\e[033m     \e[4mExample: ./check_cert.sh domainname.com 25 --smtp or ./check_cert.sh domainname 25 --smtp --zabbix\e[0m"
        echo -e "\e[0;32mfor use with zabbix monitoring system. Use switch \"--zabbix\" after domain and/or port\e[0m"
}

ISDIGIT='^[0-9]+$'

if [ $# -eq 4 ] ; then
        DOMAIN=$1
        PORT=$2
        if [ "$3" == "--zabbix" ] ; then
                OPTION=$3
                OPTION2=$4
                case $OPTION2 in
                        "--smtp")
                                OPTION2="smtp"
                        ;;
                        "--imap")
                                OPTION2="imap"
                        ;;
                        "--pop3")
                                OPTION2="pop3"
                        ;;
                        "--ftp")
                                OPTION2="ftp"
                        ;;
			"--xmpp")
				OPTION2="xmpp"
			;;
                        *)
                                usage
                                exit 4;
                        ;;
                esac
        elif [ "$3" != "--zabbix" ]; then
                if [ "$4" == "--zabbix" ]; then
                        OPTION=$4
                        OPTION2=$3
           case $OPTION2 in
           "--smtp")
              OPTION2="smtp"
           ;;
           "--imap")
              OPTION2="imap"
           ;;
           "--pop3")
              OPTION2="pop3"
           ;;
           "--ftp")
              OPTION2="ftp"
           ;;
	   "--xmpp")
	      OPTION2="xmpp"	
	   ;;
           *)
              usage
              exit 3;
           ;;
                        esac
                fi
        else
                usage
                exit 1;
        fi
elif [ $# -eq 3 ] ; then
        DOMAIN=$1
        PORT=$2

        if [ "$3" == "--zabbix" ] ; then
                OPTION=$3
                if ! [[ $PORT =~ $ISDIGIT ]] ; then
                        usage
                        exit 2;
                elif [ "$OPTION" != "--zabbix" ]; then
                        usage
                        exit 2;
                fi
        elif [ "$3" != "--zabbix" ] ; then
                OPTION2=$3
           case $OPTION2 in
           "--smtp")
              OPTION2="smtp"
           ;;
           "--imap")
              OPTION2="imap"
           ;;
           "--pop3")
              OPTION2="pop3"
           ;;
           "--ftp")
              OPTION2="ftp"
           ;;
           "--xmpp")
	      OPTION2="xmpp"
	   ;;
           *)
              usage
              exit 1;
           ;;
                esac
        fi
elif [ $# -eq 2 ]; then
        DOMAIN=$1
        if [ "$2" == "--zabbix" ] ; then
                OPTION=$2
                elif [[ $2 =~ $ISDIGIT ]] ; then
                        PORT=$2
                elif [ "$2" != "--zabbix" ] ; then
                        OPTION=$2
                case $OPTION in
                "--smtp")
                	OPTION2="smtp"
                ;;
                "--imap")
                	OPTION2="imap"
                ;;
                "--pop3")
                	OPTION2="pop3"
                ;;
                "--ftp")
                	OPTION2="ftp"
                ;;
		"--xmpp")
			OPTION2="xmpp"
		;;
                *)
              usage
              exit 1;
                ;;
              esac
        fi

elif [ $# -eq 1 ] ; then
        DOMAIN=$1
        PORT=443
elif [ $# -gt 3 ] ; then
        usage
        exit 1;
fi

DATE=`date +%F"-"%H%M%S%N`
TMPDIR="/tmp/"
FILE="cert_check_result_$DATE.txt"
SERVICE=$OPTION2

#################FUNKCJE SKRYPTU!!!#######################
#
function check_cert_443(){
        PORT=443

        echo "logout" | openssl s_client -servername $DOMAIN -connect $DOMAIN:$PORT 2>/dev/null  | openssl x509 -noout -enddate 2>/dev/null >$TMPDIR$FILE

}

function check_cert_on_port(){

        echo "logout" | openssl s_client -servername $DOMAIN -connect $DOMAIN:$PORT 2>/dev/null | openssl x509 -noout -enddate 2>/dev/null >$TMPDIR$FILE

}

function check_cert_other_than_www(){

        echo "logout"|  openssl s_client -starttls $SERVICE -connect $DOMAIN:$PORT 2>/dev/null | openssl x509 -noout -enddate 2>/dev/null >$TMPDIR$FILE
}

function clean_tmp_files(){
        rm -f  "$TMPDIR$FILE"
}

function check_date(){
        EXPIRED=`cat $TMPDIR$FILE | cut -d "=" -f 2`
        clean_tmp_files
        ESD=`date --date="$EXPIRED" +%s`
        CSD=`date +%s`
        CD=`date`
   DATE_TO_EXP=$(( ($ESD - $CSD) / 86400 ))
}

function show_full_raport(){
        if [ check_cert_on_port ] ; then
                echo "Domain: $DOMAIN"
                echo "Port: $PORT"
        elif [ check_cert_443 ] ; then
                PORT=443
                echo "Domain: $DOMAIN"
           echo "Port: $PORT"
        elif [ check_cert_other_than_www  ] ; then
                echo "Domain: $DOMAIN"
                echo "Port: $PORT"
                echo "Protocol $SERVICE"
        fi

        echo ""
        echo "-------------------------------------------------RAPORT---------------------------------------------------"
        echo "FULL_EXPITARION_DATE: $EXPIRED"
        echo "FULL_CURRENT_DATE: $CD"
        echo "EPIRATION_SECONDS_DATE: $ESD  |  CURRENT_SECONDS_DATE: $CSD |  DAYS_TO_EXPIRATION:  $DATE_TO_EXP DAYS"
}

function zabbix(){
        echo "$DATE_TO_EXP"
}

function main(){
        if [[ -z "$DOMAIN" ]] && [[ -z "$PORT" ]] ; then
                usage
                exit 1;
        elif  [[ -n "$DOMAIN" ]] && [[ -n "$PORT" ]] && [[ -n "$OPTION" ]] && [[ -n "$OPTION2" ]]; then
                        check_cert_other_than_www
                        check_date
                        zabbix
                exit 6;
        elif [[ -n "$DOMAIN" ]] && [[ -n "$PORT" ]] && [[ -n "$OPTION2" ]] ; then
                        check_cert_other_than_www
                        check_date
                        show_full_raport
                exit 12;
        elif  [[ -n "$DOMAIN" ]] && [[ -n "$PORT" ]] ; then
                if [ "$OPTION" == "--zabbix" ] ; then
                        check_cert_on_port
                        check_date
                        zabbix
                else
                        check_cert_on_port
                        check_date
                        show_full_raport
                fi
                exit 10;
        elif [[ -n "$DOMAIN" ]] && [[ -z "$PORT" ]]; then
                if [ "$OPTION" == "--zabbix" ] ; then
          check_cert_443
          check_date
          zabbix
      else
                        check_cert_443
                        check_date
                        show_full_raport
                fi
                exit 11;
        fi
}

main
