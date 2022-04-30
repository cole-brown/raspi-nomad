#-------------------------------------------------------------------------------
# Tailscale Docker
#-------------------------------------------------------------------------------
# Tailscale is a VPN built on top of the WireGuard VPN.
#
# Links:
#   https://tailscale.com/
#   https://github.com/tailscale/tailscale
#   https://github.com/tailscale/tailscale/blob/main/Dockerfile
#
# Docs:
#   https://tailscale.com/kb/
#
#------------------------------

job "tailscale" {
  # Default is "global".
  # region      = "global"
  datacenters = ["dc-2021-home"]

  # Default is "service".
  # type = "service"

  group "tailscale" {
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
    # Don't need to define any ports because Tailscale is on a macvlan network,
    # so it gets all its own ports.

    # TODO: Move this into 'pihole.nomad' once it works?
    #---------------------------------------------------------------------------
    # Task: Tailscale Docker Container
    #---------------------------------------------------------------------------
    task "tailscale" {
      # https://www.nomadproject.io/docs/job-specification/task

      # Docker Container
      driver = "docker"

      config {
        #------------------------------
        # General Config
        #------------------------------
        #  https://www.nomadproject.io/docs/job-specification/task

        # https://github.com/tailscale/tailscale/blob/main/docs/k8s/README.md#sample-proxy
        # https://github.com/tailscale/tailscale/blob/main/Dockerfile
        # Docker Hub:
        image = "tailscale/tailscale:latest"
        # Or GitHub Container Registry:
        # image = "ghcr.io/tailscale/tailscale:latest"

        #------------------------------
        # Docker Config Options
        #------------------------------
        #  https://www.nomadproject.io/docs/drivers/docker

        # Not sure if we need this or what all should be in it...
        dns_servers = [
          "127.0.0.1",
          #---
          # Pi-Hole
          #---
          "192.168.254.2",
          # "192.168.254.3", # second pi-hole, if/when I get one...
        ]

        #------------------------------
        # Docker Network: `pihole_vnet` macvlan
        #------------------------------

        #---
        # Nomad settings:
        #---
        # NOTE: Nomad can't manage a macvlan network. It forwards host ports if you do a network
        # stanza with ~to = "<port-num>"~...
        network_mode = "pihole_vnet"
        # Not needed if doing a /32 CIDR block Docker network.
        # Addresses:
        ipv4_address = "192.168.254.10"
      }

      #------------------------------
      # Environment Variables
      #------------------------------
      env {
        TZ                  = "US/Pacific"
        TUNNEL_DNS_UPSTREAM = "https://1.1.1.1/dns-query,https://1.0.0.1/dns-query"
        # TUNNEL_DNS_PORT    = 5053
        # TUNNEL_DNS_ADDRESS = "0.0.0.0"
        # TUNNEL_METRICS     = "0.0.0.0:49312" # Prometheus metrics host & port
      }

      #------------------------------
      # Resource Reservations
      #------------------------------
      # These are reservations, so just don't set so we can let it use whatever it ends up needing.
      # resources {
      #   cpu    = 100 # 100 MHz
      #   memory = 128 # 128 MB
      # }

      #------------------------------
      # Consul
      #------------------------------
      # Register this with Consul. This will make the service addressable after
      # Nomad has placed it on a host and port.
      #   https://www.nomadproject.io/docs/job-specification/service
      service {
        name = "tailscale"

        #------------------------------
        # TODO: Not really sure how to get a health check working with a macvlan Docker service.
        #---
        # # Not really sure what I get out of having a port here...
        # # Also not really sure if "driver" is correct, but it is acceptable to Nomad.
        # address_mode = "driver"
        # port         = "80"
        #
        # # Health Check: Simple TCP check?
        # check {
        #   address_mode = "driver"
        #   type         = "tcp"
        #   interval     = "10s"
        #   timeout      = "2s"
        # }
        #
        # # Health Check: HTTP admin interface working?
        # check {
        #   name         = "Tailscale Web Interface Health"
        #   address_mode = "driver"
        #   type         = "http"
        #   protocol     = "http"
        #   port         = "80"
        #   path         = "/"
        #   interval     = "1m"
        #   timeout      = "10s"
        # }
        #------------------------------
      }
    }
  }
}
