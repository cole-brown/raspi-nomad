job "batch" {
  datacenters = [
    # Most examples use "dc1". I tend to lean towards "dc0", so...
    # "dc0",
    # "dc1",
    # My current datacenter.
    "dc-2021-home"
  ]

  # https://www.nomadproject.io/docs/schedulers#batch
  # "batch" == short lived job that runs until a successful exit
  type = "batch"

  # Only run on Linux.
  constraint {
    attribute = "${attr.kernel.name}"
    value = "linux"
  }

  periodic {
    // Launch every 20 seconds
    cron = "*/20 * * * * * *"

    // Do not allow overlapping runs.
    prohibit_overlap = true
  }

  group "batch" {
    count = 1

    restart {
      interval = "20s"
      attempts = 2
      delay    = "5s"
      mode     = "delay"
    }

    network {
      # Request for a dynamic port
      port "date" {
      }
    }

    task "date" {
      driver = "exec"
      # "raw_exec" is disabled by default.
      # driver = "raw_exec"

      service {
        name = "date-batch-job"
        tags = ["date"]
        port = "date"

        check {
          name     = "alive"
          type     = "tcp"
          interval = "10s"
          timeout  = "2s"
        }
      }

      config {
        command = "date"
      }

      # resources {
      #   cpu = 100 # Mhz
      #   memory = 128 # MB
      # }
    }
  }
}
