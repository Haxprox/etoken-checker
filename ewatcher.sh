#!/usr/bin/env bash

#############################################################################################################################################################################
# Script Name	:	ewatcher.sh
# Description	:	Background bash process is watching for eToken USB serial status and makes decision for killing all processes that were authorized by the eToken.
# Terminating sequence: SSH, OpenVPN, VeraCrypt and locking(none locking) DE session.

# Args			:	Optional { '-h | --help', '-s | --showp', '-n | --nolock', '-l | --lock', '-k | --knlock', '-o | --logout' }
# Author		:	Jaroslav Popel
# Email			:	haxprox@gmail.com
#############################################################################################################################################################################

# . - Most probably need to load some configs when systemd daemon will be reviewed. {1}
# rpm and deb packages are needed {2}

declare -ri LOOPTIMER=5
declare -r LSOF=/usr/bin/lsof

help() {
	
	echo "Usage: $0 [option...]"
	echo
	echo "-h, --help	show the dialog"
	echo "-s  --showp	show processes eToken uses"
	echo "-n, --nolock	suppress DE locker and don't lock current session"
	echo "-l, --lock	Just call DE locker and nothing more"
	echo "-k, --knlock	Kill everyhing related to the eToken and lock"
	echo "-o, --logout	Kill everyhing related to the eToken and logout"
	echo
	exit 0
}

pFinder() { # Show and find processes being used "libeToken.so" or "OpenSC".
	
	case "$1" in
		-s | --showp)
			if [[ -x $LSOF ]] && [[ -e /usr/lib/libeToken.so ]]; then
				$LSOF /usr/lib/libeToken.so | cut -d' ' -f 1-5
			else
				echo "There is no lsof command or \e[102mlibeToken.so\e[0m file has been found"
				exit 0
			fi
		;;
		-f | --find)
			if [[ -x $LSOF ]] && [[ -e /usr/lib/libeToken.so ]]; then
				$LSOF -t /usr/lib/libeToken.so # OpenSC should be added as well.
			else
				echo "There is no lsof command or \e[102mlibeToken.so\e[0m file has been found"
				exit 0
			fi
		;;
		*)
			echo "Invalid option"
			exit 0
		;;
	esac
}

eSaveSession { # Execute save session command for each DE only once before 'eAgent' lopping. 
	# Pre-test here at first in order to make sure all commands are available
}

pKiller() { # Process killer
	
	local i
	for i in $(pFinder -f); do
		if kill $i; then
			echo -e "\e[41m$i\e[0m users' session has been killed"
		else
			echo -e "Permission denied. Need to be root to kill \e[41m$i\e[0m"
			return 126
		fi
		sleep 1
	done
	
	if [[ $(pidof veracrypt) ]]; then
		veracrypt -d && echo -e "Veracrypt users' containers have been unmounted"
	fi
	return 0
}

eScreenLocker() { # Locker and(or) logout
	
	local i=0
	while [ i$ -ne 5 ] ; do	
		echo -e "The locker hadler will start at \e[102m$i\e[0m"
		if [ $i -eq 5 ]; then
			case "$1" in
				-o | --logout)
					echo -e "Logout"; loginctl terminate-user $LOGNAME
				;;					
				*)
					echo -e "Locked"
					for i in $(loginctl list-sessions | grep $(whoami) | awk '{print $1}'); do 
						loginctl lock-session $i
					done
				;;
			esac
		i=$((i+1))
		sleep 1
	done
	return 0
}

eAgent() {
	
	while : ; do
		local timestamp=$(date +%Y-%m-%d_%H-%M-%S)
		local etokenID=$(lsusb -d 0529:0600)
		# Testing single Alading eToken ID,
		# any card or token should be detected automatically here.
		if [[ -n $etokenID ]]; then
			clear; echo -e "eToken $etokenID is \e[102monline\e[0m now - $timestamp" # Spinner here?
			sleep $LOOPTIMER
			continue
		else
			case "$1" in
				-n | --nolock)
					if [[ $(pFinder -f) ]]; then
						pKiller && echo -e "eToken related processes have been killed - \e[102m$timestamp\e[0m"
					fi
				;;
				-l | --lock)
				# One statement condition in order to execute locker once.
				# Unable to control this SHIT!!111 but it make sense to have session $LOOPTIMER locked or
				# locked all the time
						clear; eScreenLocker && echo -e "eToken is out now. The system has been locked - \e[102m$timestamp\e[0m"
				;;
				-k | --knlock)
					if [[ $(pFinder -f) ]]; then
						pKiller; eScreenLocker && echo -e "eToken related processes have been killed and locked - \e[102m$timestamp\e[0m"
					fi
				-o | --logout)
						# "eScreenLocker --logout" method for logout. Save session or without one?
						pKiller; eScreenLocker --logout && echo -e "eToken related processes have been killed and logout - \e[102m$timestamp\e[0m"
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
	-o | --logout)
		# Some pretests here
		eSaveSession
		eAgent --logout
	;;
	-s | --showp)
		pFinder --showp
	;;
	*)
		help
	;;
esac
