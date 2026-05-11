#!/bin/bash
set -eux

NODE_IP=${SEESAW_NODE_IP:-172.20.10.2}

mkdir -p /var/run/seesaw/engine /var/run/seesaw/ncc /var/run/seesaw/ha /var/log/seesaw

modprobe dummy || true

ip link del dummy0 2>/dev/null || true
ip link del dummy1 2>/dev/null || true

ip link add dummy0 type dummy
ip link add dummy1 type dummy
ip link set dummy0 up
ip link set dummy1 up

ip addr add ${NODE_IP}/24 dev dummy0

modprobe ip_vs || true
modprobe ip_vs_rr || true
modprobe ip_vs_wrr || true
modprobe ip_vs_lc || true

exec /usr/local/seesaw/seesaw_watchdog