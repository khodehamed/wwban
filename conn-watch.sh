#!/bin/bash
CONF=/etc/wwban.conf
[ -f "$CONF" ] && . "$CONF"
LOG=${LOG:-/var/log/conn-watch.log}
LIMIT_CONN=${LIMIT_CONN:-300}
LIMIT_SYN=${LIMIT_SYN:-80}
BAN_SEC=${BAN_SEC:-10800}

/usr/local/sbin/wwban-setup.sh 2>/dev/null || true

load1=$(awk '{print $1}' /proc/loadavg)
ww=$(ps -eo pcpu,comm | awk '/Waterwall/{s+=$1} END{printf "%d", s+0}')
estab=$(ss -H -tan state established 2>/dev/null | wc -l)
syn=$(ss -H -tn state syn-recv 2>/dev/null | wc -l)

allowed() {
  ipset test wwallow "$1" 2>/dev/null
}

banned=0
while read -r cnt ip; do
  [ -n "$ip" ] || continue
  allowed "$ip" && continue
  [ "$cnt" -ge "$LIMIT_CONN" ] || continue
  if ipset add wwban "$ip" timeout "$BAN_SEC" -exist 2>/dev/null; then
    echo "$(date -Is) BAN $ip conn=$cnt for ${BAN_SEC}s" >> "$LOG"
    banned=$((banned + 1))
  fi
done < <(ss -H -tn state established 2>/dev/null | awk '{
  split($5, r, ":"); rip=r[1]
  if (rip ~ /^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$/) c[rip]++
} END { for (i in c) printf "%d %s\n", c[i], i }')

while read -r cnt ip; do
  [ -n "$ip" ] || continue
  allowed "$ip" && continue
  [ "$cnt" -ge "$LIMIT_SYN" ] || continue
  if ipset add wwban "$ip" timeout "$BAN_SEC" -exist 2>/dev/null; then
    echo "$(date -Is) BAN $ip synrecv=$cnt for ${BAN_SEC}s" >> "$LOG"
    banned=$((banned + 1))
  fi
done < <(ss -H -tn state syn-recv 2>/dev/null | awk '{
  split($5, r, ":"); rip=r[1]
  if (rip ~ /^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$/) c[rip]++
} END { for (i in c) printf "%d %s\n", c[i], i }')

awk -v l="$load1" -v w="$ww" -v e="$estab" -v b="$banned" 'BEGIN{exit !((l+0)>=2.0 || w>=80 || e>=800 || b>0)}' || exit 0
{
  echo "==== $(date -Is) load=$load1 ww_cpu=$ww estab=$estab synrecv=$syn banned=$banned ===="
  echo "wwban:"
  ipset list wwban 2>/dev/null | awk '/^[0-9]+\./{print "  "$0}' | head -40
  echo "top_public_remotes:"
  ss -H -tn 2>/dev/null | awk '
    {
      split($5, a, ":")
      ip=a[1]
      if (ip ~ /^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$/ && ip !~ /^10\./ && ip !~ /^127\./)
        c[ip]++
    }
    END { for (i in c) printf "%7d %s\n", c[i], i }
  ' | sort -nr | head -25
} >> "$LOG"
