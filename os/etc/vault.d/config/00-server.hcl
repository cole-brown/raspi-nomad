#-------------------------------------------------------------------------------
# Vault Configuration
#-------------------------------------------------------------------------------
# Docs:     https://www.vaultproject.io/docs/configuration
# Tutorial: https://learn.hashicorp.com/tutorials/vault/configure-vault


#------------------------------
# CHANGE-LOG:
#-----------
# [2022-01-15]
#   Created config.
# Links:
#   https://learn.hashicorp.com/tutorials/vault/getting-started-deploy
#   https://www.vaultproject.io/docs/configuration/storage/consul
#---
# [NEXT]
#------------------------------


#------------------------------
# Storage Backend & Registration
#------------------------------
# https://www.hashicorp.com/blog/vault-integrated-storage-ga

#---
# Consul
#---
# https://www.vaultproject.io/docs/configuration/storage/consul

storage "consul" {
  address = "127.0.0.1:8500"
  path    = "vault"
}
# NOTE: If you use Consul for storage, you don't need to register with it.


# #---
# # Raft (disk storage)
# #---
# https://www.vaultproject.io/docs/configuration/storage/raft
#
# storage "raft" {
# path    = "./vault/data"
# node_id = "node-0"
# }
#
# service_registration "consul" {
# address      = "127.0.0.1:8500"
# }
#
# # NOTE: When using the Integrated Storage (raft) backend, it is strongly
# # recommended to set disable_mlock to true, and to disable memory swapping on
# # the system.
# disable_mlock = true

#---
# Consul Availability:
#---
# Once properly configured, an unsealed Vault installation should be available
# and accessible at:
#   active.vault.service.consul
#
# Unsealed Vault instances in standby mode are available at:
#   standby.vault.service.consul
#
# All unsealed Vault instances are available as healthy at:
#   vault.service.consul
#
# Sealed Vault instances will mark themselves as unhealthy to avoid being
# returned at Consul's service discovery layer.


#------------------------------
# Serve
#------------------------------

listener "tcp" {
  address = "127.0.0.1:8200"

  # TODO: Enable TLS?
  #   - Need cert files.
  #     - https://www.vaultproject.io/docs/configuration/listener/tcp#tls_cert_file
  tls_disable = "true"
}

api_addr     = "http://127.0.0.1:8200"
cluster_addr = "https://127.0.0.1:8201"


# #------------------------------
# # Telemetry
# #------------------------------
#
# telemetry {
#   statsite_address = "127.0.0.1:8125"
#   disable_hostname = true
# }


#------------------------------
# Misc
#------------------------------

# Use Nomad's/Consul's `datacenter` name for cluster name?
cluster_name="dc-2021-home"

ui = true
