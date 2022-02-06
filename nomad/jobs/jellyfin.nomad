#-------------------------------------------------------------------------------
# Jellyfin Docker
#-------------------------------------------------------------------------------
# Jellyfin Media Server running on Docker
#
# Links:
#   https://www.nomadproject.io/docs/job-specification/job
#
#   https://www.ctrl.blog/entry/jellyfin-vs-plex.html
#
#   https://hub.docker.com/r/linuxserver/jellyfin
#   https://gitea.redalder.org/RedAlder/systems/commit/a3b7c0161cac65d97e351ce79892a2df43bdf660
#------------------------------

job "jellyfin" {
  # Default is "global".
  # region      = "global"
  datacenters = ["dc-2021-home"]

  # Default is "service".
  # type = "service"

  # Constrain to a certain host?
  #  constraint {
  #    # https://www.nomadproject.io/docs/runtime/interpolation
  #    attribute = "${attr.unique.hostname}"
  #    value = "blowhole"
  # }

  group "jellyfin" {
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
    #   # Job file we're deriving from has bridge mode.
    #   # We're trying "host" to start with since that works good for Plex.
    #   # mode = "bridge"
    #
    #   # Web UI - HTTP
    #   port "http" {
    #     static = 8096
    #   }
    #   # Web UI - HTTPS
    #   port "https" {
    #     static = 8920
    #   }
    #   # Client Auto-Discovery
    #   port "client-discovery" {
    #     static = 7359
    #   }
    #   # Service Auto-Discovery
    #   #   - NOTE: Plex also wants this port, so... stop Plex?
    #   port "dlna" {
    #     static = 1900
    #   }
    # }

    #------------------------------
    # Volumes: Nomad Client Host Volumes
    #------------------------------

    #---
    # NFS mount.
    #---
    volume "files-media" {
      type = "host"
      source = "files-media"
      read_only = false
    }

    #---
    # Jellyfin data storage location.
    #---
    # NOTE: This can grow very large, 50gb+ is likely for a large collection.
    #---
    volume "jellyfin-config" {
      type = "host"
      source = "jellyfin-config"
      read_only = false
    }

    #------------------------------
    # Task
    #------------------------------
    task "jellyfin" {
      # https://www.nomadproject.io/docs/job-specification/task

      # Docker Container
      driver = "docker"

      # Use "UID:GID"? Hopefully "GID" works...
      #   ~sudo groupadd --gid 2000 jellyfin~
      #   ~sudo useradd --no-create-home --uid 2000 --gid 2000 --no-user-group --shell /usr/sbin/nologin jellyfin~
      # [2022-02-05]: Jellyfin isn't serving it's web UI on "http" port (8096)...
      #   - Tried adding ~jellyfin~ user to ~docker~ group, but still no joy.
      #   - But running it as root is fine & dandy...
      #     - So I guess run as root?
      #       - IDK.
      # user   = "2000:2000" # "jellyfin:jellyfin"

      # These are Nomad Docker Bind Mounts.
      # Stored wherever the =host_volume= stanza in the Nomad Client config says they should be.
      volume_mount {
        volume      = "files-media"
        destination = "/data"
        read_only   = false
      }

      volume_mount {
        volume      = "jellyfin-config"
        destination = "/config"
        read_only   = false
      }

      config {
        #------------------------------
        # General Config
        #------------------------------
        # https://www.nomadproject.io/docs/job-specification/task

        # This is the official Jellyfin Server image.
        #   - It has a separate Dockerfile for the ARM and ARM64 versions, but no tags to grab the ARM images from Docker Hub.
        # image = "jellyfininc/pms-docker"
        # This Jellyfin Server image is explicitly for ARM64 (with this tag).
        image = "linuxserver/jellyfin:arm64v8-latest"

        # If image's tag is "latest" or omitted, the docker image will always be pulled regardless of this setting.
        # But Jellyfin uses a separate tag for ARM, so try enabling this.
        force_pull = "true"

        # Don't need to define any ports because it's on a macvlan network,
        # so it gets all its own ports.
        # ports = [
        #   "http",
        #   "https",
        #   "client-discovery",
        #   "dlna",
        # ]

        #------------------------------
        # Docker Network: macvlan
        #------------------------------
        # NOTE: Nomad can't manage a macvlan network. It forwards host ports if you do a network
        # stanza with ~to = "<port-num>"~...
        network_mode = "pihole_vnet"
        # Not needed if doing a /32 CIDR block Docker network.
        ipv4_address = "192.168.254.12"

        # # Be the host, for networking, basically.
        # # Alternatively, "macvlan" makes a vlan for the container so you can be your own man but still not remap ports.
        # network_mode = "host"

        #------------------------------
        # Misc.
        #------------------------------

        # Hardware transcoding support.
        # Plex needs this if hardware transcoding is enabled; haven't looked at if Jellyfin needs it too.
        # privileged = "true"
      }

      env {
        TZ = "US/Pacific"

        # https://www.nomadproject.io/docs/runtime/interpolation
        # "Network-related Variables"
        # Publish server url of whatever host we're on, since we have network type "host".
        # NOTE: This didn't expand into an IP address. It just stayed as '${env["NOMAD_IP_http"]}'.
        # JELLYFIN_PublishedServerUrl = "${env["NOMAD_IP_http"]}"
        JELLYFIN_PublishedServerUrl = "${attr.unique.network.ip-address}"
        # If that doesn't work, hard code it:
        # JELLYFIN_PublishedServerUrl = "192.168.254.12"

        # Hardware Acceleration
        #   - !!!-NOTE-!!!: Requires active cooling!
        # https://jellyfin.org/docs/general/administration/hardware-acceleration.html#raspberry-pi-3-and-4
        # [SKIP] I don't have active cooling.

        # https://docs.linuxserver.io/images/docker-jellyfin#user-group-identifiers
        # Set these if the "task.user" setting doesn't work?
        # PUID = 2000
        # PGID = 2000
      }

      service {
        name = "jellyfin"
        # port = "http"

        # Can't health check with macvlan? Or I just haven't figured it out?
        # Everything I've tried hasn't worked...
        #   https://www.nomadproject.io/docs/job-specification/service
        # check {
        #   type         = "http"
        #   address_mode = "pihole"
        #   path         = "/"
        #   port         = "http"
        #   interval     = "10s"
        #   timeout      = "10s"
        # }

        # Hard limit for the =Consul Connect= sidecar service?
        # connect {
        #   sidecar_service {}
        #
        #   sidecar_task {
        #     resources {
        #       cpu = 75
        #       memory = 48
        #     }
        #
        #     config {
        #       memory_hard_limit = 96
        #     }
        #   }
        # }
      }

      #------------------------------
      # Resource Reservations
      #---
      # Don't reserve anything - just let this Nomad job reserve the default and then use whatever.
      #------------------------------
      # resources {
      #   # main@home-2019-raspi4:/srv/nomad/pihole/etc/pihole$ sudo lscpu | grep -i mhz
      #   # CPU max MHz:                     1500.0000
      #   # CPU min MHz:                     600.0000
      #   cpu = nnn # MHz
      #
      #   # main@home-2019-raspi4:/srv/nomad/pihole/etc/pihole$ cat /proc/meminfo | grep -i mem
      #   # MemTotal:        1892528 kB
      #   # MemFree:           47384 kB
      #   # MemAvailable:    1416612 kB
      #   # Shmem:             10556 kB
      #   memory = 1024 # mB
      # }
    }
  }
}
