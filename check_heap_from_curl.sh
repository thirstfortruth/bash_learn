#!/bin/bash
DEFAULT_WARNING_THRESHOLD=93;
DEFAULT_CRITICAL_THRESHOLD=96;
OPTIONS='u:w:c:h';

declare -i CRITICAL_THRESHOLD;
declare -i WARNING_THRESHOLD;
unset URL;

USAGE="$0 -u <url> [-h -w <n> -c <n>] \n
\n
\t	where:\n
\t	-u\t	define url to execute\n
\t	\t	optional:\n
\t	-h\t	show this help\n
\t	-w\t	warning theshold  % (default=${DEFAULT_WARNING_THRESHOLD})\n
\t	-c\t	critical theshold % (default=${DEFAULT_CRITICAL_THRESHOLD})\n
";
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
calculate (){
	if [ $# -ne 2 ];then
		echo "ERROR: $0 wrong number of input parameters" >&2;
		exit 1
	fi;
	current_value=$1;
	max_value=$2;
	echo $(echo "scale=0;${current_value}*100 / ${max_value}"|bc -l) >&1;
}

get_heap_values () {
	if [ $# -ne 1 ];then
		echo "ERROR: $0 wrong number of input parameters" >&2;
		exit 1;
	fi;
	
}

parse_arguments $@;
calculate 21423.1234 23423.454;



#curl -s '${URL}' |sed 's/,/\n/g'|egrep -e 'jvm.memory.heap.(max|used)';
