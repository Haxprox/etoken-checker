#!/usr/bin/env bash

#############################################################################################################################################################################
# Script Name	:	ewatcher.sh (ewatcher.service unit)
# Description	:	Background bash process is watching for eToken USB serial status and makes decision for killing all processes that were authorized by the eToken.
# Terminating	:	SSH(1) : OpenVPN{1} -> VeraCrypt{2} -> locking(none locking){3} or logout{3} with saving DE session.
# Args			:	Optional { '-h | --help', '-s | --showp', '-n | --nolock', '-l | --lock', '-k | --knlock', '-o | --logout', -c | --check }
# Author		:	Jaroslav Popel
# Email			:	haxprox@gmail.com
#############################################################################################################################################################################

declare -ri LOOPTIMER=5
declare -r LSOF=/usr/bin/lsof
declare -r etokenID=0529:0600 # Find and specify your eToken or smart-card ID here using 'lsusb' command. 

help() {
	
	echo "Usage: $0 [option...]"
	echo
	echo "-h, --help	Show help dialog."
	echo "-s  --showp	Show processes eToken uses."
	echo "-n, --nolock	Suppress DE locker and kill related eToken processes."
	echo "-l, --lock	Just call DE locker and nothing more. PAM pre-installed authentication is expected here."
	echo "-k, --knlock	Kill everything related to the eToken and lock."
	echo "-o, --logout	Kill everything related to the eToken and logout."
	echo "-c, --check	Check whether the libraries are pre-installed."
	echo
	return 0
}

pFinder() { # Show and find processes being used "libeToken.so" or "OpenSC".
	
	case "$1" in
		-s | --showp)
				$LSOF /usr/lib/libeToken.so /usr/lib/x86_64-linux-gnu/opensc-pkcs11.so /usr/lib64/opensc-pkcs11.so 2> /dev/null | cut -d' ' -f 1-5
		;;
		-f | --find)
				$LSOF -t /usr/lib/libeToken.so /usr/lib/x86_64-linux-gnu/opensc-pkcs11.so /usr/lib64/opensc-pkcs11.so 2> /dev/null
		;;
		-c | --check)
			if [[ -e /usr/lib/libeToken.so || -e /usr/lib/x86_64-linux-gnu/opensc-pkcs11.so || -e /usr/lib64/opensc-pkcs11.so ]]; then
				return 0
			else
				notify-send "$(date +%H:%M)" "There is no lsof command or 'libeToken.so' and 'opensc-pkcs11.so' files have been found"
				notify-send "$(date +%H:%M)" "Please install openSC or eToken package libraries"
				notify-send "$(date +%H:%M)" "The scirpt wont work and to be launched as well"
				return 255
			fi
		;;
		*)
			echo "\e[102mInvalid option\e[0m"
			return 255
		;;
	esac
}

eSaveSession() { # Execute save session command for each DE only once before 'eAgent' lopping. 
				 # Pre-test here at first in order to make sure all commands are available
	echo -e "nothing yet here". # Soon
	return 0
}

pKiller() { # Process killer
	
	local i
	for i in $(pFinder -f); do
		if sudo kill $i; then
			notify-send "$(date +%H:%M)" "$i user process session has been killed"
		else
			notify-send "$(date +%H:%M)" "Permission denied. Need to be root to kill $i"
			return 255
		fi
		sleep 1
	done
	
	if [[ -e /usr/bin/keepassxc && $(pidof keepassxc) ]]; then
		sudo kill $(pidof keepassxc) && notify-send "$(date +%H:%M)" "Keepassxc password manager has been killed"
	fi
		
	if [[ -e /usr/bin/veracrypt && $(pidof veracrypt) ]]; then
		sudo veracrypt -d && notify-send "$(date +%H:%M)" "Veracrypt user's containers have been unmounted"
	fi
	return 0
}

