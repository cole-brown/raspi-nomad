job "hello-world" {
  datacenters = [
    # Most examples use "dc1". I tend to lean towards "dc0", so...
    "dc0",
    "dc1",
    # My current datacenter.
    "dc-2021-home"
  ]

  group "example" {
    network {
      port "http" {
        static = "5678"
      }
    }

    task "server" {
      driver = "docker"

      config {
        image = "hashicorp/http-echo"
        ports = ["http"]
        args = [
          "-listen",
          ":5678",
          "-text",
          "hello world",
        ]
      }
    }
  }
}
