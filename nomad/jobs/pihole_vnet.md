# Docker `macvlan` Network: `pihole_vnet`

## Docker Command for Creating:

Creates a network of:
  - type: `macvlan`
  - CIDR: `192.168.254.0/28`
    - 192.168.254.0 - 192.168.254.15

``` bash
sudo docker network create \
    --driver macvlan \
    --subnet 192.168.254.0/24  \
    --ip-range 192.168.254.0/28 \
    --gateway 192.168.254.254 \
    --opt parent=eth0 \
    pihole_vnet
```

## Addresses in Use

| Address        | For             | Used?      |
|----------------|-----------------|------------|
| 192.168.254.2  |  pihole         |  in-use    |
| 192.168.254.3  | <pihole-2>      | <reserved> |
| 192.168.254.4  |  cloudflared    |  in-use    |
| 192.168.254.5  | <cloudflared-2> | <reserved> |
| 192.168.254.6  |                 |            |
| 192.168.254.7  |                 |            |
| 192.168.254.8  |                 |            |
| 192.168.254.9  |                 |            |
| 192.168.254.10 |  tailscale vpn  |  in-use    |
| 192.168.254.11 |                 |            |
| 192.168.254.12 | jellyfin        |  in-use    |
| 192.168.254.13 | plex            |  in-use    |
| 192.168.254.14 |                 |            |
| 192.168.254.15 |                 |            |


# Jobs not on `pihole_vnet`


## network_mode = "host"

None, currently.

### Formerly

Jellyfin
Plex

These both want port 1900 currently, so they can't run at the same time.
  - Should probably switch one or both to `bridge`?
  - Or just decide that Jellyfin wins over Plex (or vice versa).

Switched Plex to `bridge` network mode, but then the Amazon Fire TV Stick couldn't access it. So I've moved both media servers to the `pihole_vnet` macvlan so that they can have their ports.
