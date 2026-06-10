#!/bin/bash

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print error messages
print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to print success messages
print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

# Function to print info messages
print_info() {
    echo -e "${YELLOW}[INFO]${NC} $1"
}

# Validate input
if [ "$#" -ne 1 ]; then
    print_error "Invalid number of arguments"
    echo "Usage: $0 <server_FQDN>"
    exit 1
fi

SERVER_FQDN=$1

# Validate FQDN format
if ! [[ "$SERVER_FQDN" =~ ^[a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(\.[a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$ ]]; then
    print_error "Invalid FQDN format: $SERVER_FQDN"
    exit 1
fi

print_info "Starting certificate generation for: $SERVER_FQDN"

# subjectAltName
SAN="DNS:$SERVER_FQDN,DNS:*.$SERVER_FQDN"

# Check if OpenSSL is installed
if ! command -v openssl &> /dev/null; then
    print_error "OpenSSL is not installed. Please install it first."
    exit 1
fi
print_success "OpenSSL found"

# Step 1: Generate Root Key
print_info "Step 1: Generating Root CA Key..."
if openssl genrsa -out root.key 2048 2>/dev/null; then
    print_success "Root CA Key generated successfully: root.key"
else
    print_error "Failed to generate Root CA Key"
    exit 1
fi

# Step 2: Generate Root Certificate
print_info "Step 2: Generating Root CA Certificate..."
if openssl req -x509 -new -key root.key -days 7300 -out root.crt -subj "/O=nginx/OU=nginx/CN=RootCA" 2>/dev/null; then
    print_success "Root CA Certificate generated successfully: root.crt"
else
    print_error "Failed to generate Root CA Certificate"
    rm -f root.key
    exit 1
fi

# Step 3: Generate Server Key
print_info "Step 3: Generating Server Private Key..."
if openssl genrsa -out server.key 2048 2>/dev/null; then
    print_success "Server Private Key generated successfully: server.key"
else
    print_error "Failed to generate Server Private Key"
    rm -f root.key root.crt
    exit 1
fi

# Step 4: Generate Certificate Signing Request (CSR)
print_info "Step 4: Generating Certificate Signing Request (CSR)..."
if openssl req -new -key server.key -out server.csr -subj "/C=XX/ST=XX/O=nginx/OU=nginx/CN=$SERVER_FQDN" 2>/dev/null; then
    print_success "CSR generated successfully: server.csr"
else
    print_error "Failed to generate Certificate Signing Request"
    rm -f root.key root.crt server.key
    exit 1
fi

# Step 5: Sign the CSR with the Root CA
print_info "Step 5: Signing CSR with Root CA..."
if openssl x509 -req -extfile <(printf "subjectAltName=$SAN") -days 3650 -in server.csr -CA root.crt -CAkey root.key -CAcreateserial -out server.crt 2>/dev/null; then
    print_success "Server Certificate signed successfully: server.crt"
else
    print_error "Failed to sign the Certificate Signing Request"
    rm -f root.key root.crt server.key server.csr
    exit 1
fi

# Step 6: Create Full Chain Certificate
print_info "Step 6: Creating Full Chain Certificate..."
if cat server.crt root.crt > fullchain.crt 2>/dev/null; then
    print_success "Full Chain Certificate created successfully: fullchain.crt"
else
    print_error "Failed to create Full Chain Certificate"
    rm -f root.key root.crt server.key server.csr server.crt
    exit 1
fi

# Step 7: Cleanup temporary files
print_info "Step 7: Cleaning up temporary files..."
if rm -f root.srl server.csr server.crt 2>/dev/null; then
    print_success "Temporary files cleaned up"
else
    print_error "Warning: Failed to remove some temporary files (non-critical)"
fi

# Final success message
echo ""
echo "=========================================="
print_success "Certificates generated successfully!"
echo "=========================================="
echo ""
echo "Generated Files:"
echo "  Root Certificate:      ${GREEN}root.crt${NC}"
echo "  Server Private Key:    ${GREEN}server.key${NC}"
echo "  Full Chain Certificate: ${GREEN}fullchain.crt${NC}"
echo ""
echo "Nginx Configuration Usage:"
echo "  ssl_certificate      /path/to/fullchain.crt;"
echo "  ssl_certificate_key  /path/to/server.key;"
echo ""
echo "Installation on Client Systems:"
echo "  Install ${GREEN}root.crt${NC} on client systems to trust this certificate"
echo "=========================================="