eScreenLocker() { # Session locker or logout caller
	
	local -i i=5
	while [[ $i -ne 0 ]]; do
		notify-send "The locker hadler will start at $i"
		if [[ $i -eq 1 ]]; then
			case "$1" in
				-o | --logout)
					notify-send "$(date +%H:%M)" "Logout";
					sleep 1
					sudo loginctl terminate-user $(whoami)
				;;					
				*)
					notify-send "$(date +%H:%M)" "Locked"
					sleep 1
					for j in $(loginctl list-sessions | grep seat | awk '{print $1}'); do 
						sudo loginctl lock-session $j
					done
				;;
			esac
			break
		fi
		sleep 1
		i=$((i-1))
	done
	return 0
}

eAgent() { # Main function
	
	local -i LOCKER_STATE=0
	while : ; do
		if [[ $(lsusb -d $etokenID) ]]; then
			sleep $LOOPTIMER
			if [[ $LOCKER_STATE != 0 ]]; then
				LOCKER_STATE=0;
			fi
			continue # Is it a great security idea to have automatic actions when the device is online? Hmmmm ...
					 # Will see ...
		else
			case "$1" in
				-n | --nolock)
					if [[ $LOCKER_STATE == 0 ]]; then
						LOCKER_STATE=1
						pKiller
					fi
				;;
				-l | --lock)
					if [[ $LOCKER_STATE == 0 ]]; then
						LOCKER_STATE=1
						eScreenLocker
					fi
				;;
				-k | --knlock)
					if [[ $LOCKER_STATE == 0 ]]; then
						LOCKER_STATE=1
						pKiller; eScreenLocker
					fi
				;;
				-o | --logout)
					if [[ $LOCKER_STATE == 0 ]]; then
						LOCKER_STATE=1
						pKiller; eScreenLocker --logout
					fi
				;;
				*)
					echo "\e[102mInvalid option\e[0m"
					exit 255
				;;
			esac
		fi
		sleep $LOOPTIMER
	done
	return 0
}

case "$1" in
	-h | --help)
		help
	;;
	-n | --nolock)
		if pFinder --check; then # Check whether the libraries are pre-installed.
			eAgent --nolock
		else
			echo -e "$(date +%H:%M)" "There is no lsof command or 'libeToken.so' and 'opensc-pkcs11.so' files have been found" && \
			echo -e "$(date +%H:%M)" "Please install openSC or eToken package libraries" && \
			echo -e "$(date +%H:%M)" "The scirpt wont work and to be launched as well"
			exit 255
		fi
	;;
	-l | --lock)
		if pFinder --check; then
			eAgent --lock
		else
			echo -e "$(date +%H:%M)" "There is no lsof command or 'libeToken.so' and 'opensc-pkcs11.so' files have been found" && \
			echo -e "$(date +%H:%M)" "Please install openSC or eToken package libraries" && \
			echo -e "$(date +%H:%M)" "The scirpt wont work and to be launched as well"
			exit 255
		fi
	;;
	-k | --knlock)
		if pFinder --check; then
			eAgent --knlock
		else
			echo -e "$(date +%H:%M)" "There is no lsof command or 'libeToken.so' and 'opensc-pkcs11.so' files have been found" && \
			echo -e "$(date +%H:%M)" "Please install openSC or eToken package libraries" && \
			echo -e "$(date +%H:%M)" "The scirpt wont work and to be launched as well"
			exit 255
		fi
	;;
	-o | --logout)
		if pFinder --check; then
			# eSaveSession
			eAgent --logout
		else
			echo -e "$(date +%H:%M)" "There is no lsof command or 'libeToken.so' and 'opensc-pkcs11.so' files have been found" && \
			echo -e "$(date +%H:%M)" "Please install openSC or eToken package libraries" && \
			echo -e "$(date +%H:%M)" "The scirpt wont work and to be launched as well"
			exit 255
		fi
	;;
	-s | --showp)
		pFinder --showp
	;;
	-c | --check)
		pFinder --check
	;;
	*)
		help
	;;
esac
