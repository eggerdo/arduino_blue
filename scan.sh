#!/bin/bash

echo 'Scanning ...'

DEVICE_FILTER=RN42

# scans for bluetooth devices but displays only results from RN42 bluetooth devices
sudo hcitool -i hci0 scan | grep $DEVICE_FILTER