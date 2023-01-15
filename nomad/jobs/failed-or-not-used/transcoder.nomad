#-------------------------------------------------------------------------------
# Transcoder Docker
#-------------------------------------------------------------------------------
# Transcoder running on Docker
#
# Links:
#   https://github.com/Vilsol/transcoder-go
#     - https://hub.docker.com/r/vilsol/transcoder-go
#------------------------------

job "transcoder" {
  # Default is "global".
  # region      = "global"
  datacenters = ["dc-2021-home"]

  # Default is "service".
  # type = "service"

  group "transcoder" {
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

    #------------------------------
    # Volumes: Nomad Client Host Volumes
    #------------------------------

    # NFS mount.
    volume "transcoder-process" {
      type      = "host"
      source    = "transcoder-process"
      read_only = false
    }

    #------------------------------
    # Task
    #------------------------------
    task "transcoder" {
      # https://www.nomadproject.io/docs/job-specification/task

      # Docker Container
      driver = "docker"

      #------------------------------
      # Docker Volumes
      #------------------------------

      #---
      # NFS Mounts
      #---
      # Files that should be accessable to the transcoder.

      volume_mount {
        volume      = "transcoder-process"
        destination = "/data"
        read_only   = false
      }

      config {
        #------------------------------
        # General Config
        #------------------------------
        # https://www.nomadproject.io/docs/job-specification/task

        image = "vilsol/transcoder-go"

        # Don't need any ports.
        # ports = [
        # ]

        #------------------------------
        # Docker Network: default
        #------------------------------
        # Just have it as whatever since we don't need access to any particular ports.
      }

      env {
        PATHS = "/data"
      }

      service {
        name = "transcoder"
      }
    }
  }
}
