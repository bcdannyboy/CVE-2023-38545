#!/bin/bash

# Initialize default IP addresses and vulnerability status variables
SOCKS5_IP="localhost"
HTTP_IP="localhost"
status_socks5=""
DEBUG=false

# Function to test vulnerability with -x socks5:// option
test_vulnerability() {
    local status_var_name=$1

    # Execute curl command and capture error output
    error_output=$(curl -4 -L --max-time 10 --location --max-redirs 50 --verbose \
                  --ftp-skip-pasv-ip -X "$SOCKS5_IP:1080" --socks5-hostname "$SOCKS5_IP:1080" \
                  --resolve "*:8080:$HTTP_IP" \
                  --no-sessionid http://$HTTP_IP:8080/poc 2>&1)

    exit_code=$?

    if [[ $DEBUG == true ]]; then 
        # Debugging: Display curl messages
        echo "=== Curl Messages ==="
        echo "$error_output"
        echo "======================"
    fi

    # Determine vulnerability status based on curl exit code and error output
    if [[ $exit_code -eq 0 ]]; then
        eval $status_var_name="'Inconclusive, likely not vulnerable'"
    else
        case "$error_output" in
            *"heap buffer overflow"* | *"Segmentation fault"*)
                eval $status_var_name="'[*] Vulnerable'";;
            *"Out of memory"*)
                eval $status_var_name="'[*] Likely Vulnerable, got an out of memory error'";;
            *"Could not resolve host"* | *"Failed to connect to"*)
                eval $status_var_name="'[*] Likely Not Vulnerable, got a connection error'";;
            *)
                eval $status_var_name="'[*] Inconclusive, further investigation needed'";;
        esac
    fi
}

# Parse command-line arguments for IP addresses
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --socks5-ip) SOCKS5_IP="$2"; shift ;;
        --http-ip) HTTP_IP="$2"; shift ;;
        --DEBUG) DEBUG=true ;;
        *) echo "Unknown parameter: $1"; exit 1 ;;
    esac
    shift
done

# Check if curl is installed
if ! curl_version=$(curl -V 2>/dev/null); then
    echo "[*] System is not vulnerable (curl not installed)"
    exit 1
fi

# Extract curl version
libcurl_version=$(echo "$curl_version" | head -n 1 | awk '{print $2}')

# Check if the version is within the vulnerable range
if [[ $(echo -e "$libcurl_version\n7.69.0" | sort -V | head -n1) == "7.69.0" && \
      $(echo -e "$libcurl_version\n8.3.1" | sort -V | head -n1) != "8.3.1" ]]; then

    # Test for vulnerability using -x socks5://
    test_vulnerability status_socks5

    # Display vulnerability status
    echo "=== Vulnerability Status ==="
    echo "[*] $status_socks5"
    echo "============================"
else
    echo "[*] System is not vulnerable (non-vulnerable version $libcurl_version)"
    exit 1
fi
