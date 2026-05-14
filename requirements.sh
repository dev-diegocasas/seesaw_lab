#!/bin/bash
# ============================================================
# requirements.sh - Dependencias necesarias para labseesaw
# Ejecutar UNA SOLA VEZ en Ubuntu antes de docker compose up
# ============================================================
set -e

echo "============================================"
echo "  labseesaw — Instalación de dependencias"
echo "============================================"

# ─── Docker ────────────────────────────────────────────────
echo "[1/4] Instalando Docker..."
if ! command -v docker &>/dev/null; then
    sudo apt-get update
    sudo apt-get install -y docker.io docker-compose-v2
    sudo systemctl enable --now docker
    echo "  ✓ Docker instalado"
else
    echo "  ✓ Docker ya instalado"
fi

# ─── IPVS (módulos del kernel) ─────────────────────────────
echo "[2/4] Instalando ipvsadm y módulos del kernel..."
sudo apt-get install -y ipvsadm
sudo modprobe ip_vs     2>/dev/null || echo "  ⚠ ip_vs ya cargado o no disponible"
sudo modprobe ip_vs_rr  2>/dev/null || true
sudo modprobe ip_vs_wrr 2>/dev/null || true
sudo modprobe ip_vs_lc  2>/dev/null || true
sudo modprobe ip_vs_sh  2>/dev/null || true
sudo modprobe dummy     2>/dev/null || true
echo "  ✓ Módulos cargados"

# ─── Persistencia al arranque ──────────────────────────────
echo "[3/4] Habilitando módulos al arranque..."
MODULES="ip_vs
ip_vs_rr
ip_vs_wrr
ip_vs_lc
ip_vs_sh
dummy"
echo "$MODULES" | sudo tee /etc/modules-load.d/seesaw.conf > /dev/null
echo "  ✓ Persistencia configurada"

# ─── net.ipv4.ip_forward ───────────────────────────────────
echo "[4/4] Habilitando IP forwarding..."
if ! grep -q "^net.ipv4.ip_forward=1" /etc/sysctl.conf; then
    echo "net.ipv4.ip_forward=1" | sudo tee -a /etc/sysctl.conf > /dev/null
    sudo sysctl -w net.ipv4.ip_forward=1 > /dev/null
    echo "  ✓ IP forwarding activado"
else
    echo "  ✓ IP forwarding ya activo"
fi

echo ""
echo "============================================"
echo "  Todo listo. Ahora ejecuta:"
echo ""
echo "    docker compose up --build"
echo ""
echo "  Para probar el balanceo:"
echo "    docker exec -it test-client sh"
echo "    # curl http://172.20.10.100   (Seesaw)"
echo "    # curl http://172.20.10.200   (HAProxy)"
echo "============================================"
