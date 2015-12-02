#!/bin/bash
#script is written to check heap size with help of app metric screen
#adapted for usage as Nagios plugin
#02.12.2015
declare -i CRITICAL_THRESHOLD;
declare -i WARNING_THRESHOLD;
declare -r DEFAULT_WARNING_THRESHOLD=93;
declare -r DEFAULT_CRITICAL_THRESHOLD=96;
declare -r OPTIONS='u:w:c:h';
declare -r OTHERS_CODE=3;
declare -r CRITICAL_CODE=2;
declare -r WARNING_CODE=1;
declare -r OK_CODE=0;
#usage
USAGE="$0 -u <url> [-h -w <n> -c <n>] \n
\n
\t	where:\n\n
\t	-u <url>\turl to execute\n\n
\t	optional:\n\n
\t	-h\t	show this help\n
\t	-w <n>\t	warning theshold  n% (default=${DEFAULT_WARNING_THRESHOLD})\n
\t	-c <n>\t	critical theshold n% (default=${DEFAULT_CRITICAL_THRESHOLD})\n
";
#parse script input parameters
parse_arguments () {
	#parse options
	while getopts ${OPTIONS} opt; do
	  case $opt in
		u)
		  URL=$OPTARG;
		  ;;
		w)
		  WARNING_THRESHOLD=$OPTARG;
		  ;;
		c)
		  CRITICAL_THRESHOLD=$OPTARG;
		  ;;
		h)
		  echo -e $USAGE >&1;
		  exit ${OK_CODE};
		  ;;
		\?)
		  echo -e "\nERROR: invalid option: -$OPTARG\n" >&2;
		  echo -e $USAGE >&2;
		  exit ${OTHERS_CODE};
		  ;;
		:)
		  echo -e "\nERROR: option -$OPTARG requires an argument.\n" >&2;
		  echo -e $USAGE >&2;
		  exit ${OTHERS_CODE};
		  ;;
	  esac
	done;
	#check if both -w and -c optiones defined
	if [ -z ${WARNING_THRESHOLD} ] && [ ! -z ${CRITICAL_THRESHOLD} ]
	then 
		echo -e "\nERROR: please define warning theshold!\n";
		echo -e $USAGE >&2;
		exit ${OTHERS_CODE};
	elif [ -z ${CRITICAL_THRESHOLD} ] && [ ! -z ${WARNING_THRESHOLD} ]
	then
		echo -e "\nERROR: please define critical theshold!\n";
		echo -e $USAGE >&2;
		exit ${OTHERS_CODE};		
	else
		#set up default values if none defined
		WARNING_THRESHOLD=${WARNING_THRESHOLD:=$DEFAULT_WARNING_THRESHOLD};
		CRITICAL_THRESHOLD=${CRITICAL_THRESHOLD:=$DEFAULT_CRITICAL_THRESHOLD};
		#check if critical threshold is greater than warning
		if [ ${WARNING_THRESHOLD} -ge ${CRITICAL_THRESHOLD} ]
		then
			echo -e "\nERROR: warning threshold(${WARNING_THRESHOLD}%) is greater than critical theshold(${CRITICAL_THRESHOLD}%)!\n";
			exit ${OTHERS_CODE};
		fi;
	fi
	#check mandatory options
	if [ -z ${URL} ];then
		echo -e "\nERROR: Url is not set up!\n" >&2;
		echo -e $USAGE >&2;
		exit ${OTHERS_CODE};
	fi;
}
#get integer percentage of argument1 compared to argument2
calculate (){
	if [ $# -ne 2 ];then
		echo "ERROR: $0 wrong number of input parameters" >&2;
		exit ${OTHERS_CODE};
	fi;
	current_value=$1;
	max_value=$2;
	echo $(echo "scale=0;${current_value}*100 / ${max_value}"|bc -l) >&1;
}
#get required heap values from curl responce
get_heap_values () {
	if [ $# -ne 1 ];then
		echo "ERROR: get_heap_values: wrong number of input parameters" >&2;
		exit ${OTHERS_CODE};
	fi;
	L_URL=$1;
	heap_values=$(curl -s ${L_URL} |sed 's/,/\n/g'|egrep -e 'jvm.memory.heap.(max|used)');
	max_heap=$(echo ${heap_values}|sed 's/ /\n/g'|grep max|sed 's/[^0-9]//g');
	used_heap=$(echo ${heap_values}|sed 's/ /\n/g'|grep used|sed 's/[^0-9]//g');
	echo "${used_heap} ${max_heap}" >&1;
}
#generate message depending on input percent and configured threshold
validate_percent (){
	if [ $# -ne 1 ];then
		echo "ERROR: validate_percent: wrong number of input parameters" >&2;
		exit ${OTHERS_CODE};
	fi;
	L_HEAP_USAGE_PERCENT=$1;
	if [ ${L_HEAP_USAGE_PERCENT} -ge ${WARNING_THRESHOLD} ] && [ ${L_HEAP_USAGE_PERCENT} -lt ${CRITICAL_THRESHOLD} ]
	then
		echo "WARNING: Heap usage is ${L_HEAP_USAGE_PERCENT}%!" >&1;
		exit ${WARNING_CODE};
	elif [ ${L_HEAP_USAGE_PERCENT} -ge ${CRITICAL_THRESHOLD} ]
	then
		echo "CRITICAL: Heap usage is ${L_HEAP_USAGE_PERCENT}%!" >&1;
		exit ${CRITICAL_CODE};
	else
		echo "OK: Heap usage is ${L_HEAP_USAGE_PERCENT}%!" >&1;
		exit ${OK_CODE};
	fi
}
#begin processing
parse_arguments $@;
HEAP_VALUES=$(get_heap_values $URL);
HEAP_USAGE_PERCENT=$(calculate ${HEAP_VALUES});
validate_percent ${HEAP_USAGE_PERCENT};