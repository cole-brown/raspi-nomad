#!/usr/bin/env fish
# -*- mode: fish; -*-

set --local _script_file (status --current-filename)
set --local _script_dir (dirname $_script_file)

set --local _script_name (basename _script_file)


# ------------------------------------------------------------------------------
# Usage
# ------------------------------------------------------------------------------

function usage
    echo "Usage: $_script_name [-h] [-u]
Copy the current Nomad config files to the Raspberry Pi, then call a script on
the Pi to updated perms/ownership, put them into their place, and reload the
Nomad service.

  Options:
    -h, --help
       Displays this help/usage message.

    -u, --upload-only
       Do not run the Pi-side script, only upload to the Pi."
    or return
end

# ------------------------------------------------------------------------------
# Parse Options & Args
# ------------------------------------------------------------------------------

# ------------------------------
# Parse Options
# ------------------------------
# Create options using `fish_opt` for clarity.
#   https://fishshell.com/docs/current/cmds/fish_opt.html

# Help
set --local options (fish_opt --short h --long help)

# Upload-Only
set --local options $options (fish_opt --short u --long upload-only)

# Parse options.
#   https://fishshell.com/docs/current/cmds/argparse.html
# To handle errors myself:
#   --name=my_function
# Useful for having sub-commands:
#   --stop-nonopt
argparse --stop-nonopt $options -- $argv

# ------------------------------
# Verify Options
# ------------------------------

# Check for `--help`.
if test -n "$_flag_help"
    usage
    exit 0
end


# ------------------------------------------------------------------------------
# Script
# ------------------------------------------------------------------------------

echo "Push latest Nomad configs..."
echo "────────────────────────────"

cd "{$_script_dir}/../../os/etc/nomad.d/config/"

echo
echo "  [local] Latest Configs:"
echo "────────────────────────────"
ll
echo "────────────────────────────"

# Make sure the dir exists on the Pi.
echo
echo "  [raspi] Ensure dir..."
set --local raspi_home_config "/home/main/nomad/etc/config"
ssh raspi mkdir -p $raspi_home_config

# Make sure only our HCL files are there...
echo
echo "  [raspi] Clean dir..."
ssh raspi rm $raspi_home_config/'*.hcl'

# Copy the new ones in...
echo
echo "  [local] Copy to raspi..."
scp *.hcl raspi:$raspi_home_config

# And tell the raspi to finish up...
echo
echo "  [raspi] Finish config update:"
echo "────────────────────────────"
ssh raspi sudo /etc/nomad.d/scripts/config.update.sh
echo "────────────────────────────"

echo
echo "[SUCCESS] Done."
