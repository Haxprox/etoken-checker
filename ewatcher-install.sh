#!/usr/bin/env bash

help() {
	
	echo "==============================================================="
	echo "--nolock	Suppress DE locker and kill related eToken processes."
	echo "--lock	Just call DE locker and nothing more. PAM pre-installed authentication expects here."
	echo "--knlock	Kill everything related to the eToken and lock."
	echo "--logout	Kill everything related to the eToken and logout."
	echo "==============================================================="
	return 0
}

eClone() {

	if [[ -x /usr/bin/git || -x /bin/git || -x $(which git) ]]; then
		git clone https://github.com/Haxprox/etoken-checker
	elif [[ -x /usr/bin/curl || -x /bin/curl || -x $(which curl) ]]; then
		curl -LkSs https://github.com/Haxprox/etoken-checker/archive/master.zip -o etoken-checker.zip
	elif [[ -x /usr/bin/unzip || -x /bin/unzip || -x $(which unzip) ]]; then
		unzip etoken-checker.zip && mv etoken-checker-master etoken-checker
	else
		echo -e "There is no git or curl and unzip command has been found. Plesae install the mentioned applications according to your distro."
		exit 126
	fi
}

eInstall() { # $1 -> ID variable should be here
 
	if [[ -d etoken-checker ]]; then
		sed -i "/etokenID=/c etokenID=$1" etoken-checker/src/ewatcher.sh
		echo -e "\e[91mPlease, select which of existed parameters you want to use:\e[0m"
		help
		select parameter in --nolock --lock --knlock --logout; do
			case $parameter in
				--nolock)
					sed -i "/ExecStart=ewatcher.sh/c ExecStart=ewatcher.sh $parameter" etoken-checker/src/ewatcher.service
					break
				;;
				--lock)
					sed -i "/ExecStart=ewatcher.sh/c ExecStart=ewatcher.sh $parameter" etoken-checker/src/ewatcher.service
					break
				;;
				--knlock)
					sed -i "/ExecStart=ewatcher.sh/c ExecStart=ewatcher.sh $parameter" etoken-checker/src/ewatcher.service
					break
				;;				
				--logout)
					sed -i "/ExecStart=ewatcher.sh/c ExecStart=ewatcher.sh $parameter" etoken-checker/src/ewatcher.service
					break
				;;
				*)
					echo -e "Wrong, try one more time and do it сonsciously. I believe in you!"
					continue
				;;
			esac
		done
		#=========================================================================================================
		cp etoken-checker/src/ewatcher.sh /usr/bin/ && cp etoken-checker/src/ewatcher.service /etc/systemd/system/
		#=========================================================================================================
		echo -n "Would you like to start 'ewatcher.service' on boot? y/n: "
		while read -r yn; do
			case $yn in
				yes | Yes | Y | y)
					systemctl enable ewatcher.service; systemctl start ewatcher.service
					break
				;;
				no | No | N | n)
					systemctl disable ewatcher.service
					break
				;;
				*)
					echo -e "Yes or No?"
					continue
				;;
			esac
			break
		done
			
	else
		echo -e "There is no 'etoken-checker' folder has been found."
		exit 126
	fi
}

while : ; do
	clear
	echo "=============================================================================="
	lsusb
	echo "=============================================================================="
	echo -e "Please, specify your current eToken ID from existed ID list. Format \e[91m0000:XXXX\e[0m"
	echo -n "ID="
	read ID
	for i in $(lsusb | awk '{print $6}'); do
		if [[ "$ID" != "$i" ]]; then
			continue
		else
			eClone && eInstall $ID && echo -e "\e[32meToken-agent-watcher has been successfully installed!\e[0m"
			exit 0
		fi
	done
	clear
	echo -e "Unable to find ID you specified or format is unavailable. Please, try again."
	sleep 2
done

