#!/bin/bash

# Optional 'help' and 'processFinder' parameters are available.
# The script should be runnable as a daemon with empty parameters.

# - ? - Need to suppress screenlocker with separate parameter? 

etokenID=$(lsusb -d 0529:0600) # Testing single Alading eToken ID
loopTimer=3

help() {
	echo "Usage: $0 [option...] {--help|--nolock|}" >&2
    echo
    echo "-h, --help	show this dialog"
    echo "-s  --showp	show processes use eToken"
    echo "-n, --nolock	suppress DE locker and don't lock current session"
    echo
    exit 1
}

processFinder() {
	local pnames=$(lsof /usr/lib/libeToken.so | cut -d' ' -f1)
	echo "$pnames"
}

etokenSpy() { # here is parameter to suppress locker session
	while :
	do
		sleep $loopTimer
	done
}

case "$1" in
	-h | --help)
		help
	;;
	-n | --nolock)
		etokenSpy 
	;;
	-s | --showp)
		processFinder
	;;
	*)
		etokenSpy
	;;	
esac

