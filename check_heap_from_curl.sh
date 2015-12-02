#!/bin/bash
declare -i CRITICAL_THRESHOLD;
declare -i WARNING_THRESHOLD;
declare -r DEFAULT_WARNING_THRESHOLD=93;
declare -r DEFAULT_CRITICAL_THRESHOLD=96;
declare -r OPTIONS='u:w:c:h';
#usage
USAGE="$0 -u <url> [-h -w <n> -c <n>] \n
\n
\t	where:\n
\t	-u\t	define url to execute\n
\t	\t	optional:\n
\t	-h\t	show this help\n
\t	-w\t	warning theshold  % (default=${DEFAULT_WARNING_THRESHOLD})\n
\t	-c\t	critical theshold % (default=${DEFAULT_CRITICAL_THRESHOLD})\n
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
		  exit 0;
		  ;;
		\?)
		  echo "Invalid option: -$OPTARG" >&2;
		  echo -e $USAGE >&2;
		  exit 1;
		  ;;
		:)
		  echo "Option -$OPTARG requires an argument." >&2;
		  echo -e $USAGE >&2;
		  exit 1;
		  ;;
	  esac
	done;
	#set up default values if none defined
	WARNING_THRESHOLD=${WARNING_THRESHOLD:=$DEFAULT_WARNING_THRESHOLD};
	CRITICAL_THRESHOLD=${CRITICAL_THRESHOLD:=$DEFAULT_CRITICAL_THRESHOLD};
	#check mandatory options
	if [ -z ${URL} ];then
		echo -e "ERROR: Url is not set up." >&2;
		echo -e $USAGE >&2;
		exit 1;
	fi;
}
#get integer percentage of argument1 compared to argument2
calculate (){
	if [ $# -ne 2 ];then
		echo "ERROR: $0 wrong number of input parameters" >&2;
		exit 1
	fi;
	current_value=$1;
	max_value=$2;
	echo $(echo "scale=0;${current_value}*100 / ${max_value}"|bc -l) >&1;
}
#get required heap values from curl responce
get_heap_values () {
	if [ $# -ne 1 ];then
		echo "ERROR: $0 wrong number of input parameters" >&2;
		exit 1;
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
		echo "ERROR: $0 wrong number of input parameters" >&2;
		exit 1;
	fi;
	L_HEAP_USAGE_PERCENT=$1;
	if [ ${L_HEAP_USAGE_PERCENT} -ge ${WARNING_THRESHOLD} ] && [ ${L_HEAP_USAGE_PERCENT} -lt ${CRITICAL_THRESHOLD} ]
	then
		echo "WARNING: Heap usage is ${L_HEAP_USAGE_PERCENT}%!" >&1;
	elif [ ${L_HEAP_USAGE_PERCENT} -ge ${CRITICAL_THRESHOLD} ]
	then
		echo "CRITICAL: Heap usage is ${L_HEAP_USAGE_PERCENT}%!" >&1;
	fi
}
#begin processing
parse_arguments $@;
HEAP_VALUES=$(get_heap_values $URL);
HEAP_USAGE_PERCENT=$(calculate ${HEAP_VALUES});
validate_percent ${HEAP_USAGE_PERCENT};









