# MITM Attack Simulation Testing Guide

## Prerequisites
- Wireshark installed (download from https://www.wireshark.org/)
- System running (docker-compose up --build)
- JWT token generated (cd api && node generateToken.js)

## Step 1: HTTP Mode Setup
1. Backup current nginx.conf:
   ```powershell
   cp nginx/nginx.conf nginx/nginx.conf.https
   ```

2. Edit nginx/nginx.conf to disable SSL:
   - Comment out these lines:
     ```
     # ssl_certificate /etc/nginx/certs/server.crt;
     # ssl_certificate_key /etc/nginx/certs/server.key;
     # ssl_protocols TLSv1.2 TLSv1.3;
     # ssl_prefer_server_ciphers on;
     # ssl_ciphers HIGH:!aNULL:!MD5;
     ```
   - Change `listen 443 ssl;` to `listen 80;`

3. Restart Nginx:
   ```powershell
   docker-compose restart nginx
   ```

## Step 2: Capture HTTP Traffic with Wireshark
1. Open Wireshark
2. Select your network interface (e.g., "Ethernet" or "Wi-Fi")
3. Click "Start" to begin capturing packets
4. In a new terminal, send a test request:
   ```powershell
   $token = node .\api\generateToken.js
   curl -X POST "http://localhost/task" -H "Authorization: Bearer $token" -H "Content-Type: application/json" -d '{"task":"mitm-test"}'
   ```
5. Click "Stop" in Wireshark to end capture
6. In Wireshark, apply filter: `http`
7. **Demonstrate visibility:**
   - Expand HTTP packets
   - Show request headers (including Authorization with JWT token)
   - Show request payload in plain text: `{"task":"mitm-test"}`
   - JWT token is fully readable

## Step 3: HTTPS Mode Setup
1. Restore HTTPS configuration:
   ```powershell
   cp nginx/nginx.conf.https nginx/nginx.conf
   ```

2. Restart Nginx:
   ```powershell
   docker-compose restart nginx
   ```

## Step 4: Capture HTTPS Traffic with Wireshark
1. Start a new capture in Wireshark (same interface)
2. Send HTTPS test request:
   ```powershell
   $token = node .\api\generateToken.js
   curl -k -X POST "https://localhost/task" -H "Authorization: Bearer $token" -H "Content-Type: application/json" -d '{"task":"secure-test"}'
   ```
3. Stop capture
4. Apply filter: `tls` or `ssl`
5. **Demonstrate encryption:**
   - Packets show TLS handshake
   - No readable HTTP headers
   - No visible JWT token
   - No readable payload - all data is encrypted

## Key Observations
- **HTTP Mode**: Vulnerable to MITM - credentials and data exposed
- **HTTPS Mode**: Secure - traffic encrypted, prevents eavesdropping

## Screenshots to Capture
1. Wireshark HTTP capture showing plain text JWT token
2. Wireshark HTTP capture showing readable payload
3. Wireshark HTTPS capture showing encrypted packets
4. Before/after comparison of the same request in HTTP vs HTTPS
