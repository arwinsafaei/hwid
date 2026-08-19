#!/usr/bin/env bash

SERVER_PORT=55557

echo "==================================="
echo "        HWID NETWORK SETUP"
echo "==================================="
echo

echo "[+] Checking Ethernet..."

ETHERNET=""

for interface in /sys/class/net/*; do
    name=$(basename "$interface")

    if [ "$name" != "lo" ] && [ "$name" != "wlan0" ] && [ "$name" != "wlp2s0" ]; then
        ETHERNET="$name"
        break
    fi
done

if [ -z "$ETHERNET" ]; then
    echo "[-] No Ethernet interface found."
    exit 1
fi

echo "[+] Ethernet interface detected: $ETHERNET"

echo "[+] Checking Ethernet connection..."

if ip link show "$ETHERNET" | grep -q "LOWER_UP"; then
    echo "[+] Ethernet link detected."
else
    echo "[-] Ethernet cable/link not detected."
    exit 1
fi

echo "[+] Requesting IPv4 address..."

dhclient "$ETHERNET" >/dev/null 2>&1

CLIENT_IPV4=$(ip -4 addr show "$ETHERNET" | awk '/inet / {print $2}' | cut -d/ -f1 | head -n1)

if [ -z "$CLIENT_IPV4" ]; then
    echo "[-] Failed to obtain IPv4 address."
    exit 1
fi

echo "[+] Client IPv4: $CLIENT_IPV4"

echo
read -rp "[?] Enter HWID-Server IPv4: " SERVER_IP

if [ -z "$SERVER_IP" ]; then
    echo "[-] No server address entered."
    exit 1
fi

echo "[+] Testing connection to $SERVER_IP:$SERVER_PORT..."

if ! timeout 5 bash -c "</dev/tcp/$SERVER_IP/$SERVER_PORT" 2>/dev/null; then
    echo "[-] Could not connect to HWID-Server."
    exit 1
fi

echo "[+] HWID-Server connection established."

SERIAL=$(cat /sys/class/dmi/id/product_serial 2>/dev/null)

if [ -z "$SERIAL" ]; then
    SERIAL="UNKNOWN"
fi

echo "[+] Serial: $SERIAL"

TESTMSG="TESTMSG
Coming from $SERIAL at $CLIENT_IPV4 (IPv6 unavailable).
Destination: port $SERVER_PORT at HWID server $SERVER_IP"

echo
echo "[+] Sending TESTMSG..."

RESPONSE=$(printf '%s\n' "$TESTMSG" | nc "$SERVER_IP" "$SERVER_PORT")

echo "[+] Server response:"
echo "-----------------------------------"
echo "$RESPONSE"
echo "-----------------------------------"

if echo "$RESPONSE" | grep -q "^INITMSG"; then
    echo "[+] HWID-Server handshake successful."
    exit 0
fi

echo "[-] Invalid server response."
exit 1