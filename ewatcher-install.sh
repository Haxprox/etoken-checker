#!/usr/bin/env bash

# sed '/etokenID=/c etokenID=0000:9999' - change example

# Some draft loop here for correct ID configuration and installation process in general.

while : ; do
	clear
	echo "=============================================================================="
	lsusb
	echo "=============================================================================="
	echo -e "Please, specify your current eToken ID from existed list. Format \e[91m0000:XXXX\e[0m"
	echo -n "ID="
	read ID
	for i in $(lsusb | awk '{print $6}'); do
		if [[ "$ID" != "$i" ]]; then
			continue
		else
			# 1. Specify $ID to etokenID
			# 3. Copy files to the directories
			# 2. Ask for the arguments
			# ... Do all those stuff in order to proper editing and installation.
			# Rewrite README as this task will do everything automacticaly!!!!!
			exit 0
		fi
	done
	clear
	echo -e "Unable to find ID you specified or format is unavailable. Please, try again."
	sleep 2
done

