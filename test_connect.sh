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

# 1. Teste de resolução DNS com getent
echo "[1] Testando resolução DNS..."
if getent hosts "$HOST" >/dev/null 2>&1; then
    echo "DNS resolvido com sucesso"
else
    echo "Falha na resolução DNS"
    exit 1
fi
echo

# 2. Testar portas com nc
echo "[2] Testando portas com nc..."
for PORT in $PORTS; do
    if nc -z -w 3 "$HOST" "$PORT" >/dev/null 2>&1; then
        echo "Porta $PORT acessível (nc conectou)"
    else
        echo "Porta $PORT inacessível (nc falhou)"
    fi
done
echo

# 3. Testar portas com telnet
echo "[3] Testando portas com telnet..."
for PORT in $PORTS; do
    if echo quit | telnet "$HOST" "$PORT" >/dev/null 2>&1; then
        echo "Porta $PORT acessível (telnet conectou)"
    else
        echo "Porta $PORT inacessível (telnet falhou)"
    fi
done
echo

# 4. Teste HTTP/HTTPS com curl
echo "[4] Testando HTTP/HTTPS..."
for PORT in $PORTS; do
    case "$PORT" in
        80|443|8080)
            URL="http://$HOST:$PORT"
            echo "Testando $URL ..."
            if curl -Is "$URL" >/dev/null 2>&1; then
                echo "Resposta HTTP recebida na porta $PORT"
            else
                echo "Nenhuma resposta HTTP na porta $PORT"
            fi
            ;;
    esac
done
echo

echo "=== Teste finalizado ==="
