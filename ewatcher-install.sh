#!/usr/bin/env bash

EWATCHER_PARAMETER="--nolock"

help() {
	
	echo "========================================================================================"
	echo "--nolock	Suppress DE locker and kill related eToken processes."
	echo "--lock	Just call DE locker and nothing more. PAM pre-installed authentication is expected here."
	echo "--knlock	Kill everything related to the eToken and lock."
	echo "--logout	Kill everything related to the eToken and logout."
	echo "========================================================================================"
	return 0
}

ePckMgmtDetect() { # Returns the package manager is used on the current distro. 
	
	declare -A osInfo;
	osInfo[/etc/centos-release]=yum
	osInfo[/etc/arch-release]=pacman
	osInfo[/etc/gentoo-release]=emerge
	osInfo[/etc/SuSE-release]=zypper
	osInfo[/etc/debian_version]=apt-get
	osInfo[/etc/fedora-release]=dnf

	for f in ${!osInfo[@]}; do
		if [[ -f $f ]]; then
			echo "${osInfo[$f]}"
		fi
	done
	return 0
}

ePackInstall() { # OpenSC, lsof installation and probabaly the latest eToken, ruToken, etc drivers.
				 # parameters here are the packages.	
	local pckmgr=$(ePckMgmtDetect)
	local arr=("$@")
	local i
	for i in "${arr[@]}"; do
		if [ "$pckmgr" == "pacman" ]; then
			sudo $pckmgr -Sy "$i"
		elif [ "$pckmgr" == "emerge" ]; then
			echo -e "Does not support yet, unfortunately. Install the packages manually and launch the installation one more time."
			return 255
		else
			sudo $pckmgr install -y "$i"
		fi
	done
}

pFinder() {
	
	if [[ -e /usr/lib/libeToken.so || -e /usr/lib/x86_64-linux-gnu/opensc-pkcs11.so || -e /usr/lib64/opensc-pkcs11.so ]]; then
	# Need to improve the findings with installed packages and corresponding distro's package manager.
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
	elif [[ -x /usr/bin/curl || -x /bin/curl || -x $(which curl) ]] && [[ -x /usr/bin/unzip || -x /usr/unzip || -x $(which unzip) ]]; then
		curl -o etoken-checker.zip https://github.com/Haxprox/etoken-checker/archive/master.zip && \
		unzip etoken-checker.zip && mv etoken-checker-master etoken-checker
	else
		echo -n "There is no git or curl and unzip command has been found. Would you like to install them now? y/n: "
		while read -r ny; do
			case $ny in
				yes | Yes | Y | y)
					local packages=("git" "curl" "unzip")
					ePackInstall "${packages[@]}"
					break
				;;
				no | No | N | n)
					echo -e "No problem. Do it yourself and start installation one more time."
					exit 255
				;;
				*)
					echo -e "Yes or No?"
					continue
				;;
			esac
		done
	fi
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
					EWATCHER_PARAMETER=$parameter
					break
				;;
				--lock)
					sed -i "/ewatcher.sh/c Exec=bash .config/autostart/ewatcher.sh $parameter &" etoken-checker/src/ewatcher.desktop
					EWATCHER_PARAMETER=$parameter
					break
				;;
				--knlock)
					sed -i "/ewatcher.sh/c Exec=bash .config/autostart/ewatcher.sh $parameter &" etoken-checker/src/ewatcher.desktop
					EWATCHER_PARAMETER=$parameter
					break
				;;				
				--logout)
					sed -i "/ewatcher.sh/c Exec=bash .config/autostart/ewatcher.sh $parameter &" etoken-checker/src/ewatcher.desktop
					EWATCHER_PARAMETER=$parameter
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
}

eAutostartInstall() {
	
	if [[ -d ~/.config/autostart ]]; then
		cp etoken-checker/src/ewatcher.desktop ~/.config/autostart/ && \
		cp etoken-checker/src/ewatcher.sh ~/.config/autostart/ && \
		sudo -k && \
		echo -e "I need root permissions in order install 'ewatcher' sudoer file into '/etc/sudoers.d/' directory" && \
		sleep 1 && \
		chmod 440 etoken-checker/src/ewatcher && \
		sudo cp etoken-checker/src/ewatcher.sh /usr/bin/ && \
		sudo cp etoken-checker/src/ewatcher /etc/sudoers.d/
	else
		echo -e "Unable to find '~/.config/autostart' folder. Please, perform some tweaks or create it yourself and start installation again." && \
		rm -rf etoken-checker
		exit 255
	fi
}

eUnitInstall() {
	
	echo -e "I need 'root' permissions in order to install the files to the appropriate folders."
	sleep 1
	#===================================================================================================================
	sudo -k && \
	sudo cp etoken-checker/src/ewatcher.sh /usr/bin/ && \
	sudo cp etoken-checker/src/ewatcher.service /etc/systemd/system/ && \
	echo -e "The 'ewatcher.sh' and 'ewatcher.service' files have been installed" && \
	#===================================================================================================================
	echo -n "Would you like to start 'ewatcher.service' on boot? y/n: " && \
	while read -r yn; do
		case $yn in
			yes | Yes | Y | y)
				sudo systemctl enable ewatcher.service; sudo systemctl start ewatcher.service
				break
			;;
			no | No | N | n)
				sudo systemctl disable ewatcher.service && \
				echo -n "But would you like to start it now? y/n: "
				while read -r ny; do
					case $ny in
					yes | Yes | Y | y)
						sudo systemctl start ewatcher.service
						break
					;;
					no | No | N | n)
						return 0
					;;
					*)
						echo -e "Yes or No?"
						continue
					;;
					esac
				done
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

eSetup() {
	
	while : ; do
		clear
		echo "=============================================================================="
		lsusb
		echo "=============================================================================="
		echo -e "\e[32mNOTE:\e[0m Insert your USB eToken or SmartCard device and type anything to refresh USB device list."
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
							rm -rf etoken-checker && \
							echo -e "\e[32meToken-agent-watcher has been successfully installed and started.\e[0m" && \
							bash ~/.config/autostart/ewatcher.sh $EWATCHER_PARAMETER &
							break
						;;
						Systemd)
							eClone && \
							eInit $ID --systemd && \
							eUnitInstall && \
							echo -e "\e[32meToken-agent-watcher has been successfully installed!\e[0m"
							rm -rf etoken-checker
							break
						;;
						*)
							echo -e "Wrong, try one more time and do it сonsciously. 1 or 2? I believe in you!"
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
}

if pFinder; then
	eSetup
else
	echo -e "There is no 'lsof' command or 'libeToken.so' and 'opensc-pkcs11.so' files have been found"
	echo -e "The scirpt wont work and to be launched as well. You need to install openSC or eToken package libraries at first"
	echo -n "Would you like to continue 'etocken-watcher' and related packages installation on this process? y/n: "
	while read -r yn; do
		case $yn in
			yes | Yes | Y | y)
				packages=("lsof" "opensc")
				ePackInstall "${packages[@]}" && \
				eSetup
				break
			;;
			no | No | N | n)
				echo -e "Aborted. Install related packages at first manually. Start installation script afterward again."
				exit 255
			;;
			*)
				echo -e "Yes or No?"
				continue
			;;
		esac
	done
fi
