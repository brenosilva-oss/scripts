#!/bin/bash

# Cores ANSI
GREEN="\e[32m"
RED="\e[31m"
BLUE="\e[34m"
RESET="\e[0m"

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

echo -e "${BLUE}=== Testando conectividade com: $HOST ===${RESET}"
echo

# 1. Resolução DNS
echo -e "${BLUE}[1] Testando resolução DNS...${RESET}"
if getent hosts "$HOST" >/dev/null 2>&1; then
    echo -e "${GREEN}OK${RESET} DNS resolvido com sucesso"
else
    echo -e "${RED}FALHA${RESET} Falha na resolução DNS"
    exit 1
fi
echo

# 2. Teste de portas com nc
echo -e "${BLUE}[2] Testando portas com nc...${RESET}"
for PORT in $PORTS; do
    if nc -z -w 2 "$HOST" "$PORT" >/dev/null 2>&1; then
        echo -e "${GREEN}OK${RESET} Porta $PORT acessível (nc)"
    else
        echo -e "${RED}FALHA${RESET} Porta $PORT inacessível (nc)"
    fi
done
echo

# 3. Teste de portas com telnet (com timeout)
echo -e "${BLUE}[3] Testando portas com telnet...${RESET}"
for PORT in $PORTS; do
    if timeout 3 bash -c "echo quit | telnet $HOST $PORT" >/dev/null 2>&1; then
        echo -e "${GREEN}OK${RESET} Porta $PORT acessível (telnet)"
    else
        echo -e "${RED}FALHA${RESET} Porta $PORT inacessível (telnet)"
    fi
done
echo

# 4. Teste HTTP/HTTPS com curl
echo -e "${BLUE}[4] Testando HTTP/HTTPS...${RESET}"
for PORT in $PORTS; do
    case "$PORT" in
        80|443|8080)
            URL="http://$HOST:$PORT"
            echo "Testando $URL ..."
            if curl -Is --max-time 3 "$URL" >/dev/null 2>&1; then
                echo -e "${GREEN}OK${RESET} Resposta HTTP recebida na porta $PORT"
            else
                echo -e "${RED}FALHA${RESET} Nenhuma resposta HTTP na porta $PORT"
            fi
            ;;
    esac
done
echo

echo -e "${BLUE}=== Teste finalizado ===${RESET}"
