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

KEYS=(
    "$RASPI_VAULT_KEY_0"
    "$RASPI_VAULT_KEY_1"
    "$RASPI_VAULT_KEY_2"
)

for key in "${KEYS[@]}"; do
    vault operator unseal $key
done

sealed=$(vault status | grep "Sealed")
echo "Vault $sealed"
