#!/usr/bin/env bash

set -eo pipefail

echo "Update Nomad config files..."
cd ~/nomad/etc/config
ll *.hcl

# Fix Permissions & Ownership.
echo "  Update permissions & ownership..."
chmod u=rw,g=r,o= *.hcl
sudo chown root:root *.hcl

# Move into place.
echo "  Move into place..."
sudo mv *.hcl /etc/nomad.d/config

# Reload Nomad service to get changes.
echo "  Reload Nomad service..."
sudo service reload nomad

echo "Done."
