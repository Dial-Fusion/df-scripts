#!/bin/bash
echo `/usr/bin/find /var/spool/asterisk/monitorDONE -maxdepth 3 -type f -print | wc -l` recordings deleted
/usr/bin/find /var/spool/asterisk/monitorDONE -maxdepth 3 -type f -print | xargs rm -f
echo `/usr/bin/find /var/spool/asterisk/monitorDONE/ORIG -mindepth 1 -maxdepth 1 -type d -print | wc -l` date folders deleted
/usr/bin/find /var/spool/asterisk/monitorDONE/ORIG -mindepth 1 -maxdepth 1 -type d -print | xargs rm -rf
/sbin/fstrim -av