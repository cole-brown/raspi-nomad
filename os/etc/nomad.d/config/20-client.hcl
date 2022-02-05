#-------------------------------------------------------------------------------
# Nomad Configuration
#-------------------------------------------------------------------------------

#------------------------------
# CHANGE-LOG:
#-----------
# [2021-11-07 11:09:34]
#   Created this file.
# Links:
#   https://janssend.wordpress.com/2020/04/21/nomad-setup/
#   https://www.nomadproject.io/docs/configuration/client
#---
# [2021-11-13 14:15:59]
#   Added 'host_volume' for two pihole volumes.
#------------------------------

client {
  enabled = true

  # Defaults to the default route used.
  # network_interface = "eth0"

  servers = [
    "localhost"
  ]

  server_join {
    retry_join = [
      "localhost"
    ]

    retry_max      = 3
    retry_interval = "15s"
  }

  #------------------------------
  # Volumes: General Files
  #------------------------------

  # Used by Plex.
  host_volume "files-temp" {
    path      = "/tmp"
    read_only = false
  }

  # Used by Plex.
  host_volume "files-media" {
    path      = "/mnt/nfs/media"
    read_only = false
  }

  #------------------------------
  # Volumes: Tailscale VPN
  #------------------------------

  host_volume "tailscale-data" {
    path      = "/srv/nomad/tailscale/data"
    read_only = false
  }

  #------------------------------
  # Volumes: pihole
  #------------------------------

  host_volume "pihole-data" {
    path      = "/srv/nomad/pihole/etc/pihole"
    read_only = false
  }

  host_volume "pihole-dnsmasq" {
    path      = "/srv/nomad/pihole/etc/dnsmasq.d"
    read_only = false
  }

  #------------------------------
  # Volumes: Plex Media Server
  #------------------------------

  host_volume "plex-config" {
    path      = "/srv/nomad/plex/config"
    read_only = false
  }

  #------------------------------
  # Volumes: Jellyfin Media Server
  #------------------------------

  host_volume "jellyfin-config" {
    path      = "/srv/nomad/jellyfin/config"
    read_only = false
  }
}

# Configure Docker.
plugin "docker" {
  config {
    allow_privileged = true
    allow_caps       = ["ALL"]

    volumes {
      enabled = true
    }
  }
}
