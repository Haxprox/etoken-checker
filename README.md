## eToken-checker

Background bash process is watching for eToken USB serial status and make decision
for killing all processes that were authorized by the eToken.

Previosly eToken driver provider must be pre-installed and located at '/usr/lib/libeToken.so' directory. 

The script covers the next processes: VeraCrypt crypted volumes and their unmounting, OpenVPN and SSH disconnecting sessions, screenlocker xfce4 caller and PAM auth.
