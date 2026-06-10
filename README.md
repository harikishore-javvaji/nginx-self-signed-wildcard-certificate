# Nginx Self-Signed Wildcard Certificate Generator

A bash script that simplifies the process of securing your server with robust encryption, using OpenSSL to generate top-tier certificates. Designed for compatibility with Nginx and similar servers, the script streamlines the creation of a Root Certificate, Server Key, and Server Certificate with ease.

---

## 📋 Table of Contents

- [Features](#features)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Usage](#usage)
- [Generated Files](#generated-files)
- [Nginx Configuration](#nginx-configuration)
- [Client Installation](#client-installation)
- [Error Handling](#error-handling)
- [Troubleshooting](#troubleshooting)

---

## ✨ Features

- ✅ **Comprehensive Error Handling** - Try-catch exception handling for each step
- ✅ **Input Validation** - Validates FQDN format and argument count
- ✅ **Wildcard Certificate Support** - Generates certificates for both domain and subdomains
- ✅ **Automatic Cleanup** - Removes temporary files automatically
- ✅ **Color-coded Output** - Clear visual feedback (Success, Error, Info messages)
- ✅ **Detailed Logging** - Step-by-step progress reporting
- ✅ **2048-bit RSA Keys** - Enterprise-grade encryption
- ✅ **Automatic Rollback** - Cleans up partial files on failure
- ✅ **OpenSSL Validation** - Checks for OpenSSL availability

---

## 📦 Prerequisites

Before running the script, ensure you have:

- **Bash Shell** - Any modern version
- **OpenSSL** - v1.0.0 or later
- **Linux/Unix Environment** - Linux, macOS, or WSL on Windows
- **Execute Permissions** - To run the script

### Check if OpenSSL is installed:
```bash
openssl version
```

### Install OpenSSL (if needed):

**Ubuntu/Debian:**
```bash
sudo apt-get update
sudo apt-get install openssl
```

**CentOS/RHEL:**
```bash
sudo yum install openssl
```

**macOS:**
```bash
brew install openssl
```

---

## 📥 Installation

### 1. Download or clone the repository

```bash
git clone https://github.com/harikishore-javvaji/nginx-self-signed-wildcard-certificate.git
cd nginx-self-signed-wildcard-certificate
```

### 2. Make the script executable

```bash
chmod +x nginx-self-signed-wildcard-certificate.sh
```

---

## 🚀 Usage

### Basic Usage

```bash
./nginx-self-signed-wildcard-certificate.sh <server_FQDN>
```

### Example

```bash
./nginx-self-signed-wildcard-certificate.sh example.com
```

This command will:
- Generate a Root CA Certificate for trust establishment
- Create a Server Private Key (2048-bit RSA)
- Generate a Certificate Signing Request (CSR)
- Sign the certificate with the Root CA
- Create a Full Chain Certificate
- Clean up temporary files
- Display success confirmation

### Expected Output

```
[INFO] Starting certificate generation for: example.com
[SUCCESS] OpenSSL found
[INFO] Step 1: Generating Root CA Key...
[SUCCESS] Root CA Key generated successfully: root.key
[INFO] Step 2: Generating Root CA Certificate...
[SUCCESS] Root CA Certificate generated successfully: root.crt
[INFO] Step 3: Generating Server Private Key...
[SUCCESS] Server Private Key generated successfully: server.key
[INFO] Step 4: Generating Certificate Signing Request (CSR)...
[SUCCESS] CSR generated successfully: server.csr
[INFO] Step 5: Signing CSR with Root CA...
[SUCCESS] Server Certificate signed successfully: server.crt
[INFO] Step 6: Creating Full Chain Certificate...
[SUCCESS] Full Chain Certificate created successfully: fullchain.crt
[INFO] Step 7: Cleaning up temporary files...
[SUCCESS] Temporary files cleaned up

==========================================
[SUCCESS] Certificates generated successfully!
==========================================

Generated Files:
  Root Certificate:      root.crt
  Server Private Key:    server.key
  Full Chain Certificate: fullchain.crt

Nginx Configuration Usage:
  ssl_certificate      /path/to/fullchain.crt;
  ssl_certificate_key  /path/to/server.key;

Installation on Client Systems:
  Install root.crt on client systems to trust this certificate
==========================================
```

---

## 📄 Generated Files

The script generates three essential files:

| File | Purpose | Usage |
|------|---------|-------|
| **root.crt** | Root Certificate Authority | Install on client systems for trust |
| **server.key** | Server Private Key (2048-bit RSA) | Use in Nginx SSL configuration |
| **fullchain.crt** | Full Chain Certificate | Use in Nginx SSL configuration |

### Certificate Details

- **Validity Period**: 10 years (3650 days)
- **Wildcard Support**: *.example.com and example.com
- **Key Size**: 2048-bit RSA encryption
- **Format**: PEM

---

## ⚙️ Nginx Configuration

### 1. Copy certificates to Nginx SSL folder

```bash
sudo mkdir -p /etc/nginx/ssl
sudo cp fullchain.crt /etc/nginx/ssl/
sudo cp server.key /etc/nginx/ssl/
sudo chmod 600 /etc/nginx/ssl/server.key
```

### 2. Update Nginx Configuration

Add the following to your Nginx server block:

```nginx
server {
    listen 443 ssl http2;
    server_name example.com *.example.com;

    # SSL Configuration
    ssl_certificate      /etc/nginx/ssl/fullchain.crt;
    ssl_certificate_key  /etc/nginx/ssl/server.key;

    # Optional SSL settings
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
    ssl_prefer_server_ciphers on;

    # Your server configuration
    location / {
        proxy_pass http://localhost:8080;
    }
}

# Redirect HTTP to HTTPS
server {
    listen 80;
    server_name example.com *.example.com;
    return 301 https://$server_name$request_uri;
}
```

### 3. Test and reload Nginx

```bash
# Test Nginx configuration
sudo nginx -t

# Restart Nginx
sudo systemctl restart nginx
```

### Reference
For detailed Nginx SSL setup: [PhoenixNAP - Install SSL Certificate Nginx](https://phoenixnap.com/kb/install-ssl-certificate-nginx)

---

## 🔐 Client Installation

### Windows

To install the root certificate on Windows systems:

1. Download `root.crt` from your server
2. Double-click the file
3. Click "Install Certificate"
4. Choose "Local Machine"
5. Select "Place all certificates in the following store: Trusted Root Certification Authorities"
6. Click "Next" and "Finish"

Reference: [WindowsReport - Install Windows Root Certificates](https://windowsreport.com/install-windows-10-root-certificates/)

### Linux

To install the root certificate on Linux systems:

```bash
# Copy the certificate
sudo cp root.crt /usr/local/share/ca-certificates/

# Update CA certificates
sudo update-ca-certificates

# Verify installation
ls /etc/ssl/certs/ | grep -i root
```

Reference: [HowToUseLinux - Install CA Certificate on Linux](https://www.howtouselinux.com/post/install-a-ca-certificate-on-linux)

### macOS

To install the root certificate on macOS:

```bash
# Add to system keychain
sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain root.crt

# Or use Keychain Access GUI:
# 1. Open Keychain Access
# 2. Drag and drop root.crt into Keychain
# 3. Double-click the certificate
# 4. Set "Trust" to "Always Trust"
```

---

## 🛡️ Error Handling

The script includes comprehensive error handling for each step:

### What happens if something fails?

1. **Input Validation Fails**
   - Error message displayed
   - Script exits with code 1
   - No files are created

2. **OpenSSL Not Found**
   - Clear error message
   - Script exits immediately
   - Suggests installation

3. **Certificate Generation Fails**
   - Error-specific message shown
   - All previously created files automatically deleted
   - Script exits with error code

4. **File Creation Fails**
   - Automatic cleanup triggered
   - Warning message displayed
   - Error details provided

### Exit Codes

- `0` - Successful execution
- `1` - Error occurred (see error message for details)

---

## 🔧 Troubleshooting

### Issue: Command not found

**Solution:** Make the script executable
```bash
chmod +x nginx-self-signed-wildcard-certificate.sh
```

### Issue: OpenSSL not found

**Solution:** Install OpenSSL
```bash
# Ubuntu/Debian
sudo apt-get install openssl

# CentOS/RHEL
sudo yum install openssl

# macOS
brew install openssl
```

### Issue: Permission denied

**Solution:** Run with appropriate permissions
```bash
# Option 1: Make executable and run
chmod +x nginx-self-signed-wildcard-certificate.sh
./nginx-self-signed-wildcard-certificate.sh example.com

# Option 2: Run with bash
bash nginx-self-signed-wildcard-certificate.sh example.com
```

### Issue: Invalid FQDN format

**Solution:** Use a valid fully qualified domain name
```bash
# Valid examples:
./nginx-self-signed-wildcard-certificate.sh example.com
./nginx-self-signed-wildcard-certificate.sh api.example.com
./nginx-self-signed-wildcard-certificate.sh subdomain.example.co.uk

# Invalid examples (will fail):
./nginx-self-signed-wildcard-certificate.sh -example.com
./nginx-self-signed-wildcard-certificate.sh example
```

### Issue: Certificate not trusted by browser

**Solution:** Install `root.crt` on your client system (see [Client Installation](#client-installation) section)

### Issue: Nginx fails to restart

**Solution:** Check Nginx configuration
```bash
# Test configuration
sudo nginx -t

# Check error logs
sudo tail -f /var/log/nginx/error.log
```

---

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🤝 Contributing

Contributions are welcome! Feel free to submit issues and enhancement requests.

---

## 📧 Support

For issues and questions, please open an issue on the [GitHub repository](https://github.com/harikishore-javvaji/nginx-self-signed-wildcard-certificate).

---

**Last Updated:** June 2026
**Version:** 2.0 (Enhanced with Error Handling)
