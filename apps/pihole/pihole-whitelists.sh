#!/usr/bin/env bash

# -o pipefail = set exit code of a sequence of piped commands to an error if any of them errored
# -e          = exit on first error
set -eo pipefail

# ------------------------------------------------------------------------------
# Whitelist Links
# ------------------------------------------------------------------------------
# Most of these are from:
#   https://discourse.pi-hole.net/t/commonly-whitelisted-domains/212


verbose=false

# ------------------------------------------------------------------------------
# Helper Funcs
# ------------------------------------------------------------------------------

usage () {
    cat <<EOF 1>&2
Usage: $0 [-h] [-v]
  Run a bunch of Pi-Hole whitelist commands.

  Options:
    -h
       Displays this help/usage message.
    -v
       Print some output messages.
EOF
}

parse_cli() {
    while getopts ":hv" option; do
        case $option in
            h) # Asked to display help/usage, so return 'ok'.
                usage
                exit 0
                ;;

            v) # Verbose
                verbose=true
                ;;

            *) # Unknown option; return error code.
                echo
                echo "Unknown option flag '$option'."
                echo "------------------------------"
                echo
                usage
                exit 1
                ;;
        esac
    done
    shift $((OPTIND-1))
}


print_title() {
    local title="$1"
    if ! $verbose; then
        return 0
    fi

    echo
    echo "┌───────────────────────────────────────────────────────────────────────────────"
    echo "│ $title"
    echo "└───────────────────────────────────────────────────────────────────────────────"

    return 0
}


print_section() {
    local section="$1"
    if ! $verbose; then
        return 0
    fi

    echo
    echo "┌───────────────────────────────────────"
    echo "│ $section"
    echo "└───────────────────────────────────────"

    return 0
}


pihole_whitelist() {
    if $verbose; then
        set -x
    fi

    # Force exit of script if a whitelist command goes wrong.
    pihole -w $@ || exit 1

    { set +x; } >/dev/null 2>&1
}


#-------------------------------------------------------------------------------
# Phones
#-------------------------------------------------------------------------------

whitelist_phones() {
    print_section "Whitelist: Phones"

    # ------------------------------
    # Android
    # ------------------------------

    # Google Play
    pihole_whitelist android.clients.google.com

    # ------------------------------
    # iOS
    # ------------------------------

    # Gmail (iOS app won't connect without this?)
    pihole_whitelist googleapis.l.google.com

    # ------------------------------
    # "Captive-Portal" / Internet Connectivity tests
    # ------------------------------

    # Android/Chrome
    pihole_whitelist connectivitycheck.android.com android.clients.google.com clients3.google.com connectivitycheck.gstatic.com

    # Windows/Microsoft
    pihole_whitelist msftncsi.com www.msftncsi.com ipv6.msftncsi.com

    # iOS/Apple
    pihole_whitelist captive.apple.com gsp1.apple.com www.apple.com www.appleiphonecell.com
}

#-------------------------------------------------------------------------------
# OS / Apps
#-------------------------------------------------------------------------------

whitelist_os () {
    print_section "Whitelist: OS"

    # Android OS Updates?
    pihole_whitelist appspot-preview.l.google.com

    # Windows 10 updates
    pihole_whitelist sls.update.microsoft.com.akadns.net fe3.delivery.dsp.mp.microsoft.com.nsatc.net tlu.dl.delivery.mp.microsoft.com
}

whitelist_apps() {
    print_section "Whitelist: Apps"

    # Microsoft Store
    pihole_whitelist dl.delivery.mp.microsoft.com geo-prod.do.dsp.mp.microsoft.com displaycatalog.mp.microsoft.com

    # Edge Browser Updates
    pihole_whitelist msedge.api.cdp.microsoft.com

    # Microsoft Office
    pihole_whitelist officeclient.microsoft.com

    # Google Chrome / Ubuntu
    pihole_whitelist dl.google.com

    # Spotify
    pihole_whitelist spclient.wg.spotify.com apresolve.spotify.com

    # Spotify on TVs
    pihole_whitelist api-tv.spotify.com

    # Plex Domains
    pihole_whitelist plex.tv tvdb2.plex.tv pubsub.plex.bz proxy.plex.bz proxy02.pop.ord.plex.bz cpms.spop10.ams.plex.bz meta-db-worker02.pop.ric.plex.bz meta.plex.bz tvthemes.plexapp.com.cdn.cloudflare.net tvthemes.plexapp.com 106c06cd218b007d-b1e8a1331f68446599e96a4b46a050f5.ams.plex.services meta.plex.tv cpms35.spop10.ams.plex.bz proxy.plex.tv metrics.plex.tv pubsub.plex.tv status.plex.tv www.plex.tv node.plexapp.com nine.plugins.plexapp.com staging.plex.tv app.plex.tv o1.email.plex.tv  o2.sg0.plex.tv dashboard.plex.tv

    # Domains used by Plex
    pihole_whitelist gravatar.com # custom login pictures
    pihole_whitelist thetvdb.com # metadata for tv series
    pihole_whitelist themoviedb.com # metadata for movies
    pihole_whitelist chtbl.com # iHeart radio/Plex Podcast

    # Dropbox
    pihole_whitelist dl.dropboxusercontent.com ns1.dropbox.com ns2.dropbox.com

    # Firefox Tracking Protection
    # May or may not be blocked due to over-eager "tracking" regexes.
    pihole_whitelist tracking-protection.cdn.mozilla.net
}


