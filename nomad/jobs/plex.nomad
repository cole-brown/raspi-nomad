#-------------------------------------------------------------------------------
# Plex Docker
#-------------------------------------------------------------------------------
# Plex running on Docker
#
# Links:
#   https://www.nomadproject.io/docs/job-specification/job
#------------------------------

job "plex" {
  # Default is "global".
  # region      = "global"
  datacenters = ["dc-2021-home"]

  # Default is "service".
  # type = "service"

  group "plex" {
    # Defaults to 1.
    # count = 1

    restart {
      attempts = 5
      delay    = "30s"
      # "fail" does not try any more restarts after it fails `attempts` times in the `interval`.
      # "delay" will try restarts again after waiting until the next `interval`.
      # mode     = "fail"
    }

    #------------------------------
    # Network, Ports
    #------------------------------
    # Don't need to define any ports because it's on a macvlan network,
    # so it gets all its own ports.
    # network {
    #   port "http" {
    #     to = "32400"
    #   }
    #   port "dlna-udp" {
    #     to = "1900"
    #   }
    #   port "dlna-tcp" {
    #     to = "32469"
    #   }
    #   port "bonjour" {
    #     to = "5353"
    #   }
    #   port "plex-companion" {
    #     to = "8324"
    #   }
    #   port "gdm-10" {
    #     to = "32410"
    #   }
    #   port "gdm-12" {
    #     to = "32412"
    #   }
    #   port "gdm-13" {
    #     to = "32413"
    #   }
    #   port "gdm-14" {
    #     to = "32414"
    #   }
    # }

    #------------------------------
    # Volumes: Nomad Client Host Volumes
    #------------------------------
    # NFS mount.
    volume "files-media" {
      type      = "host"
      source    = "files-media"
      read_only = false
    }

    # /tmp
    volume "files-temp" {
      type      = "host"
      source    = "files-temp"
      read_only = false
    }

    # /config
    volume "plex-config" {
      type      = "host"
      source    = "plex-config"
      read_only = false
    }

    #------------------------------
    # Task
    #------------------------------
    task "plex" {
      # https://www.nomadproject.io/docs/job-specification/task

      # Docker Container
      driver = "docker"

      # These are Nomad Docker Bind Mounts.
      # Stored wherever the =host_volume= stanza in the Nomad Client config says they should be.
      volume_mount {
        volume      = "plex-config"
        destination = "/config"
        read_only   = false
      }

      volume_mount {
        volume      = "files-media"
        destination = "/media"
        read_only   = false
      }

      # You'll have to set this up to be used for transcoding instead of something under '/config'.
      volume_mount {
        volume      = "files-temp"
        destination = "/transcode"
        read_only   = false
      }

      config {
        #------------------------------
        # General Config
        #------------------------------
        # https://www.nomadproject.io/docs/job-specification/task

        # This is the official Plex Server image.
        #   - It has a separate Dockerfile for the ARM and ARM64 versions, but no tags to grab the ARM images from Docker Hub.
        # image = "plexinc/pms-docker"
        # This Plex Server image is explicitly for ARM64 (with this tag).
        image = "linuxserver/plex:arm64v8-latest"

        # If image's tag is "latest" or omitted, the docker image will always be pulled regardless of this setting.
        # But Plex uses a separate tag for ARM, so try enabling this.
        force_pull = "true"

        # Don't need to define any ports because it's on a macvlan network,
        # so it gets all its own ports.
        # ports = [
        #   "http",
        #   "dlna-udp",
        #   "dlna-tcp",
        #   "bonjour",
        #   "plex-companion",
        #   "gdm-10",
        #   "gdm-12",
        #   "gdm-13",
        #   "gdm-14",
        # ]

        #------------------------------
        # Docker Network: macvlan
        #------------------------------
        # NOTE: Nomad can't manage a macvlan network. It forwards host ports if you do a network
        # stanza with ~to = "<port-num>"~...
        network_mode = "raspi_vnet"
        ipv4_address = "192.168.50.13"

        #------------------------------
        # Misc.
        #------------------------------

        # Hardware transcoding support. Probably don't need? Maybe?
        # privileged = "true"
      }

      env {
        TZ = "US/Pacific"

        # The Docker container is in charge of what version Plex is. Don't auto-update.
        VERSION = "docker"

        # https://docs.linuxserver.io/images/docker-plex#user-group-identifiers
        # If there are file permission issues, set PUID and PGID to the correct integers.
        # See: `id <username>`
        # Think this is running as root, though, so no need?
        #
        # PUID = 1000
        # PGID = 1000

        # For logging your Plex Server into your Plex account.
        #
        # "Optionally you can obtain a claim token from https://plex.tv/claim and input here.
        # Keep in mind that the claim tokens expire within 4 minutes."
        PLEX_CLAIM = "claim-dHUTTBtbNycWAq8stkJr"
      }

      service {
        # port = "http"
        name = "plex"

        # # TODO: If this doesn't work, try http?
        # check {
        #   name     = "Plex TCP Health"
        #   type     = "tcp"
        #   interval = "10s"
        #   timeout  = "2s"
        # }
      }

      #------------------------------
      # Resource Reservations
      #---
      # Try to give Plex a decent amount of resources?
      #
      # These appear to be resource _reservations_ (as opposed to caps), so I think just don't reserve anything.
      # That way I can cram as many nomad jobs as possible in without fiddling around with resources?
      #------------------------------
      # resources {
      #   # main@home-2019-raspi4:/srv/nomad/pihole/etc/pihole$ sudo lscpu | grep -i mhz
      #   # CPU max MHz:                     1500.0000
      #   # CPU min MHz:                     600.0000
      #   cpu = 1000
      #
      #   # main@home-2019-raspi4:/srv/nomad/pihole/etc/pihole$ cat /proc/meminfo | grep -i mem
      #   # MemTotal:        1892528 kB
      #   # MemFree:           47384 kB
      #   # MemAvailable:    1416612 kB
      #   # Shmem:             10556 kB
      #   memory = 1024
      # }
    }
  }
}
