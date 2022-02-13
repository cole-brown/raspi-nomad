#!/usr/bin/env fish
# -*- mode: fish; -*-

set --local _script_path_file (status --current-filename)
pushd (dirname "$_script_path_file") >/dev/null

set --local _script_path_dir (pwd)
popd >/dev/null

set --local _script_file_name (basename "$_script_path_file")


# ------------------------------------------------------------------------------
# Usage
# ------------------------------------------------------------------------------

function usage
    echo "Usage: $_script_file_name [-h] [-u]
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
# Functions
# ------------------------------------------------------------------------------

set --local error_code_local 1
set --local error_code_raspi 2
function error_exit -a exit_code exit_msg
    echo
    echo "────────────────────────────"
    if test -n "$exit_msg"
        echo exit_msg
    else
        echo "[FAILURE] Errored."
    end

    if string match --quiet --regex '\D'
        # We were given something, but it's not an integer.
        echo "   [ERROR] `error_exit` expects an integer for the `exit_code`, got: '$exit_code'"
        exit 1
    else
        exit $exit_code
    end
end


function ok_exit
    echo "[SUCCESS] Done."
    exit 0
end


# ------------------------------------------------------------------------------
# Script
# ------------------------------------------------------------------------------

echo "Push latest Nomad configs..."
echo "────────────────────────────"

cd {$_script_path_dir}"/../../os/etc/nomad.d/config/"
or error_exit $error_code_local

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
or error_exit $error_code_raspi

# Make sure only our HCL files are there...
echo
echo "  [raspi] Clean dir..."
set --local bash_rm "for file in \$(find \"$raspi_home_config\" -iname \"*.hcl\"); do rm \"\$file\"; done"
ssh raspi $bash_rm
or error_exit $error_code_raspi

# Copy the new ones in...
echo
echo "  [local] Copy to raspi..."
scp *.hcl raspi:$raspi_home_config
or error_exit $error_code_raspi

# Stop now?
if test -n "$_flag_upload_only"
    echo
    echo "Upload-only flag set; quitting."
    ok_exit
end


# And tell the raspi to finish up...
echo
echo "  [raspi] Finish config update:"
echo "────────────────────────────"
ssh raspi sudo /etc/nomad.d/scripts/config-update.sh
or error_exit $error_code_raspi
echo "────────────────────────────"

ok_exit
