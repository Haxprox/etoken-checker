#!/usr/bin/env bash

#############################################################################################################################################################################
# Script Name	:	ewatcher.sh
# Description	:	Background bash process is watching for eToken USB serial status and makes decision for killing all processes that were authorized by the eToken.
# Terminating sequence: SSH, OpenVPN, VeraCrypt and locking(none locking) DE session.

# Args			:	Optional {'-h | --help', '-s | --showp' and '-n | --nolock'}
# Author		:	Jaroslav Popel
# Email			:	haxprox@gmail.com
#############################################################################################################################################################################

# . - Most probably need to load some configs when systemd daemon will be reviewed.
# Check one more function that just locking and do nothing anymore.

declare -ri LOOPTIMER=5
declare -r LSOF=/usr/bin/lsof

help() {
	echo "Usage: $0 [option...]"
	echo
	echo "-h, --help	show this dialog"
	echo "-s  --showp	show processes use eToken"
	echo "-n, --nolock	suppress DE locker and don't lock current session"
	echo "-l, --lock	Just call DE locker and nothing more"
	echo "-k, --knlock	Kill everyhing depends to the eToken and lock"
	echo
	exit 0
}

pFinder() {
	case "$1" in
		-s | --showp)
			if [ -x $LSOF ] && [ -e /usr/lib/libeToken.so ]; then
				$LSOF /usr/lib/libeToken.so | cut -d' ' -f 1-5
			else
				echo "There is no lsof command or 'libeToken.so' file has been found"
				exit 0
			fi
		;;
		-f | --find)
			if [ -x $LSOF ] && [ -e /usr/lib/libeToken.so ]; then
				$LSOF -t /usr/lib/libeToken.so # OpenSC should be added as well.
			else
				echo "There is no lsof command or 'libeToken.so' file has been found"
				exit 0
			fi
		;;
		*)
			echo "Invalid option"
			exit 0
		;;
	esac
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

eScreenLocker() {
	
	case "$XDG_CURRENT_DESKTOP" in
		XFCE)
			# Some checker here then locking
			#xflock4
		;;
		KDE)
			# Some checker here then locking
			# loginctl "lock-session" or something like similar: "qdbus org.kde.ksmserver /ScreenSaver org.freedesktop.ScreenSaver.Lock"
		;;
		GNOME)
			# Some checker here then locking
			# bus-send --type=method_call --dest=org.gnome.ScreenSaver /org/gnome/ScreenSaver org.gnome.ScreenSaver.Lock
		;;
		MATE)
			# Some checker here then locking
			# mate-screensaver-command -l
		;;
		CINNAMON)
			# Some checker here then locking
			# bash -c "cinnamon-screensaver-command -l; xset dpms force off;"
			# or "cinnamon-screensaver-command -l"
		;;			
	esac
	return 0
}

eAgent() {	
	while : ; do
		local timestamp=$(date +%Y-%m-%d_%H-%M-%S)
		local etokenID=$(lsusb -d 0529:0600)
		# Testing single Alading eToken ID,
		# any card or token should be detected automatically here.
		if [ -n "$etokenID" ]; then
			clear
			echo -e "eToken $etokenID is \e[102monline\e[0m now - $timestamp" # Spinner here?
			sleep $LOOPTIMER
			continue
		else
			case "$1" in
				-n | --nolock)
					if [ $(pFinder -f) ]; then
						pKiller && echo -e "eToken related processes have been killed - \e[102m$timestamp\e[0m"
					fi
				;;
				-l | --lock)
					if [ 1 ]; then # One statement condition in order to execute xflock4(locker) once.
						eScreenLocker && echo -e "eToken is out now. The system has been locked - \e[102m$timestamp\e[0m"
					fi
				;;
				-k | --knlock)
					if [ $(pFinder -f) ]; then
						pKiller && eScreenLocker && echo -e "eToken related processes have been killed and locked - \e[102m$timestamp\e[0m"
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
	-s | --showp)
		pFinder --showp
	;;
	*)
		help
	;;
esac
