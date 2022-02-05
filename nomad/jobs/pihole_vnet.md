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
| 192.168.254.12 |                 |            |
| 192.168.254.13 |                 |            |
| 192.168.254.14 |                 |            |
| 192.168.254.15 |                 |            |

