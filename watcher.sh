#!/bin/bash

# Optional '--help', '--pFinder' and '--nolock'  parameters are available.
# The script should be runnable as a daemon with empty parameters.

# Terminating sequence: SSH, OpenVPN, VeraCrypt and locking(none locking) DE (xfce4) session.

LOOPTIMER=5
LSOF=/usr/bin/lsof

help() {
	echo "Usage: $0 [option...] {--help | --nolock | --showp}"
	echo
	echo "-h, --help	show this dialog"
	echo "-s  --showp	show processes use eToken"
	echo "-n, --nolock	suppress DE locker and don't lock current session"
	echo
	return 0
}

pFinder() {
	if [ -x $LSOF ] && [ -e /usr/lib/libeToken.so ]; then
		$LSOF /usr/lib/libeToken.so | cut -d' ' -f 1-5
	else
		echo "There is no lsof command or 'libeToken.so' file has been found"
		return 126
	fi
}

pKiller() { # Process killer
	local i
	for i in $(pidof ssh openvpn); do
		if ( kill -9 $i ); then
			echo "$i users' session has been killed"
		else
			echo "Permission denied. Need to be root to kill $i"
		fi
		sleep 1
	done
	# Veracrypt provides unmount volume possibilities not being as root,
	# just when the volumes mounted as read-only.
	# You need to be in the appropriate group to unmount all volumes.
	if ( veracrypt -d ); then
		echo "Veracrypt users' containers have been unmounted"
	else
		echo "Permission denied. Need to be root to kill Veracrypt container"
		return 126
	fi
	return 0
}

lockFinder() {
	echo "Nothing yet" # Detect DE's locker command. Xfce4 light-locker only supported.
	return 0
}

eAgent() { # Loop agent. Always stay online and watching for eToken status
	case "$1" in
		-n | --nolock)
			while : ; do
				local timestamp=$(date +%Y-%m-%d_%H-%M-%S)
				local etokenID=$(lsusb -d 0529:0600) # Testing single Alading eToken ID,
				# any card or token should be detected automatically here.
				sleep $LOOPTIMER
				if [ -n "$etokenID" ]; then
					echo "eToken $etokenID is online now - $timestamp"
					continue
				else
					# Need to have eToken online every time because it kills
					# every processes not being used the eToken either.
					pKiller && echo "eToken related processes have been killed - $timestamp"
				fi
			done
		;;
		*)
			while : ; do
				local timestamp=$(date +%Y-%m-%d_%H-%M-%S)
				local etokenID=$(lsusb -d 0529:0600) # Testing single Alading eToken ID,
				# any card or token should be detected automatically here.
				sleep $LOOPTIMER
				if [ -n "$etokenID" ]; then
					echo "eToken $etokenID is online now - $timestamp"
					continue
				else
					# Need to have eToken online every time because it kills
					# every processes not being used the eToken either.
					pKiller && echo "eToken related processes have been killed - $timestamp"
					# xflock4 checker should be here in order to get rid
					# doing it every time.
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
		eAgent --nolock
	;;
	-s | --showp)
		pFinder
	;;
	*)
		# Some pretests here
		eAgent
	;;	
esac

