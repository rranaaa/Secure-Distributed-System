Got it — you want it as a **clean README file**, not just explanations. Here is the **final polished README version** you can paste directly into your repo.

---

# 🔐 MITM Attack Simulation (Wireshark)

## 📌 Objective

Demonstrate the difference between **insecure HTTP** and **secure HTTPS** communication by capturing network traffic using Wireshark.

---

# 🔴 Step 1: HTTP Mode (Insecure)

## ▶️ Run automated script

```powershell
.\mitm-http-mode.ps1
```

This script:

* Switches Nginx to HTTP
* Restarts containers
* Waits for RabbitMQ
* Sends a test request

---

## 🧪 Capture HTTP Traffic

1. Open Wireshark
2. Select:

   ```
   Npcap Loopback Adapter
   ```
3. Start capture
4. Apply filter:

   ```
   tcp.port == 80
   ```

---

## 🔍 Inspect Packet

* Right-click → **Follow → TCP Stream**

### You will see:

```http
POST /task HTTP/1.1
Authorization: Bearer eyJhbGciOiJIUzI1Ni...
Content-Type: application/json

{"task":"mitm-http-test"}
```

---

## 📸 Required Screenshots (HTTP)

* Authorization header visible
* JWT token readable
* JSON payload readable
* Full HTTP request

---

## 🧠 Observation

> In HTTP mode, all traffic is transmitted in plaintext. Wireshark clearly shows the JWT token and request payload, making the system vulnerable to Man-in-the-Middle (MITM) attacks.

---

# 🔵 Step 2: HTTPS Mode (Secure)

## ▶️ Run automated script

```powershell
.\mitm-https-mode.ps1
```

This script:

* Restores HTTPS configuration
* Enables TLS encryption
* Restarts system safely

---

## 🧪 Capture HTTPS Traffic

1. Start a new capture in Wireshark
2. Use filter:

   ```
   tls
   ```

   or

   ```
   tcp.port == 443
   ```

---

## 🔍 Inspect Packet

You will see:

```
TLSv1.2 / TLSv1.3
Encrypted Application Data
```

---

## ❌ What you will NOT see

* No Authorization header
* No JWT token
* No JSON payload

---

## 📸 Required Screenshots (HTTPS)

* TLS packets
* Encrypted Application Data
* No readable request data

---

## 🧠 Observation

> In HTTPS mode, communication is encrypted using TLS. Wireshark only shows encrypted packets, and sensitive data such as JWT tokens and payloads are not visible, preventing MITM attacks.

---

# ⚠️ Common Issues & Fixes

## ❌ No HTTP packets captured

* Use **Npcap Loopback Adapter**
* Use filter:

  ```
  tcp.port == 80
  ```

---

## ❌ RabbitMQ connection error (ECONNREFUSED)

* Wait for RabbitMQ to start
* Restart API containers:

  ```powershell
  docker restart api1 api2 api3
  ```

---

## ❌ Scripts stop working after HTTP mode

* Restore HTTPS:

  ```powershell
  .\mitm-https-mode.ps1
  ```

---

# 📊 Final Comparison

| Feature           | HTTP         | HTTPS    |
| ----------------- | ------------ | -------- |
| Headers visible   | ✅ Yes        | ❌ No     |
| JWT token visible | ✅ Yes        | ❌ No     |
| Payload readable  | ✅ Yes        | ❌ No     |
| Encryption        | ❌ None       | ✅ TLS    |
| Security          | ❌ Vulnerable | ✅ Secure |

---

# 🎯 Conclusion

> HTTP exposes sensitive data such as authentication tokens and request payloads, making it vulnerable to MITM attacks. HTTPS protects communication using TLS encryption, ensuring confidentiality and security.

---
