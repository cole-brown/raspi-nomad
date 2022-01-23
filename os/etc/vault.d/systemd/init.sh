#!/bin/bash

# set options:
#   -e:          exit on first non-zero exit/return code
#   -u:          do not allow unset variables (error on them)
#   -o pipefail: if a command in a pipe chain exits non-zero, fail whole chain
#                with that exit code
set -euo pipefail

# ------------------------------------------------------------------------------
# Debug Funcs
# ------------------------------------------------------------------------------

VAULT_INIT_DEBUG=false

debug_echo() {
    if $VAULT_INIT_DEBUG; then
        echo "$@"
    fi
}


#-------------------------------------------------------------------------------
# Vault Service Initialization Script
#-------------------------------------------------------------------------------

# ------------------------------
# Wait for Vault to finish starting.
# ------------------------------
sleep 5s


# ------------------------------
# Fix ~gpg~ Error:
# ------------------------------
#   "gpg: can't connect to the agent: Read-only file system"

# Create a temp dir for GPG and delete it on script's exit.
export GNUPGHOME=$(mktemp -d)
cp --recursive ~/.gnupg/* "$GNUPGHOME"
trap "rm -rf '$GNUPGHOME'" EXIT


# ------------------------------
# Unseal Vault.
# ------------------------------

KEYS=(
    "$RASPI_VAULT_KEY_0"
    "$RASPI_VAULT_KEY_1"
    "$RASPI_VAULT_KEY_2"
)

for encrypted_key in "${KEYS[@]}"; do
    debug_echo ""
    debug_echo "│ Encrypted:"
    debug_echo "│   $encrypted_key"
    debug_echo "├───────────────────────────────────────────"

    # Decrypt the unseal key.
    debug_echo "│   Decrypted:"
    decrypted_key=$(echo "$encrypted_key" | base64 --decode | gpg -dq)
    if [[ $? -eq 0 ]]; then
        debug_echo "│     [SUCCESS]"
    else
        debug_echo "│     [FAILURE]"
    fi

    # Apply the unseal key.
    debug_echo "│   ┌─────────────────┐"
    debug_echo "│   ├──Vault──Unseal──┤"
    vault operator unseal $decrypted_key
    if [[ $? -eq 0 ]]; then
        debug_echo "│   └────┤SUCCESS├────┘"
    else
        debug_echo "│   └────┤FAILURE├────┘"
    fi
    debug_echo "└──"
done


# ------------------------------
# Output something for checking in the systemd logs?
# ------------------------------
# Find "Sealed       <bool>", trim down.
sealed=$(vault status | grep "Sealed" | tr -s ' ' | sed 's/Sealed/Sealed:/')
if [[ "$sealed" == *true ]]; then
    echo -e "[init:FAILURE] Vault $sealed"
else
    echo -e "[init:SUCCESS] Vault $sealed"
fi
