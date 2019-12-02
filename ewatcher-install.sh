#!/usr/bin/env bash

help() {
	
	echo "==============================================================="
	echo "--nolock	Suppress DE locker and kill related eToken processes."
	echo "--lock	Just call DE locker and nothing more."
	echo "--knlock	Kill everything related to the eToken and lock."
	echo "--logout	Kill everything related to the eToken and logout."
	echo "==============================================================="
	exit 0
}

eClone() {

	if [[ -x /usr/bin/git || -x /bin/git || -x $(which git) ]]; then
		git clone https://github.com/Haxprox/etoken-checker
	elif [[ -x /usr/bin/curl || -x /bin/curl || -x $(which curl) ]]; then
		curl -LkSs https://github.com/Haxprox/etoken-checker/archive/master.zip -o etoken-checker.zip
	elif [[ -x /usr/bin/unzip || -x /bin/unzip || -x $(which unzip) ]]; then
		unzip etoken-checker.zip && mv etoken-checker-master etoken-checker
	else
		echo -e "There is no git or curl and unzip command has been found. Plesae install the mentioned applications according to your distro."
		exit 126
	fi
}

eInstall() { # $1 -> ID variable should be here
 
	if [[ -d etoken-checker ]]; then
		sed -i "/etokenID=/c etokenID=$1" etoken-checker/src/ewatcher.sh
		echo -e "\e[91mPlease, select which of existed parameters you want to use:\e[0m"
		help
		select parameter in --nolock --lock --knlock --logout; do
			case $parameter
				--nolock)
					sed -i "/ExecStart=ewatcher.sh/c ExecStart=ewatcher.sh $parameter" etoken-checker/src/ewatcher.service
				;;
				--lock)
					sed -i "/ExecStart=ewatcher.sh/c ExecStart=ewatcher.sh $parameter" etoken-checker/src/ewatcher.service
				;;
				--knlock)
					sed -i "/ExecStart=ewatcher.sh/c ExecStart=ewatcher.sh $parameter" etoken-checker/src/ewatcher.service
				;;				
				--logout)
					sed -i "/ExecStart=ewatcher.sh/c ExecStart=ewatcher.sh $parameter" etoken-checker/src/ewatcher.service
				;;
				*)
					continue
				;;
			esac
		do
		
		# To be continued ...
		
	else
		echo -e "There is no 'etoken-checker' folder has been found."
		exit 126
	fi
}

while : ; do
	clear
	echo "=============================================================================="
	lsusb
	echo "=============================================================================="
	echo -e "Please, specify your current eToken ID from existed ID list. Format \e[91m0000:XXXX\e[0m"
	echo -n "ID="
	read ID
	for i in $(lsusb | awk '{print $6}'); do
		if [[ "$ID" != "$i" ]]; then
			continue
		else
			eClone && eInstall $ID 
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

