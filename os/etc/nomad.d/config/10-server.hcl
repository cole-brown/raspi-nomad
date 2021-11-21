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

advertise {
  http = "{{ GetInterfaceIP \"eth0\" }}"
  rpc  = "{{ GetInterfaceIP \"eth0\" }}"
  serf = "{{ GetInterfaceIP \"eth0\" }}"
}

server {
  enabled          = true
  bootstrap_expect = 1
  # encrypt          = "<some specific base-64 string>"
}

# https://www.nomadproject.io/docs/configuration/consul
#   "A default ~consul~ stanza is automatically merged with all Nomad agent configurations."
# So only add this if consul integration isn't working?..
# consul {
#   address = "127.0.0.1:8501"
# }
