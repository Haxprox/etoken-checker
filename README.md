## eToken Agent checker

Background bash process is watching for eToken USB serial status and makes decision for killing all processes that were authorized by the eToken or any smart-card device.

The script covers for terminating the next processes: Unmount VeraCrypt crypted volumes, OpenVPN and SSH disconnecting sessions, screenlocker caller.
