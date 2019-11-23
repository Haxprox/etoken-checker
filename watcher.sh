#!/bin/bash

# Optional 'help' and 'processFinder' parameters are available.
# The script should be runnable as a daemon with empty parameters.

# - ? - Need to suppress screenlocker with separate parameter? 

etokenID=$(lsusb -d 0529:0600) # Testing single Alading eToken ID
loopTimer=3

help() {
	
}

processFinder() {
	local pnames=$(lsof /usr/lib/libeToken.so | cut -d' ' -f1)
	echo "$pnames"
}

main() {
	
}
