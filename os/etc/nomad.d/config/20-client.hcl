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

  #-----------------------------------------------------------------------------
  # Volumes BEGIN
  #-----------------------------------------------------------------------------
  # Make sure to read the NOTE, at "Volumes END".

  #------------------------------
  # Volumes, Data: General Files
  #------------------------------

  # Used by Plex.
  host_volume "files-temp" {
    path      = "/tmp"
    read_only = false
  }

  # Root directory for (most) media.
  #   - Media library is at "library/streaming/"
  host_volume "files-media" {
    path      = "/mnt/nfs/media"
    read_only = false
  }

  host_volume "files-bree" {
    path      = "/mnt/nfs/bree"
    read_only = true
  }

  #------------------------------
  # Volumes, Config: pihole
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
  # Volumes, Config (Media Server): Plex Media Server
  #------------------------------

  host_volume "plex-config" {
    path      = "/srv/nomad/plex/config"
    read_only = false
  }

  #------------------------------
  # Volumes, Config (Torrent): Jackett
  #------------------------------

  host_volume "jackett-config" {
    path      = "/srv/nomad/jackett/config"
    read_only = false
  }

  #------------------------------
  # Volumes, Config (Torrent): Qbittorrent
  #------------------------------

  host_volume "qbittorrent-config" {
    path      = "/srv/nomad/qbittorrent/config"
    read_only = false
  }

  # #------------------------------
  # # Volumes, Config: Tailscale VPN
  # #------------------------------
  #
  # host_volume "tailscale-data" {
  #   path      = "/srv/nomad/tailscale/data"
  #   read_only = false
  # }

  # #------------------------------
  # # Volumes, Config (Media Server): Jellyfin
  # #------------------------------
  #
  # host_volume "jellyfin-config" {
  #   path      = "/srv/nomad/jellyfin/config"
  #   read_only = false
  # }

  #-----------------------------------------------------------------------------
  # Volumes END
  #
  # NOTE: Make sure "$GIT_ROOT/ansible/inventory/host_vars/home_2019_raspi4.yaml"
  # has an entry for each of these under `nomad.host_volumes`.
  #
  # Or update Ansible to generate these from that...
  #-----------------------------------------------------------------------------
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
