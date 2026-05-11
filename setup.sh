#!/bin/bash
# setup.sh — ejecutar UNA VEZ antes de docker compose up

mkdir -p backends/web{1,2,3}
mkdir -p config/node{1,2}

for i in 1 2 3; do
  cat > backends/web$i/index.html <<EOF
<!DOCTYPE html>
<html><body>
<h1>Backend $i</h1>
<p>Servidor: web-backend-$i (172.20.20.$i)</p>
</body></html>
EOF
  echo "OK" > backends/web$i/healthz
done

# Copiar cluster.pb igual en ambos nodos
cp config/node1/cluster.pb config/node2/cluster.pb 2>/dev/null || true

echo "Estructura lista. Ahora corre: docker compose up --build"