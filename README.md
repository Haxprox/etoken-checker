
## eToken-agent-watcher
Background bash process is watching for eToken USB serial status and makes a decision for killing all processes that were authorized by the eToken or any smart-card device.
The script covers the next functionality: Unmount VeraCrypt encrypted volumes, OpenVPN and SSH disconnecting sessions, screenlocker or logout caller.

## How does it work?
When eToken or smart-card is online, the agent is looping within pre-installed looptimer and checking when it will be disconnected. Once it's disconnected, different handlers are being called. Find it by the '--help' command.

## Usage
### Installation from source:
```
curl -O 
```
### Installation by native distro package manager:
RPM
```

```
DEB
```

```
### Run
- Check the parameters you're going to use and edit 'ewatcher.service' unit.
```
ewatcher.sh --help
```
```
vi /etc/systemd/system/ewatcher.sh
```
- Reload systemd configuration, enable service by automatically on boot and start it.
```
systemctl daemon-reload && systemctl enable ewatcher.service && systemctl start ewatcher.service
```
## Compatibility

Supported OS:

|                | KDE | Gnome 3 | Cinnamon | MATE | xfce4 |
| -------------- | ---- | ----- | ----- | ----- | ----- |
|  Arch Linux    |  ❔  |  ❔  |  ❔  |  ❔  |  ❔  |
|   Centos 8     |  ❌  |  ✅  |  ❔  |  ❔  |  ❔  |
|   CentOS 7     |  ❔  |  ✅  |  ❔  |  ❔  |  ❔  |
|   Debian 8     |  ✅  |  ✅  |  ❔  |  ❔  |  ❔  |
|   Debian 9     |  ❌  |  ✅  |  ❔  |  ❔  |  ❔  |
|   Debian 10    |  ❔  |  ✅  |  ❔  |  ❔  |  ❔  |
|   Fedora 27    |  ❔  |  ✅  |  ❔  |  ❔  |  ❔  |
|   Fedora 28    |  ❔  |  ✅  |  ❔  |  ❔  |  ❔  |
| Ubuntu 16.04   |  ✅  |  ✅  |  ❔  |  ❔  |  ❔  |
| Ubuntu 18.04   |  ❌  |  ✅  |  ❔  |  ❔  |  ❔  |
| Ubuntu 19.04   |  ❌  |  ✅  |  ❔  |  ❔  |  ❔  |

- The script requires `systemd`.
