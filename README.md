
## eToken-agent-watcher
Background bash process is watching for eToken, Smart card or Yubikey USB serial status and makes a decision for killing all processes that were authorized by any device.
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
**You will be prompted to specify your current eToken, smart card or Yubikey ID, agent parameters and Systemd/Autostart daemon ways.**

**NOTE**: The script is based on `Systemd` and built-in desktop `Autostart` feature. 
`Systemd` way doesn't support desktop notifications. The preferable way is to choose `Autostart` option.

3. Watcher now is deamonized and working. You can now test it by plug/unplug the device. 

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
|	MX-Linux	 |  -  |  -  |  -  |  -  |  A:heavy_check_mark:S❌  |  -  |  -  |
|   Fedora 29	 |  ❔  |A:heavy_check_mark:️S:heavy_check_mark:️|  ❔  |  ❔  |  ❔  |  ❔  |  ❔  |
|   Fedora 30	 |  ❔  |A:heavy_check_mark:️S:heavy_check_mark:️|  ❔  |  ❔  |  ❔  |  ❔  |  ❔  |
|   Fedora 31	 |  ❔  |A:heavy_check_mark:️S:heavy_check_mark:️|  ❔  |  ❔  |  ❔  |  ❔  |  ❔  |
| [xU]buntu 16.04	 |  ❔  |  ❔  |  ❔  |  ❔  |  ❔  |  ❔  |  ❔  |
| [xU]Ubuntu 18.04	 |  A:heavy_check_mark:️S:heavy_check_mark:️  |  ❔  |  ❔  |A:heavy_check_mark:S:heavy_check_mark:|  ❔  |  ❔  |  ❔  |
| [xU]Ubuntu 19.04	 |  ❔  |  ❔  |  ❔  |  ❔  |  ❔  |  ❔  |  ❔  |

:heavy_check_mark: - Means `opensc, lsof, libnotify-bin`, packages can be installed and `~/.config/autostart/` folder is able to be created. The distro supports `Systemd` as the main spawner.

❌ - Means `opensc, lsof, libnotify-bin` packages can't be installed or `~/.config/autostart/` folder is not supported by default. **Additional actions are needed during installation.**
`Systemd` is not supported as the main spawner.

❔ - Means not tested so far.

### Common issues:
```
Unable to create '~/.config/autostart' folder. Please, perform some tweaks or create it yourself and start installation again.
```
The script has detected an missconfiguration with 'autostart' startup folder. It's not predefined by default. Need to create this folder manually or using distro's(DE) tweak tool.

```
... notify-send: command not found
```
Unable to find `libnotify-bin` package. Please, install it manually according to your distro specific.
