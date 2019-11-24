#!/bin/bash

# Optional '--help', '--pFinder' and '--nolock'  parameters are available.
# The script should be runnable as a daemon with empty parameters.

# Terminating sequence: SSH, OpenVPN, VeraCrypt and locking(none locking) DE (xfce4) session.

ETOKENID	= $(lsusb -d 0529:0600) # Testing single Alading eToken ID
LOOPTIMER	= 3
LSOF		= /usr/bin/lsof

help() {
	echo "Usage: $0 [option...] {--help | --nolock | --showp}"
	echo
	echo "-h, --help	show this dialog"
	echo "-s  --showp	show processes use eToken"
	echo "-n, --nolock	suppress DE locker and don't lock current session"
	echo
}

pFinder() {
	if [ -x $LSOF ] && [ -e /usr/lib/libeToken.so ]; then
		$LSOF /usr/lib/libeToken.so | cut -d' ' -f 1-5
	else
		echo "There is no lsof command or 'libeToken.so' file has been found"
	fi
}

eSpy() {
	case "$1" in
		-n | --nolock)
			while : ; do
				if [ $ETOKENID ]; then
					sleep $LOOPTIMER
					;
				else
					# Do something when the eToken is not present
					killall # Array of processes
					echo "eToken related processes have been killed"
					break
				fi
			done
		;;
		*)
			while : ; do
				if [ $ETOKENID ]; then
					sleep $LOOPTIMER
					;
				else
					# Do something when the eToken is not present
					killall # Array of processes
					echo "eToken related processes have been killed and locked"
					break
				fi
			done
		;;
	esac
}

case "$1" in
	-h | --help)
		help
	;;
	-n | --nolock)
		eSpy --nolock
	;;
	-s | --showp)
		pFinder
	;;
	*)
		eSpy
	;;	
esac

