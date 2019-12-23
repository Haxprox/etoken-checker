
## eToken-agent-watcher
Background bash process is watching for eToken USB serial or smart card status and makes a decision for killing all processes that were authorized by the eToken or any smart card device.
The script covers the next functionality: Unmount VeraCrypt encrypted volumes, OpenVPN and SSH disconnecting sessions, Keepass{xc} DB closer, screen locker or logout callers.

## How does it work?
When eToken or smart card is online, the agent is looping within pre-installed looptimer and checking when it will be disconnected. Once it's disconnected, different handlers are being called. Find it by the '--help' command.

**NOTE**: The script expects you're using 2FA for all mentioned feature solutions and impossible to do it without the eToken or smart card.

## Usage
### Installation:
1. Download installation script
```
curl -O https://raw.githubusercontent.com/Haxprox/etoken-checker/master/ewatcher-install.sh
```
2. And run it
```
bash ewatcher-install.sh
```
**You will be prompted to specify your current eToken or smart card ID, agent parameters and systemd/autostart daemon ways.**

**NOTE**: The script is based on `Systemd` and built-in desktop `autostart` feature. 
`Systemd` way doesn't support desktop notifications. The preferable way is to choose `autostart` option.

3. Watcher now is deamonized and working.

## Compatibility

Supported distros and environments:

|                | KDE | Gnome 3 | Cinnamon | MATE | Xfce4 | LXQT | LXDE |
| -------------- | ---- | ----- | ----- | ----- | ----- | ----- | ----- |
|  Arch Linux	 |  ❔  |  ❔  |  ❔  |  ❔  |  ❔  |  ❔  |  ❔  |
|	OpenSuse	 |  ❔  |  ❔  |  ❔  |  ❔  |  ❔  |  ❔  |  ❔  |
|	Elementary	 |  ❔  |  ❔  |  ❔  |  ❔  |  ❔  |  ❔  |  ❔  |
|   CentOS 8	 |  ❔  |  ❔  |  ❔  |  ❔  |  ❔  |  ❔  |  ❔  |
|   CentOS 7	 |  ❔  |  ❔  |  ❔  |  ❔  |  ❔  |  ❔  |  ❔  |
|   Debian 9	 |  ❔  |  ❔  |  ❔  |  ❔  |  ❔  |  ❔  |  ❔  |
|   Debian 10	 |  ❔  |  ❔  |  ❔  |  ❔  |  ❔  |  ❔  |  ❔  |
|	Mint		 |  ❔  |  ❔  |  ❔  |  ❔  |  ❔  |  ❔  |  ❔  |
|	Manjaro		 |  ❔  |  ❔  |  ❔  |  ❔  |  ❔  |  ❔  |  ❔  |
|	MX-Linux	 |  ❔  |  ❔  |  ❔  |  ❔  |  ❔  |  ❔  |  ❔  |
|   Fedora 29	 |  ❔  |  ❔  |  ❔  |  ❔  |  ❔  |  ❔  |  ❔  |
|   Fedora 30	 |  ❔  |  ❔  |  ❔  |  ❔  |  ❔  |  ❔  |  ❔  |
|   Fedora 31	 |  ❔  |  ❔  |  ❔  |  ❔  |  ❔  |  ❔  |  ❔  |
| Ubuntu 16.04	 |  ❔  |  ❔  |  ❔  |  ❔  |  ❔  |  ❔  |  ❔  |
| Ubuntu 18.04	 |  ❔  |  ❔  |  ❔  |  ❔  |  ❔  |  ❔  |  ❔  |
| Ubuntu 19.04	 |  ❔  |  ❔  |  ❔  |  ❔  |  ❔  |  ❔  |  ❔  |

✅ - Means `opensc, lsof`, packages can be installed and `~/.config/autostart/` folder is supported by default.

❌ - Means `opensc, lsof` packages can't be installed or `~/.config/autostart/` folder is not supported by default. Additional actions are needed to continue.

❔ - Means not tested so far.
