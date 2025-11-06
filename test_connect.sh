#!/bin/bash

# Uso:
# ./check_connectivity.sh exemplo.com 80 443 8080

HOST="$1"
shift
PORTS="$@"

if [ -z "$HOST" ]; then
    echo "Uso: $0 <host> <portas>"
    echo "Ex: $0 exemplo.com 80 443"
    exit 1
fi

echo "=== Testando conectividade com: $HOST ==="
echo

# 1. Teste de resolução DNS
echo "[1] Testando resolução DNS..."
if getent hosts "$HOST" >/dev/null 2>&1; then
    echo "DNS resolvido com sucesso"
else
    echo "Falha na resolução DNS"
    exit 1
fi
echo

# 2. Teste de ping
echo "[2] Testando ping..."
if ping -c 2 "$HOST" >/dev/null 2>&1; then
    echo "Ping OK (host alcançável)"
else
    echo "Ping falhou (pode estar bloqueado, mas o host pode existir)"
fi
echo

# 3. Testar portas com nc
echo "[3] Testando portas com nc..."
for PORT in $PORTS; do
    if nc -z -w 3 "$HOST" "$PORT" >/dev/null 2>&1; then
        echo "Porta $PORT aberta"
    else
        echo "Porta $PORT inacessível"
    fi
done
echo

# 4. Teste HTTP/HTTPS com curl
echo "[4] Testando HTTP/HTTPS..."
for PORT in $PORTS; do
    if [ "$PORT" == "80" ] || [ "$PORT" == "443" ] || [ "$PORT" == "8080" ]; then
        URL="http://$HOST:$PORT"
        echo "Testando $URL ..."
        if curl -Is "$URL" >/dev/null 2>&1; then
            echo "Resposta HTTP recebida na porta $PORT"
        else
            echo "Nenhuma resposta HTTP na porta $PORT"
        fi
    fi
done
echo

echo "=== Teste finalizado ==="
