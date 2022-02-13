#!/usr/bin/env bash

set -eo pipefail

echo "    ┌─ Update Nomad config files..."

path_upload="/home/main/nomad/etc/config"
if [ -d "$path_upload" ]; then
    cd /home/main/nomad/etc/config
    echo "    ├─ Latest Configs:"
    echo "    ├─────────────────────────────"
    ls -lah
    echo "    ├─────────────────────────────"
else
    echo "    ├─ [FAILURE] Config dir does not exist!"
    echo "    ├─── dir: '$path_upload'"
    exit 1
fi

# Fix Permissions & Ownership.
echo "    ├─ Update permissions & ownership..."
chmod u=rw,g=r,o= *.hcl
sudo chown root:root *.hcl

# Move into place.
echo "    ├─ Move into place..."
sudo mv *.hcl /etc/nomad.d/config

# Reload Nomad service to get changes.
echo "    ├─ Reload Nomad service..."
sudo systemctl reload nomad

echo "    ├─ Nomad Status:"
echo "    ├─────────────────────────────"
sudo systemctl status nomad
echo "    ├─────────────────────────────"

echo "    └─ [SUCCESS] Done."
