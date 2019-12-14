#!/usr/bin/env bash

help() {
	
	echo "========================================================================================"
	echo "--nolock	Suppress DE locker and kill related eToken processes."
	echo "--lock	Just call DE locker and nothing more. PAM pre-installed authentication is expected here."
	echo "--knlock	Kill everything related to the eToken and lock."
	echo "--logout	Kill everything related to the eToken and logout."
	echo "========================================================================================"
	return 0
}

pFinder() {
	
	if [[ -e /usr/lib/libeToken.so || -e /usr/lib/x86_64-linux-gnu/opensc-pkcs11.so || -e /usr/lib64/opensc-pkcs11.so ]]; then
		return 0
	else
		notify-send "$(date +%H:%M)" "There is no lsof command or 'libeToken.so' and 'opensc-pkcs11.so' files have been found"
		notify-send "$(date +%H:%M)" "Please install openSC or eToken package libraries"
		notify-send "$(date +%H:%M)" "The scirpt wont work and to be launched as well"
		return 255
	fi
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
	local currentUser=$(whoami)
	local ownGroup=$(groups | cut -d' ' -f1)
	if [[ -d etoken-checker ]]; then
		sed -i "/etokenID=/c etokenID=$1" etoken-checker/src/ewatcher.sh && \
		sed -i "s/changeme/$currentUser/" etoken-checker/src/ewatcher && \
		echo -e "\e[91mPlease, select which of the existed parameters you want to use:\e[0m"
		help
		select parameter in --nolock --lock --knlock --logout; do
			if [[ $2 == "--systemd" ]]; then
			case $parameter in
				--nolock)
					sed -i "/ExecStart=ewatcher.sh/c ExecStart=ewatcher.sh $parameter" etoken-checker/src/ewatcher.service && \
					sed -i "/User=/c User=$currentUser" etoken-checker/src/ewatcher.service && \
					sed -i "/Group=/c User=$ownGroup" etoken-checker/src/ewatcher.service && \
					break
				;;
				--lock)					
					sed -i "/ExecStart=ewatcher.sh/c ExecStart=ewatcher.sh $parameter" etoken-checker/src/ewatcher.service && \
					sed -i "/User=/c User=$currentUser" etoken-checker/src/ewatcher.service && \
					sed -i "/Group=/c User=$ownGroup" etoken-checker/src/ewatcher.service && \
					break
				;;
				--knlock)
					sed -i "/ExecStart=ewatcher.sh/c ExecStart=ewatcher.sh $parameter" etoken-checker/src/ewatcher.service && \
					sed -i "/User=/c User=$currentUser" etoken-checker/src/ewatcher.service && \
					sed -i "/Group=/c User=$ownGroup" etoken-checker/src/ewatcher.service && \
					break
				;;				
				--logout)
					sed -i "/ExecStart=ewatcher.sh/c ExecStart=ewatcher.sh $parameter" etoken-checker/src/ewatcher.service && \
					sed -i "/User=/c User=$currentUser" etoken-checker/src/ewatcher.service && \
					sed -i "/Group=/c User=$ownGroup" etoken-checker/src/ewatcher.service && \
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
					sed -i "/ewatcher.sh/c Exec=bash .config/autostart/ewatcher.sh $parameter &" etoken-checker/src/ewatcher.desktop
					break
				;;
				--lock)
					sed -i "/ewatcher.sh/c Exec=bash .config/autostart/ewatcher.sh $parameter &" etoken-checker/src/ewatcher.desktop
					break
				;;
				--knlock)
					sed -i "/ewatcher.sh/c Exec=bash .config/autostart/ewatcher.sh $parameter &" etoken-checker/src/ewatcher.desktop
					break
				;;				
				--logout)
					sed -i "/ewatcher.sh/c Exec=bash .config/autostart/ewatcher.sh $parameter &" etoken-checker/src/ewatcher.desktop
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
	
	if [[ -d ~/.config/autostart ]]; then
		cp etoken-checker/src/ewatcher.desktop ~/.config/autostart/ && \
		cp etoken-checker/src/ewatcher.sh ~/.config/autostart/ && \
		echo -e "I need root permissions in order install 'ewatcher' sudoer file into '/etc/sudoers.d/' directory" && \
		sleep 1 && \
		chmod 440 etoken-checker/src/ewatcher && \
		sudo cp etoken-checker/src/ewatcher /etc/sudoers.d/
	else
		echo -e "Unable to find '~/.config/autostart' folder. Please, perform some tweaks or create it yourself and start installation again." && \
		rm -rf etoken-checker
		exit 0
	fi
	return 0
}

eUnitInstall() {
	
	echo -e "I need 'root' permissions in order to install the files to the appropriate folders."
	sleep 1
	#===================================================================================================================
	sudo cp etoken-checker/src/ewatcher.sh /usr/bin/ && \
	sudo cp etoken-checker/src/ewatcher.service /etc/systemd/system/ && \
	echo -e "The 'ewatcher.sh' and 'ewatcher.service' files have been installed"
	sleep 1
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

INSTALLATION_STATE=0

if pFinder; then
	$INSTALLATION_STATE=1
else
	echo -e "There is no lsof command or 'libeToken.so' and 'opensc-pkcs11.so' files have been found. Would you like to continue the installation process?"
	echo -e "The scirpt wont work and to be launched as well. You need to install openSC or eToken package libraries at first."
	echo -n "Would you like to install 'etocken-watcher' anyway? y/n: "
	while read -r yn; do
		case $yn in
			yes | Yes | Y | y)
				$INSTALLATION_STATE=1
			;;
			no | No | N | n)
				$INSTALLATION_STATE=1
				echo -e "Aborted"
			;;
			*)
				echo -e "Yes or No?"
				continue
			;;
		esac
	done
fi

while [ $INSTALLATION_STATE -eq 1 ]; do

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
			echo -e "Please, specify which of the options service you would like to use:"
			select selector in Autostart Systemd; do
				case $selector in
					Autostart)
						eClone && \
						eInit $ID --autostart && \
						eAutostartInstall && \
						echo -e "\e[32meToken-agent-watcher has been successfully installed. You need to logout and login again!\e[0m"
					;;
					Systemd)
						eClone && \
						eInit $ID --systemd && \
						eUnitInstall && \
						echo -e "\e[32meToken-agent-watcher has been successfully installed!\e[0m"
						break
					;;
					*)
						echo -e "Wrong, try one more time and do it сonsciously. I believe in you!"
						continue
					;;				
				esac
			done
			exit 0
		fi
	done
	clear
	echo -e "Unable to find ID you specified or format is unavailable. Please, try again or insert a new device"
	sleep 2
done
