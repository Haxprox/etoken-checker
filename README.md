## eToken-agent-watcher
Background bash process is watching for eToken USB serial status and makes a decision for killing all processes that were authorized by the eToken or any smart card device.
The script covers the next functionality: Unmount VeraCrypt encrypted volumes, OpenVPN and SSH disconnecting sessions, screen locker or logout callers.

## How does it work?
When eToken or smart card is online, the agent is looping within pre-installed looptimer and checking when it will be disconnected. Once it's disconnected, different handlers are being called. Find it by the '--help' command.

## Usage
### Installation:
- Download installation script
```
curl -O https://raw.githubusercontent.com/Haxprox/etoken-checker/master/ewatcher-install.sh
```
- And run it
```
sudo bash ewatcher-install.sh
```
***You will be prompted to specify your current eToken or smart card ID, agent parameters and systemd unit status.***

- Watcher now is deamonized and working.

## Compatibility

Supported distros and environments:

|                | KDE | Gnome 3 | Cinnamon | MATE | Xfce4 | LXQT | LXDE |
| -------------- | ---- | ----- | ----- | ----- | ----- | ----- | ----- |
|  Arch Linux    |  ❔  |  ❔  |  ❔  |  ❔  |  ❔  |  ❔  |  ❔  |
|   CentOS 8     |  ❔  |  ❔  |  ❔  |  ❔  |  ❔  |  ❔  |  ❔  |
|   CentOS 7     |  ❔  |  ❔  |  ❔  |  ❔  |  ❔  |  ❔  |  ❔  |
|   Debian 8     |  ❔  |  ❔  |  ❔  |  ❔  |  ❔  |  ❔  |  ❔  |
|   Debian 9     |  ❔  |  ❔  |  ❔  |  ❔  |  ❔  |  ❔  |  ❔  |
|   Debian 10    |  ❔  |  ❔  |  ❔  |  ❔  |  ❔  |  ❔  |  ❔  |
|   Fedora 28    |  ❔  |  ❔  |  ❔  |  ❔  |  ❔  |  ❔  |  ❔  |
|   Fedora 29    |  ❔  |  ❔  |  ❔  |  ❔  |  ❔  |  ❔  |  ❔  |
|   Fedora 30    |  ❔  |  ❔  |  ❔  |  ❔  |  ❔  |  ❔  |  ❔  |
|   Fedora 31    |  ❔  |  ❔  |  ❔  |  ❔  |  ❔  |  ❔  |  ❔  |
| Ubuntu 16.04   |  ❔  |  ❔  |  ❔  |  ❔  |  ❔  |  ❔  |  ❔  |
| Ubuntu 18.04   |  ❔  |  ❔  |  ❔  |  ❔  |  ❔  |  ❔  |  ❔  |
| Ubuntu 19.04   |  ❔  |  ❔  |  ❔  |  ❔  |  ❔  |  ❔  |  ❔  |

- The script is based on `systemd`.

✅
❌
