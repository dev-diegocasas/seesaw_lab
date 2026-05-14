#!/bin/bash
# setup.sh — Prepara el laboratorio y construye todo
set -e

echo "============================================"
echo "  labseesaw — Setup"
echo "============================================"

# ── Paso 1: Dependencias ──────────────────────────
echo ""
echo "[1/3] Instalando dependencias del sistema..."
sudo bash requirements.sh

# ── Paso 2: Backends ──────────────────────────────
echo ""
echo "[2/3] Creando archivos de los backends..."
mkdir -p backends/web{1,2,3}
mkdir -p config/node{1,2}

for i in 1 2 3; do
  cat > backends/web$i/index.html <<EOF
<!DOCTYPE html>
<html><body>
<h1>Backend $i</h1>
<p>Servidor: web-backend-$i (172.20.20.$((9+i)))</p>
</body></html>
EOF
  echo "OK" > backends/web$i/healthz
done

# ── Paso 3: Construir y levantar ──────────────────
echo ""
echo "[3/3] Construyendo y levantando contenedores..."
echo "  (esto puede tomar varios minutos la primera vez)"
echo ""
docker compose up --build -d

echo ""
echo "============================================"
echo "  ¡Laboratorio listo!"
echo ""
echo "  Balanceador Seesaw VIP: http://172.20.10.100"
echo ""
echo "  Cliente de prueba (dentre al contenedor):"
echo "    docker exec -it test-client sh"
echo "    # curl -s http://172.20.10.100 | head -5"
echo ""
echo "  Logs de Seesaw:"
echo "    docker logs seesaw-node1"
echo "    docker logs seesaw-node2"
echo ""
echo "  CLI de Seesaw (dentro del nodo activo):"
echo "    docker exec -it seesaw-node1 seesaw"
echo "    # show vservers"
echo "    # show vserver http.web@lab"
echo "============================================"
