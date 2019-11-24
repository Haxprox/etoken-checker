#!/bin/bash

# Optional '--help', '--pFinder' and '--nolock'  parameters are available.
# The script should be runnable as a daemon with empty parameters.

# Terminating sequence: SSH, OpenVPN, VeraCrypt and locking(none locking) DE (xfce4) session.

LOOPTIMER=3
LSOF=/usr/bin/lsof

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

pKiller() {
	local i
	for i in $(pidof ssh openvpn); do
		kill -9 $i && echo "$i users' session has been killed"
		sleep $LOOPTIMER
	done
	# Veracrypt provides unmount volume possibilities not being as root,
	# just when the volumes mounted as read-only.
	# You need to be in the appropriate group to unmount all volumes.
	veracrypt -d; echo "Veracrypt users' containers have been unmounted"
}

lockFinder() {
	echo "Nothing yet" # Detect DE's locker command. Xfce4 light-locker only supported.
}

eSpy() {
	case "$1" in
		-n | --nolock)
			while : ; do
				sleep $LOOPTIMER
				local etokenID=$(lsusb -d 0529:0600) # Testing single Alading eToken ID. Any card or token should be detected automatically here.
				if [ -n "$etokenID" ]; then
					echo "eToken is online"
					continue
				else
					# Need to have eToken online every time because it kills
					# every processes not being used the eToken either.
					pKiller
					echo "eToken related processes have been killed"
				fi
			done
		;;
		*)
			while : ; do
				sleep $LOOPTIMER
				local etokenID=$(lsusb -d 0529:0600) # Testing single Alading eToken ID. Any card or token should be detected automatically here.
				if [ -n "$etokenID" ]; then
					echo "eToken is online"
					continue
				else
					# Need to have eToken online every time because it kills
					# every processes not being used the eToken either.
					pKiller
					# xflock4 checker should be here in order to get rid
					# doing it every time.
					echo "eToken related processes have been killed and locked"
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
		# Some pretests here
		eSpy --nolock
	;;
	-s | --showp)
		pFinder
	;;
	*)
		# Some pretests here
		eSpy
	;;	
esac

