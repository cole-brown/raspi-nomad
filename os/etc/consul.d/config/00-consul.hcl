#-------------------------------------------------------------------------------
# Consul Configuration
#-------------------------------------------------------------------------------

#------------------------------
# CHANGE-LOG:
#-----------
# [2021-11-07]
#   Original (server w/ encrypt & tls) created by ~hashi-up~
# Links:
#   https://johansiebens.dev/posts/2020/08/building-a-nomad-cluster-on-raspberry-pi-running-ubuntu-server/
#   https://github.com/jsiebens/hashi-up/blob/master/docs/consul.md
#---
# [2021-11-07 11:09:34]
#   Formatting changes.
# Links:
#   https://janssend.wordpress.com/2020/04/21/nomad-setup/
#---
# [2021-11-07 16:23:14]
#   Comment out: encrypt, ca/cert/key files, auto_encrypt, verify_*
#   Commented out: address, ports
#   Added 'connect' block.
#------------------------------

server           = true
ui               = true
datacenter       = "dc-2021-home"
bootstrap_expect = 1
data_dir         = "/opt/consul"
bind_addr        = "{{ GetInterfaceIP \"eth0\" }}"
advertise_addr   = "{{ GetInterfaceIP \"eth0\" }}"
client_addr      = "0.0.0.0"

connect {
  enabled = true
}

# addresses {
# }

# ports {
#   https = 8501
#   http  = -1
# }
#
# verify_incoming_rpc    = true
# verify_outgoing        = true
# verify_server_hostname = true
#
#
# encrypt                = "<some specific base-64 string>"
# ca_file                = "/etc/consul.d/certs/consul-agent-ca.pem"
# cert_file              = "/etc/consul.d/certs/dc-2021-home-server-consul-0.pem"
# key_file               = "/etc/consul.d/certs/dc-2021-home-server-consul-0-key.pem"
# auto_encrypt {
#   allow_tls = true
# }
