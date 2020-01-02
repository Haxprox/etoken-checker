
## eToken-agent-watcher
Background bash process is watching for eToken USB serial, smart card or Yubikey status and makes a decision for killing all processes that were authorized by any device.
The script covers the next functionality: Unmount VeraCrypt encrypted volumes, terminating OpenVPN and SSH sessions, Keepass{xc} DB closer, screen locker or logout caller.

## How does it work?
When eToken, smart card or Yubikey is online, the agent is looping within pre-installed looptimer and checking when it will be disconnected. Once it's disconnected, different handlers are being called. Find it by the **--help** command.

**NOTE**: The script expects you're using 2FA for all mentioned feature solutions and impossible to do it without the eToken, Smart card or Yubikey.

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
**You will be prompted to specify your current eToken, smart card or Yubikey ID, agent parameters and systemd/autostart daemon ways.**

**NOTE**: The script is based on `Systemd` and built-in desktop `autostart` feature. 
`Systemd` way doesn't support desktop notifications. The preferable way is to choose `autostart` option.

3. Watcher now is deamonized and working.

## Compatibility

**A** - autostart feature

**S** - systemd daemon

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
|   Bunsenlabs	 |  -  |  -  |  -  |  -  |  -  |  -  |  -  |
|	Mint		 |  -  |  -  |  ❔  |  ❔  |  ❔  |  -  |  -  |
|	Manjaro		 |  ❔  |  ❔  |  ❔  |  ❔  |  ❔  |  ❔  |  ❔  |
|	MX-Linux	 |  -  |  -  |  -  |  -  |  ❔  |  -  |  -  |
|   Fedora 29	 |  ❔  |A✓S✓|  ❔  |  ❔  |  ❔  |  ❔  |  ❔  |
|   Fedora 30	 |  ❔  |A✓S✓|  ❔  |  ❔  |  ❔  |  ❔  |  ❔  |
|   Fedora 31	 |  ❔  |A✓S✓|  ❔  |  ❔  |  ❔  |  ❔  |  ❔  |
| Ubuntu 16.04	 |  ❔  |  ❔  |  ❔  |  ❔  |  ❔  |  ❔  |  ❔  |
| Ubuntu 18.04	 |  ❔  |  ❔  |  ❔  |A✓S✓|  ❔  |  ❔  |  ❔  |
| Ubuntu 19.04	 |  ❔  |  ❔  |  ❔  |  ❔  |  ❔  |  ❔  |  ❔  |

✓ - Means `opensc, lsof`, packages can be installed and `~/.config/autostart/` folder is able to be created. The distro supports `Systemd` as the main spawner.

❌ - Means `opensc, lsof` packages can't be installed or `~/.config/autostart/` folder is not supported by default. **Additional actions are needed during installation.**
`Systemd` is not supported as the main spawner.

❔ - Means not tested so far.

### Common issues:
```
Unable to create '~/.config/autostart' folder. Please, perform some tweaks or create it yourself and start installation again.
```
The script has detected an missconfiguration with 'autostart' startup folder. It's not predefined by default. Need to create this folder manually or using distro's(DE) tweak tool.
