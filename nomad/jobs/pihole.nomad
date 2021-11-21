#-------------------------------------------------------------------------------
# Pi-Hole Docker
#-------------------------------------------------------------------------------
# Pi-Hole running on Docker
#
# Links:
#   https://www.nomadproject.io/docs/job-specification/job
#   https://janssend.wordpress.com/2020/04/30/nomad-how-to-create-a-new-job/
#   https://medium.com/swlh/running-hashicorp-nomad-consul-pihole-and-gitea-on-raspberry-pi-3-b-f3f0d66c907
#------------------------------

job "pihole" {
  # Default is "global".
  # region      = "global"
  datacenters = ["dc-2021-home"]

  # Default is "service".
  # type = "service"

  group "pihole" {
    # Defaults to 1.
    # count = 1

    restart {
      attempts = 5
      delay    = "30s"
      # "fail" does not try any more restarts after it fails `attempts` times in the `interval`.
      # "delay" will try restarts again after waiting until the next `interval`.
      # mode     = "fail"
    }

    network {
      # mbits = 100

      port "dns" {
        static = "53"
      }

      port "http" {
        static = "80"
      }

      port "https" {
        static = "443"
      }
    }

    volume "pihole-data" {
      type      = "host"
      source    = "pihole-data"
      read_only = false
    }

    volume "pihole-dnsmasq" {
      type      = "host"
      source    = "pihole-dnsmasq"
      read_only = false
    }

    #------------------------------
    # Task
    #------------------------------
    task "pihole" {
      # https://www.nomadproject.io/docs/job-specification/task

      # Docker Container
      driver = "docker"

      # These are Nomad Docker Bind Mounts.
      # Stored wherever the =host_volume= stanza in the Nomad Client config says they should be.
      volume_mount {
        volume      = "pihole-data"
        destination = "/etc/pihole"
        read_only   = false
      }

      volume_mount {
        volume      = "pihole-dnsmasq"
        destination = "/etc/dnsmasq.d"
        read_only   = false
      }

      config {
        #------------------------------
        # General Config
        #------------------------------
        #  https://www.nomadproject.io/docs/job-specification/task
        image = "pihole/pihole:latest"

        ports = [
          "dns",
          "http",
          "https"
        ]

        #------------------------------
        # Docker Config Options
        #------------------------------
        #  https://www.nomadproject.io/docs/drivers/docker
        dns_servers = [
          "127.0.0.1",
          "1.1.1.1",
          "8.8.8.8",
          "1.0.0.1",
          "8.8.4.4",
        ]

        cap_add = [
          "NET_ADMIN",
        ]

        # These are Docker Volumes; stored in "/var/lib/docker/volumes/<source>/_data".
        # Do not want that...
        # mount {
        #   type     = "volume"
        #   source   = "pihole-data"
        #   target   = "/etc/pihole"
        #   readonly = false
        # }

        # mount {
        #   type     = "volume"
        #   source   = "pihole-dnsmasq"
        #   target   = "/etc/dnsmasq.d"
        #   readonly = false
        # }
      }

      env {
        TZ           = "US/Pacific"
        WEBPASSWORD  = "I do not like raspberries."

        # TODO: Do I need these?
        DNS1         = "1.1.1.1"
        DNS2         = "8.8.8.8"

        INTERFACE    = "eth0"

        # Not sure if this'll work?
        VIRTUAL_HOST = "home-2019-raspi4"
        ServerIP     = "192.168.254.10"
      }

      # resources {
      #   cpu    = 100 # 100 MHz
      #   memory = 128 # 128 MB
      # }

      # Register this with Consul. This will make the service addressable after
      # Nomad has placed it on a host and port.
      #   https://www.nomadproject.io/docs/job-specification/service
      service {
        name = "pihole"
        # Try https for security?
        # port = "http"
        port = "https"

        # # Health Check
        # check {
        #   # name     = "alive"
        #   type = "tcp"
        #   port = "dns"
        #   # path     = "/"
        #   # protocol = "http" # TODO: "https"?
        #   # port     = "http" # TODO: "https"?
        #   # tls_skip_verify = true # If doing "https" and if needed.
        #   interval = "1m"
        #   timeout  = "10s"
        # }
      }
    }
  }
}
