#!/usr/bin/env bash

help() {
	
	echo "==============================================================="
	echo "--nolock	Suppress DE locker and kill related eToken processes."
	echo "--lock	Just call DE locker and nothing more. PAM pre-installed authentication being expected here."
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
	return 0
}

eInit() { # $1 -> ID variable should be here
		  # $2 -> aurostart or systemd
	if [[ -d etoken-checker ]]; then
		sed -i "/etokenID=/c etokenID=$1" etoken-checker/src/ewatcher.sh
		echo -e "\e[91mPlease, select which of existed parameters you want to use:\e[0m"
		help
		select parameter in --nolock --lock --knlock --logout; do
			if [[ $2 == "--systemd" ]]; then
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
			elif [[ $2 == "--autostart" ]]; then
			case $parameter in
				--nolock)
					sed -i "/Exec=~/.config/autostart/ewatcher.sh/c Exec=~/.config/autostart/ewatcher.sh $parameter" etoken-checker/src/ewatcher.auto
					break
				;;
				--lock)
					sed -i "/Exec=~/.config/autostart/ewatcher.sh/c Exec=~/.config/autostart/ewatcher.sh $parameter" etoken-checker/src/ewatcher.auto
					break
				;;
				--knlock)
					sed -i "/Exec=~/.config/autostart/ewatcher.sh/c Exec=~/.config/autostart/ewatcher.sh $parameter" etoken-checker/src/ewatcher.auto
					break
				;;				
				--logout)
					sed -i "/Exec=~/.config/autostart/ewatcher.sh/c Exec=~/.config/autostart/ewatcher.sh $parameter" etoken-checker/src/ewatcher.auto
					break
				;;
				*)
					echo -e "Wrong, try one more time and do it сonsciously. I believe in you!"
					continue
				;;
			esac				
			fi
		done			
	else
		echo -e "There is no 'etoken-checker' folder has been found."
		exit 126
	fi
	return 0
}

eAutostartInstall() {
	# Install autostart service.
	return 0
}

eUnitInstall() { 
	#===================================================================================================================
	sudo cp etoken-checker/src/ewatcher.sh /usr/bin/ && sudo cp etoken-checker/src/ewatcher.service /etc/systemd/system/
	#===================================================================================================================
	echo -n "Would you like to start 'ewatcher.service' on boot? y/n: "
	while read -r yn; do
		case $yn in
			yes | Yes | Y | y)
				sudo systemctl enable ewatcher.service; sudo systemctl start ewatcher.service
				break
			;;
			no | No | N | n)
				sudo systemctl disable ewatcher.service
				break
			;;
			*)
				echo -e "Yes or No?"
				continue
			;;
		esac
		break
	done
	return 0
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
			eClone && eInit $ID --autostart && echo -e "\e[32meToken-agent-watcher has been successfully installed!\e[0m"
			exit 0
		fi
	done
	clear
	echo -e "Unable to find ID you specified or format is unavailable. Please, try again or insert a new device"
	sleep 2
done

