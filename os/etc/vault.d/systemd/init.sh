#!/bin/bash

# set options:
#   -e:          exit on first non-zero exit/return code
#   -u:          do not allow unset variables (error on them)
#   -o pipefail: if a command in a pipe chain exits non-zero, fail whole chain
#                with that exit code
set -euo pipefail

#-------------------------------------------------------------------------------
# Vault Service Initialization Script
#-------------------------------------------------------------------------------

for key in ${RASPI_VAULT_KEYS[@]}; do
    /usr/local/sbin/vault operator unseal $key
done
