#!/bin/bash

# colour assignments, see -> http://linuxtidbits.wordpress.com/2008/08/13/output-color-on-bash-scripts-advanced/
ORANGE="\033[38;5;214m"
GREEN="\033[38;5;46m"
RED="\033[38;5;196m"

SERIAL=false
KEEP_ALIVE=false

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
	echo -e "    -f               similar to -t but specify a file in which"
	echo -e "                     the target is defined"
	echo -e "    -s               starts the serial monitor once upload has"
	echo -e "                     successfully completed"
	echo
	echo -e "Note:"
	echo -e "If no target is defined, the file 'arduino_ip.txt' is checked by default."
	echo
}

# ino is required for execution of the script! -> http://inotool.org/
hash ino 2>/dev/null || { print "FATAL: Ino required for execution. See http://inotool.org/  Aborting." $RED; exit 1; }

# check for option arguments
while getopts ":t:sf:k" optname; do
	case "$optname" in
		"t")
			TARGET=$OPTARG
			;;
		"s")
			SERIAL=true
			;;
		"f")
			if [ -e "./$OPTARG" ]; then
				TARGET=`cat $OPTARG`
			fi
			;;
		"k")
			KEEP_ALIVE=true
			;;
		"?")
			showUsage
			exit
			;;
		*)
			print "Unknown error while processing options" $RED
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

# connect to the robot
. ./connect.sh $TARGET

print "-> connection ok" $GREEN

# build the sketch with ino
print "build sketch ..." $ORANGE
ino build

# check if build process completed successfully
let ERRORLEVEL=$?
if [ $ERRORLEVEL -ne 0 ]; then
	exit $ERRORLEVEL
else
	print "-> build done" $GREEN
fi

# reset the arduino. this works only if the current sketch running on 
# the arduino has a routine which listens for the char r and resets 
# the arduino with a delay of 1 seconds
print "reset arduino ..." $ORANGE
echo r > /dev/rfcomm0  
sleep 1

# initiate upload sequence with ino
print "start upload ..." $ORANGE
ino upload

# check if upload process completed successfully
let ERRORLEVEL=$?
if [ $ERRORLEVEL -ne 0 ]; then
	exit $ERRORLEVEL
else
	print "-> upload done" $GREEN
fi

sleep 1

# if user specified option -s then start the serial monitor
if $SERIAL; then
	print "start serial monitor ..." $ORANGE
	ino serial
fi

# if option keep alive not set, close the connection again
if ! $KEEP_ALIVE; then
	sudo rfcomm release all > /dev/null
	print "connection closed" $ORANGE
fi

