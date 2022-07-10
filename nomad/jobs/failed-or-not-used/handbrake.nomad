#-------------------------------------------------------------------------------
# Handbrake Docker
#-------------------------------------------------------------------------------
# Handbrake running on Docker
#
# Links:
#   https://hub.docker.com/r/jlesage/handbrake/
#   https://github.com/jlesage/docker-handbrake
#------------------------------

job "handbrake" {
  # Default is "global".
  # region      = "global"
  datacenters = ["dc-2021-home"]

  # Default is "service".
  # type = "service"

  group "handbrake" {
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
    #
    # https://github.com/jlesage/docker-handbrake#ports
    #   5800 = HTTP(S) Web UI

    #------------------------------
    # Volumes: Nomad Client Host Volumes
    #------------------------------
    # https://github.com/jlesage/docker-handbrake#data-volumes

    # # NFS mount.
    # volume "files-media" {
    #   type      = "host"
    #   source    = "files-media"
    #   read_only = false
    # }

    # # NFS mount.
    # volume "files-bree" {
    #   type      = "host"
    #   source    = "files-bree"
    #   read_only = true
    # }

    # NFS mount.
    volume "handbrake-watch" {
      type      = "host"
      source    = "handbrake-watch"
      read_only = false
    }

    # NFS mount.
    volume "handbrake-output" {
      type      = "host"
      source    = "handbrake-output"
      read_only = false
    }

    # Dir with symlinks to NFS storage.
    # [2022-02-27] Trying out read-only access so we don't accidentally wipe anything.
    volume "handbrake-storage" {
      type      = "host"
      source    = "handbrake-storage"
      read_only = true
    }

    # /tmp
    volume "files-temp" {
      type      = "host"
      source    = "files-temp"
      read_only = false
    }

    # /config
    volume "handbrake-config" {
      type      = "host"
      source    = "handbrake-config"
      read_only = false
    }

    #------------------------------
    # Task
    #------------------------------
    task "handbrake" {
      # https://www.nomadproject.io/docs/job-specification/task

      # Docker Container
      driver = "docker"

      #------------------------------
      # Docker Volumes
      #------------------------------
      # https://github.com/jlesage/docker-handbrake#data-volumes

      # These are Nomad Docker Bind Mounts.
      # Stored wherever the =host_volume= stanza in the Nomad Client config says they should be.
      volume_mount {
        volume      = "handbrake-config"
        destination = "/config"
        read_only   = false
      }

      volume_mount {
        volume      = "files-temp"
        destination = "/tmp"
        read_only   = false
      }

      #---
      # NFS Mounts
      #---
      # Files that should be accessable to Handbrake.

      # Handbrake will watch for auto-transcoding input.
      volume_mount {
        volume      = "handbrake-watch"
        destination = "/watch"
        read_only   = false
      }

      # Handbrake will use for auto-transcoding output.
      volume_mount {
        volume      = "handbrake-output"
        destination = "/output"
        read_only   = false
      }

      # Allow Handbrake access for manually transcoding.
      # [2022-02-27] Trying out read-only access so we don't accidentally wipe anything.
      volume_mount {
        volume      = "handbrake-storage"
        destination = "/storage"
        read_only   = true
      }

      config {
        #------------------------------
        # General Config
        #------------------------------
        # https://www.nomadproject.io/docs/job-specification/task

        image = "jlesage/handbrake"

        # Don't need to define any ports because it's on a macvlan network,
        # so it gets all its own ports.
        # ports = [
        #   https://github.com/jlesage/docker-handbrake#ports
        #   5800 = HTTP(S) Web UI
        # ]

        #------------------------------
        # Docker Network: macvlan
        #------------------------------
        # NOTE: Nomad can't manage a macvlan network. It forwards host ports if you do a network
        # stanza with ~to = "<port-num>"~...
        network_mode = "pihole_vnet"
        # Not needed if doing a /32 CIDR block Docker network.
        ipv4_address = "192.168.50.8"
      }

      # https://github.com/jlesage/docker-handbrake#environment-variables
      env {
        TZ = "US/Pacific"

        # The Docker container is in charge of what version Handbrake is. Don't auto-update.
        VERSION = "docker"

        # Run as non-root user - requires the NFS volumes mounted as this user/group.
        # 1000:1000 is `main:main` on raspi.
        USER_ID  = 1000
        GROUP_ID = 1000

        # The application will be automatically restarted if it crashes or if a user quits it.
        KEEP_APP_RUNNING = 1

        # TODO: what to set one of these to?
        # AUTOMATED_CONVERSION_PRESET
        # AUTOMATED_CONVERSION_FORMAT

        # Delete from the watch directory after it's converted.
        AUTOMATED_CONVERSION_KEEP_SOURCE = 0

        # Allow overwriting in output dir if same filename already exists.
        AUTOMATED_CONVERSION_OVERWRITE_OUTPUT = 1

        # Root directory where converted videos should be written?
        # AUTOMATED_CONVERSION_OUTPUT_DIR = "/media/transcode/done"
        # I don't know if this overwrites the default "/output" or what.
        #   - There's no similar for the other defaults ("/storage", "/watch"...)?

        # Time (in seconds) during which properties (e.g. size, time, etc) of a
        # video file in the watch folder need to remain the same. This is to
        # avoid processing a file that is being copied.
        AUTOMATED_CONVERSION_SOURCE_STABLE_TIME = 10
      }

      service {
        name = "handbrake"
      }
    }
  }
}
