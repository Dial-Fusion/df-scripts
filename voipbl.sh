#!/bin/bash

URL="http://www.voipbl.org/update/"

set -e
echo "Downloading rules from VoIP Blacklist"
wget -qO - $URL -O /tmp/voipbl.txt

echo "Loading rules..."

# Check if rule set exists and create one if required
if ! $(/usr/sbin/ipset list voipbl > /dev/null 2>&1); then
  /usr/sbin/ipset -N voipbl iphash
fi

#Check if rule in iptables
if ! $(/usr/sbin/iptables -w --check INPUT -m set --match-set voipbl src -j DROP > /dev/null 2>&1); then
 /usr/sbin/iptables -I INPUT 1 -m set --match-set voipbl src -j DROP
fi

# Create temporary chain
/usr/sbin/ipset destroy voipbl_temp > /dev/null 2>&1 || true
/usr/sbin/ipset -N voipbl_temp iphash hashsize 131072 maxelem 260000

cat /tmp/voipbl.txt |\
  awk '{print "if ! [[ \""$1"\" =~ ^#$|^0.0.0.0 ]]; then /usr/sbin/ipset -A voipbl_temp \""$1"\" ; fi;"}' | sh

/usr/sbin/ipset swap voipbl_temp voipbl
/usr/sbin/ipset destroy voipbl_temp || true

echo "Done! Rules loaded"
