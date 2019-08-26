#!/bin/bash
MAP_FILE=$1
EMAILS=$2
DATE=$(date '+%d%m%Y')
CUR_PID=$$
LOG=/tmp/${CUR_PID}_website_check_${DATE}.log
links=$(cat ${MAP_FILE}  |grep loc|cut -d'>' -f2 |cut -d'<' -f1)
for link in $links; do
	http_responce=$(curl -o /dev/null -s -w "%{http_code}\n" ${link});
	echo "returned code = ${http_responce}  ; page = \"${link}\"" >> ${LOG};
done

if [ $(grep -v 'code = 200' ${LOG}|wc -l) -eq 0 ];
then
	cat ${LOG} | sudo mutt -a "${LOG}" -s "Web-site validation for the ${DATE}" -- ${EMAILS}
else
	cat ${LOG} | sudo mutt -a "${LOG}" -s "ATTENTION: not a regular responce identified for the ${DATE}" -- ${EMAILS}
fi

