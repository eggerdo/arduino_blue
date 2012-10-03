#!/bin/bash

# colour assignments, see -> http://linuxtidbits.wordpress.com/2008/08/13/output-color-on-bash-scripts-advanced/
ORANGE="\033[38;5;214m"
GREEN="\033[38;5;46m"
RED="\033[38;5;196m"

# print function, first parameter is the string, second parameter the colour.
# colour is optional
function print {
	if [ -z $2 ]; then
		echo -e $1
	else
		COLOR_RESET="\033[39m"
		echo -e $2$1$COLOR_RESET
	fi
}

if [ -z $1 ]; then
	print "FATAL: need to provide a address as parameter" $RED
	exit 1
fi

if [ -z $2 ]; then
	PORTNR=0
else
	PORTNR=$2
fi

print "connecting to $1 on rfcomm$PORTNR ..." $ORANGE

# check if we are connected already
go_on=`rfcomm show $PORTNR 2>/dev/null | grep connected`
if [[ -z $go_on ]]; then
	sudo rfcomm release $PORTNR 2>/dev/null

	# start rfcomm connect in another shell
	sudo rfcomm connect /dev/rfcomm$PORTNR $1 > /dev/null &
	
	sleep 1
	
	# wait for connection to be established. wait at most 10 seconds
	declare -i COUNTER
	COUNTER=0
	go_on=`rfcomm show $PORTNR 2>/dev/null | grep connected`
	while [[ -z $go_on ]]; do
		sleep 1
	  let COUNTER=$COUNTER+1
		go_on=`rfcomm show $PORTNR 2>/dev/null | grep connected`
		if [ $COUNTER -eq 10 ]; then
			print "connection failed!" $RED
			exit 1
		fi
	done

	print "-> connection ok" $GREEN
	
else 
	print "-> already connected" $GREEN
fi