# ------------------------------------------------------------------------------
# Websites
# ------------------------------------------------------------------------------

whitelist_websites() {
    print_section "Whitelist: Websites"

    # Google Fonts
    pihole_whitelist gstaticadssl.l.google.com

    # Google Maps
    pihole_whitelist clients4.google.com
    pihole_whitelist clients2.google.com

    # Bing Maps
    pihole_whitelist dev.virtualearth.net ecn.dev.virtualearth.net t0.ssl.ak.dynamic.tiles.virtualearth.net t0.ssl.ak.tiles.virtualearth.net

    # YouTube History
    pihole_whitelist s.youtube.com
    pihole_whitelist video-stats.l.google.com

    # website placeholder images
    pihole_whitelist placehold.it placeholdit.imgix.net

    # Lowes "Secure Checkout"
    pihole_whitelist assets.adobedtm.com

    # Home Depot "Secure Checkout"
    pihole_whitelist nexus.ensighten.com
}


#-------------------------------------------------------------------------------
# Gaming
#-------------------------------------------------------------------------------

whitelist_games() {
    print_section "Whitelist: Games"

    # Grand Theft Auto V
    pihole_whitelist prod.telemetry.ros.rockstargames.com
}


# ------------------------------
# Xbox
# ------------------------------

whitelist_xbox() {
    print_section "Whitelist: Xbox"

    # Xbox OS Update?
    pihole_whitelist assets1.xboxlive.com

    # Xbox Live
    pihole_whitelist clientconfig.passport.net

    # Xbox Live Achievements
    pihole_whitelist v10.events.data.microsoft.com
    pihole_whitelist v20.events.data.microsoft.com

    # Xbox Live Messaging
    pihole_whitelist client-s.gateway.messenger.live.com

    # Store App on Series X/S
    pihole_whitelist arc.msn.com

    # EA Play on Xbox
    pihole_whitelist activity.windows.com

    # "Full Functionality" (IDK)
    pihole_whitelist xbox.ipv6.microsoft.com device.auth.xboxlive.com www.msftncsi.com title.mgt.xboxlive.com xsts.auth.xboxlive.com title.auth.xboxlive.com ctldl.windowsupdate.com attestation.xboxlive.com xboxexperiencesprod.experimentation.xboxlive.com xflight.xboxlive.com cert.mgt.xboxlive.com xkms.xboxlive.com def-vef.xboxlive.com notify.xboxlive.com help.ui.xboxlive.com licensing.xboxlive.com eds.xboxlive.com www.xboxlive.com v10.vortex-win.data.microsoft.com settings-win.data.microsoft.com
}


# ------------------------------
# PC Master Race
# ------------------------------

whitelist_pcmr() {
    print_section "Whitelist: PC Master Race"

    # Epic Games
    pihole_whitelist tracking.epicgames.com

    # Origin (save game sync)
    pihole_whitelist cloudsync-prod.s3.amazonaws.com
}


# ------------------------------
# PlayStation
# ------------------------------

whitelist_playstation() {
    print_section "Whitelist: PlayStation"

    # PS5 "Recently Played" and Trophies
    pihole_whitelist telemetry-console.api.playstation.com
}


# ------------------------------------------------------------------------------
# Run Everything.
# ------------------------------------------------------------------------------

whitelists() {
    print_title "Whitelist Common Functionality"

    # Any `pihole_whitelist' func in any of these will `exit 1` if it fails.
    whitelist_phones
    whitelist_os
    whitelist_apps
    whitelist_websites
    whitelist_games
    whitelist_xbox
    whitelist_pcmr
    whitelist_playstation

    print_title "Done."
}


# ------------------------------------------------------------------------------
# Script
# ------------------------------------------------------------------------------

parse_cli
whitelists
