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

    # Don't need to define any ports because Pi-Hole is on a macvlan network,
    # so it gets all its own ports.
    # network {
    #   port "dns" {
    #     to = "53"
    #   }

    #   port "dhcp" {
    #     to = "67"
    #   }

    #   port "http" {
    #     to = "80"
    #   }

    #   port "https" {
    #     to = "443"
    #   }
    # }

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

      # These are Nomad Docker Bind Mounts; stored wherever the ~host_volume~ stanza in
      # the Nomad Client config says they should be.
      # NOTE: This is all that's needed to tell Docker about these. Do not need
      # any ~mount~, ~volume~, etc in the ~config~ stanza.
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

        # Don't need to define any ports because Pi-Hole is on a macvlan network,
        # so it gets all its own ports.
        # ports = [
        #   "dns",
        #   "dhcp",
        #   "http",
        #   "https",
        # ]

        #------------------------------
        # Docker Config Options
        #------------------------------
        #  https://www.nomadproject.io/docs/drivers/docker

        # Not sure why we need this or what all should be in it...
        dns_servers = [
          "127.0.0.1",
          #---
          # Quad9
          #---
          # "9.9.9.9",         # (malware filter, DNSSEC)
          # "149.112.112.112", # (malware filter, DNSSEC)
          # "9.9.9.10",        # (DNSSEC)
          # "149.112.112.10",  # (DNSSEC)
          "9.9.9.11",          # (malware filter, ECS, DNSSEC)
          # "149.112.112.11",  # (malware filter, ECS, DNSSEC)

          #---
          # Google
          #---
          # "8.8.8.8", # (ECS, DNSSEC)
          # "8.8.4.4", # (ECS, DNSSEC)

          #---
          # Cloudflare
          #---
          # "1.1.1.1", # (DNSSEC)
          # "1.0.0.1", # (DNSSEC)
        ]

        # Need the "NET_ADMIN" setting.
        cap_add = [
          "NET_ADMIN",
        ]

        # Use Docker macvlan 192.168.254.2/32:
        # NOTE: Nomad can't manage a macvlan network. It forwards host ports if you do a network
        # stanza with ~to = "<port-num>"~...
        network_mode = "pihole_vnet"
        # sudo docker network create \
        #     --driver macvlan \
        #     --subnet 192.168.254.0/24  \
        #     --ip-range 192.168.254.2/32 \
        #     --gateway 192.168.254.254 \
        #     --opt parent=eth0 \
        #     pihole_vnet
      }

      env {
        TZ           = "US/Pacific"
        WEBPASSWORD  = "I do not like raspberries."

        # Rest of the set-up is in the persistent files.

        # But if I change my mind, look & see what other vars I want to set:
        #   - https://github.com/pi-hole/docker-pi-hole/blob/master/README.md#environment-variables
      }

      # These are reservations, so just don't set so we can let it use whatever it ends up needing.
      # resources {
      #   cpu    = 100 # 100 MHz
      #   memory = 128 # 128 MB
      # }

      # Register this with Consul. This will make the service addressable after
      # Nomad has placed it on a host and port.
      #   https://www.nomadproject.io/docs/job-specification/service
      service {
        name = "pihole"

        # Not really sure what I get out of having a port here...
        # Also not really sure if "driver" is correct, but it is acceptable to Nomad.
        address_mode = "driver"
        port = "80"

        # TODO: Implement one or more health checks once pi-hole actually is know to actually work.
        # check {
        #   type     = "tcp"
        #   interval = "10s"
        #   timeout  = "2s"
        # }

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
