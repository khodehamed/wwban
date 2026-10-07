#!/bin/bash
set -e
CONF=/etc/wwban.conf
[ -f "$CONF" ] && . "$CONF"
PORTS=${PORTS:-443,8443,2083,2053,2087,2096,7777}
BAN_SEC=${BAN_SEC:-10800}
ALLOW_NETS=${ALLOW_NETS:-"10.0.0.0/8 127.0.0.0/8 172.16.0.0/12 192.168.0.0/16"}

command -v ipset >/dev/null || { echo "ipset نصب نیست"; exit 1; }

ipset create wwban hash:ip timeout "$BAN_SEC" -exist
ipset create wwallow hash:net -exist
for net in $ALLOW_NETS; do
  ipset add wwallow "$net" -exist
done

iptables-save | grep -E -- '--match-set wwban' | sed 's/^-A INPUT //' | while read -r spec; do
  iptables -D INPUT $spec 2>/dev/null || true
done

for proto in tcp udp; do
  iptables -I INPUT 1 -p "$proto" -m set --match-set wwban src -m multiport --dports "$PORTS" -j DROP
done
exit 0
