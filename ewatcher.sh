#!/usr/bin/env bash

#############################################################################################################################################################################
# Script Name	:	ewatcher.sh (ewatcher.service unit)
# Description	:	Background bash process is watching for eToken USB serial status and makes decision for killing all processes that were authorized by the eToken.
# Terminating	:	SSH(1) : OpenVPN{1} -> VeraCrypt{2} -> locking(none locking){3} or logout{3} with saved DE session.
# Args			:	Optional { '-h | --help', '-s | --showp', '-n | --nolock', '-l | --lock', '-k | --knlock', '-o | --logout' }
# Author		:	Jaroslav Popel
# Email			:	haxprox@gmail.com
#############################################################################################################################################################################

declare -ri LOOPTIMER=5
declare -r LSOF=/usr/bin/lsof
declare -r etokenID=0529:0600 # Find and specify your eToken or smart-card ID here with 'lsusb' command. 

help() {
	
	echo "Usage: $0 [option...]"
	echo
	echo "-h, --help	Show help dialog"
	echo "-s  --showp	Show processes eToken uses"
	echo "-n, --nolock	Suppress DE locker and kill related eToken processes"
	echo "-l, --lock	Just call DE locker and nothing more"
	echo "-k, --knlock	Kill everything related to the eToken and lock"
	echo "-o, --logout	Kill everything related to the eToken and logout"
	echo
	exit 0
}

pFinder() { # Show and find processes being used "libeToken.so" or "OpenSC".
	
	case "$1" in
		-s | --showp)
			if [[ -x $LSOF ]] && [[ -e /usr/lib/libeToken.so || -e /usr/lib/x86_64-linux-gnu/opensc-pkcs11.so ]]; then
				$LSOF /usr/lib/libeToken.so /usr/lib/x86_64-linux-gnu/opensc-pkcs11.so | cut -d' ' -f 1-5
			else
				notify-send "$(date +%H:%M)" "There is no lsof command or 'libeToken.so' and 'opensc-pkcs11.so' files have been found"
				notify-send "$(date +%H:%M)" "Please install openSC or eToken package libraries"
				exit 0
			fi
		;;
		-f | --find)
			if [[ -x $LSOF ]] && [[ -e /usr/lib/libeToken.so || -e /usr/lib/x86_64-linux-gnu/opensc-pkcs11.so ]]; then
				$LSOF -t /usr/lib/libeToken.so /usr/lib/x86_64-linux-gnu/opensc-pkcs11.so
			else
				notify-send "$(date +%H:%M)" "There is no lsof command or 'libeToken.so' and 'opensc-pkcs11.so' files have been found"
				notify-send "$(date +%H:%M)" "Please install openSC or eToken package libraries"
				exit 0
			fi
		;;
		*)
			echo "\e[102mInvalid option\e[0m"
			exit 0
		;;
	esac
}

eSaveSession() { # Execute save session command for each DE only once before 'eAgent' lopping. 
				 # Pre-test here at first in order to make sure all commands are available
	echo -e "nothing yet here"
	exit 0
}

pKiller() { # Process killer
	
	local i
	for i in $(pFinder -f); do
		if kill $i; then
			notify-send "$(date +%H:%M)" "$i user process session has been killed"
		else
			notify-send "$(date +%H:%M)" "Permission denied. Need to be root to kill $i"
			return 126
		fi
		sleep 1
	done
	
	if [[ $(pidof veracrypt) ]]; then
		veracrypt -d && notify-send "$(date +%H:%M)" "Veracrypt user's containers have been unmounted"
	fi
	return 0
}

eScreenLocker() { # Session locker and(or) logout
	
	local i=5
	while [[ $i -ne 0 ]]; do
		notify-send "The locker hadler will start at $i"
		if [ $i -eq 1 ]; then
			case "$1" in
				-o | --logout)
					sleep 1
					notify-send "$(date +%H:%M)" "Logout"; loginctl terminate-user $LOGNAME
				;;					
				*)
					notify-send "$(date +%H:%M)" "Locked"
					sleep 1
					for i in $(loginctl list-sessions | grep $(whoami) | awk '{print $1}'); do 
						loginctl lock-session $i
					done
				;;
			esac
		fi
		sleep 1
		i=$((i-1))
	done
	return 0
}

eAgent() { # Main function
	
	while : ; do
		if [[ $(lsusb -d $etokenID) ]]; then
			sleep $LOOPTIMER
			continue
		else
			case "$1" in
				-n | --nolock)
					if [[ $(pFinder -f) ]]; then
						pKiller && notify-send "$(date +%H:%M)" "eToken related processes have been killed"
					fi
				;;
				-l | --lock)
						eScreenLocker
				;;
				-k | --knlock)
					if [[ $(pFinder -f) ]]; then
						pKiller; eScreenLocker
					fi
				;;
				-o | --logout)
					if [[ $(pFinder -f) ]]; then
						pKiller; eScreenLocker --logout
					fi
				;;
				*)
					echo "\e[102mInvalid option\e[0m"
					exit 0
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
		# Some pretests here
		eAgent --nolock
	;;
	-l | --lock)
		# Some pretests here
		eAgent --lock
	;;
	-k | --knlock)
		# Some pretests here
		eAgent --knlock
	;;
	-o | --logout)
		# Some pretests here
		# eSaveSession
		eAgent --logout
	;;
	-s | --showp)
		pFinder --showp
	;;
	*)
		help
	;;
esac
