#!/bin/bash
set -eux

NODE_IP=${SEESAW_NODE_IP:-172.20.10.2}
VIP="172.20.10.100"

mkdir -p /var/run/seesaw/engine /var/run/seesaw/ncc /var/run/seesaw/ha /var/log/seesaw

# Activar IP forwarding (necesario para IPVS NAT)
echo 1 > /proc/sys/net/ipv4/ip_forward

# Cargar módulos del kernel
modprobe dummy  2>/dev/null || true
modprobe ip_vs   2>/dev/null || true
modprobe ip_vs_rr  2>/dev/null || true
modprobe ip_vs_wrr 2>/dev/null || true
modprobe ip_vs_lc  2>/dev/null || true
modprobe ip_vs_nq  2>/dev/null || true
modprobe ip_vs_sh  2>/dev/null || true

# Interfaces dummy para Seesaw
ip link del dummy0 2>/dev/null || true
ip link del dummy1 2>/dev/null || true

ip link add dummy0 type dummy
ip link add dummy1 type dummy
ip link set dummy0 up
ip link set dummy1 up

ip addr add ${NODE_IP}/24 dev dummy0

# ── Sincronización del VIP ──────────────────────────────────
# Cuando Seesaw activa el VIP en dummy1 (por VRRP), también lo
# agrega a eth0 para que sea alcanzable desde la red de Docker.
sync_vip() {
  while true; do
    if ip addr show dummy1 2>/dev/null | grep -q " ${VIP}"; then
      if ! ip addr show eth0 2>/dev/null | grep -q " ${VIP}"; then
        ip addr add ${VIP}/24 dev eth0 2>/dev/null || true
      fi
    else
      if ip addr show eth0 2>/dev/null | grep -q " ${VIP}"; then
        ip addr del ${VIP}/24 dev eth0 2>/dev/null || true
      fi
    fi
    sleep 2
  done
}
sync_vip &

exec /usr/local/seesaw/seesaw_watchdog
