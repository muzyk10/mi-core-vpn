#!/usr/bin/env bash
# Enable IPv4 and IPv6 forwarding / routing

routeadm -ue ipv4-forwarding
routeadm -ue ipv6-forwarding
