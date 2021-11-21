#-------------------------------------------------------------------------------
# Nomad Configuration
#-------------------------------------------------------------------------------

#------------------------------
# CHANGE-LOG:
#-----------
# [2021-11-07]
#   Original (server w/ encrypt & tls) created by ~hashi-up~
# Links:
#   https://johansiebens.dev/posts/2020/08/building-a-nomad-cluster-on-raspberry-pi-running-ubuntu-server/
#   https://github.com/jsiebens/hashi-up/blob/master/docs/nomad.md
#---
# [2021-11-07 11:09:34]
#   Renamed "nomad.hcl" to "server.hcl".
#   Added Docker plugin.
#   Split "server.hcl" into "nomad.hcl" (general bits) and "server.hcl" (server bits).
# Links:
#   https://janssend.wordpress.com/2020/04/21/nomad-setup/
#---
# [2021-11-07 16:23:14]
#   Comment out encrypt/tls certs...
#------------------------------

datacenter    = "dc-2021-home"
data_dir      = "/opt/nomad"

# Would be nice for debugging, but maybe figure out how to run the Pi on a ramdisk first.
# enable_syslog = true


# #---
# # HTTPS (TLS) Certificates
# #---
#
# tls {
#   http      = true
#   rpc       = true
#   ca_file   = "/etc/nomad.d/certs/nomad-ca.pem"
#   cert_file = "/etc/nomad.d/certs/server.pem"
#   key_file  = "/etc/nomad.d/certs/server-key.pem"
# }
