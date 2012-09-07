#!/bin/bash

if [ -z $1 ]; then
	echo "FATAL: need to provide an address as parameter"
	exit 1
fi

bluez-simple-agent hci0 $1
