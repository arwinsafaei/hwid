#!/usr/bin/env python3

import socket
import threading

HOST = "0.0.0.0"
PORT = 55557


def get_local_ip():
    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)

    try:
        sock.connect(("192.0.2.1", 80))
        return sock.getsockname()[0]
    except OSError:
        return "UNKNOWN"
    finally:
        sock.close()


def handle_client(conn, address):
    print(f"[+] Connection from {address[0]}:{address[1]}")

    try:
        data = conn.recv(4096)

        if not data:
            print("[-] Client disconnected.")
            return

        message = data.decode("utf-8", errors="replace")

        print("----- TESTMSG -----")
        print(message)
        print("-------------------")

        if message.startswith("TESTMSG"):
            serial = "UNKNOWN"

            for line in message.splitlines():
                if line.startswith("Coming from "):
                    serial = line.split("Coming from ", 1)[1].split(" at ", 1)[0]
                    break

            print(f"[+] Device serial: {serial}")

            response = (
                "INITMSG\n"
                "Test message received. "
                f"Device {serial} added to database.\n"
                "Receiving of information packets is now available.\n"
            )

            conn.sendall(response.encode("utf-8"))

            print("[+] INITMSG sent.")

    except Exception as error:
        print(f"[!] Client error: {error}")

    finally:
        conn.close()
        print(f"[-] Connection closed: {address[0]}:{address[1]}")


def main():
    server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

    server.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)

    server.bind((HOST, PORT))
    server.listen()

    local_ip = get_local_ip()

    print("===================================")
    print("            HWID-SERVER")
    print("===================================")
    print()
    print(f"[+] Listening on {local_ip}:{PORT}")
    print("[+] Waiting for HWID clients...")
    print()

    while True:
        conn, address = server.accept()

        thread = threading.Thread(
            target=handle_client,
            args=(conn, address),
            daemon=True
        )

        thread.start()


if __name__ == "__main__":
    main()