#!/bin/bash

# colour assignments, see -> http://linuxtidbits.wordpress.com/2008/08/13/output-color-on-bash-scripts-advanced/
ORANGE="\033[38;5;214m"
GREEN="\033[38;5;46m"
RED="\033[38;5;196m"

KEEP_ALIVE=false
PORTNR=0

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

# show usage description
function showUsage {
	echo
	echo -e "Usage:"
	echo
	echo -e "    -t <target>      specify the target either as the bluetooth"
	echo -e "                     MAC address or the name of the device"
	echo -e "    -p               define the port number on which the connection"
	echo -e "                     should be established. default is 0"
	echo -e "                     Note: only specify the number, e.g. 0 and not"
	echo -e "                     /dev/rfcomm0"
	echo -e "    -f               similar to -t but specify a file in which"
	echo -e "                     the target is defined"
	echo
	echo -e "Note:"
	echo -e "If no target is defined, the file 'arduino_ip.txt' is checked by default."
	echo
}

# ino is required for execution of the script! -> http://inotool.org/
hash ino 2>/dev/null || { print "FATAL: Ino required for execution. See http://inotool.org/  Aborting." $RED; exit 1; }

# check for option arguments
while getopts ":t:sf:kp:h" optname; do
	case "$optname" in
		"t")
			TARGET=$OPTARG
			;;
		"p")
			PORTNR=$OPTARG
			;;
		"f")
			if [ -e "./$OPTARG" ]; then
				TARGET=`cat $OPTARG`
			fi
			;;
		"k")
			KEEP_ALIVE=true
			;;
		"h")
			showUsage
			exit
			;;
		*)
			print "Unknown error while processing options, use -h for usage information" $RED
	esac
done

# check if a target is defined, otherwise check the default file 'arduino_ip.txt'
if [ -z $TARGET ]; then
	if [ -e "./arduino_ip.txt" ]; then
		TARGET=`cat arduino_ip.txt`
		if [ -z $TARGET ]; then
			print 'ERROR: arduino_ip.txt does not contain an address!' $RED
			exit 1
		fi
	else
		print 'ERROR: Specify the Bluetooth address either as a Parameter to the script with -t, write it in the default file arduino_ip.txt or specify your own file with -f' $RED
		exit 1
	fi
fi

PORT=/dev/rfcomm$PORTNR

# connect to the robot
. ./connect.sh $TARGET $PORTNR

# start serial monitor
print "start serial monitor ..." $ORANGE
ino serial -p $PORT -b 57600

# if option keep alive not set, close the connection again
if ! $KEEP_ALIVE; then
	sudo rfcomm release $PORTNR 2>/dev/null
	print "connection closed" $ORANGE
fi


