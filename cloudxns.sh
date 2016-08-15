#!/bin/sh

CONFIG=${1:-${HOME}/.config/cloudxns/cloudxns.conf}

if [ ! -f "$CONFIG" ];then
    echo "Config file not found." >&2
    exit 1
fi 

agent="CloudXNS DDNS Bash Client"
URL_D="https://www.cloudxns.net/api2/ddns"

DdnsCheck() {
	if [ $# -eq 0 ]; then
		echo 'Usage: $0 "root.domain" ["hostname"]'
		exit 1
	fi

	FULL_DOMAIN="${1}"
	if [ x."${2}" != "x." ]; then
		FULL_DOMAIN="${2}.${1}"
	fi
	PARAM_BODY="{\"domain\":\"${FULL_DOMAIN}\"}"

	echo "Updating domain ${FULL_DOMAIN} ..." >&2
	HMAC_U=$(echo -n "$API_KEY$URL_D$PARAM_BODY$DATE$SECRET_KEY"|md5sum|cut -d" " -f1)
	RESULT=$(curl --noproxy "*" -A $agent -k -s $URL_D --data $PARAM_BODY -H "API-KEY: $API_KEY" -H "API-REQUEST-DATE: $DATE" -H "API-HMAC: $HMAC_U" -H 'Content-Type: application/json')
	
	if echo -n "$RESULT" | grep -o "success" >/dev/null 2>&1; then
		echo "Update success for domain ${FULL_DOMAIN}" >&2
		return 0
	else
		echo "Update failed for domain ${FULL_DOMAIN}: $RESULT" >&2
		return 1
	fi
}

source $CONFIG
