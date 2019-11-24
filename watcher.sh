#!/bin/bash

# Optional '--help', '--processFinder' and '--nolock'  parameters are available.
# The script should be runnable as a daemon with empty parameters.

# Terminating sequence: SSH, OpenVPN, VeraCrypt and locking(none locking)

ETOKENID	= $(lsusb -d 0529:0600) # Testing single Alading eToken ID
LOOPTIMER	= 3

help() {
	echo "Usage: $0 [option...] {--help | --nolock | --showp}"
    echo
    echo "-h, --help	show this dialog"
    echo "-s  --showp	show processes use eToken"
    echo "-n, --nolock	suppress DE locker and don't lock current session"
    echo
    exit 1
}

processFinder() {
	local pnames=$(lsof /usr/lib/libeToken.so | cut -d' ' -f 1-5)
	echo "$pnames"
}

etokenSpy() { # here is parameter to suppress locker session
	case "$1" in
		-n | --lock)
			while : ; do
				if ($ETOKENID); then
					sleep $LOOPTIMER
					;
				else
					
				fi
			done
		;;
		*)
			while : ; do
				//
				if ($ETOKENID); then
					sleep $LOOPTIMER
					;
				else
					
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
		etokenSpy --nolock
	;;
	-s | --showp)
		processFinder
	;;
	*)
		etokenSpy
	;;	
esac

