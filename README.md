# Secure Distributed System

This repository implements a secure distributed system with observability and security analysis.

## Architecture

- `nginx`: HTTPS gateway, reverse proxy, load balancer, and rate limiter
- `api1`, `api2`, `api3`: API service replicas
- `rabbitmq`: message broker for asynchronous task queueing
- `worker`: background task processor
- `db`: PostgreSQL database for audit logs and request state tracking

## Features

- HTTPS communication via Nginx
- JWT authentication for API requests
- Request ID tracking across services
- Audit logging in PostgreSQL
- Request state tracking: RECEIVED, AUTHENTICATED, QUEUED, CONSUMED, PROCESSED, FAILED
- Load balancing across three API instances
- Rate limiting at the gateway layer
- Asynchronous processing through RabbitMQ

## Prerequisites

- Docker Engine installed
- Docker Compose available
- Windows PowerShell or another shell

## Setup

1. Open a terminal in the repository root.
2. Build and start the system:

```powershell
docker-compose up --build
```

3. Confirm the following services are running:

- `secure_nginx` on ports `80` and `443`
- `secure_rabbitmq` on ports `5672` and `15672`
- `secure_db` on port `5432`
- `api1`, `api2`, `api3`, and `worker`

## Generate a JWT

The API service uses the secret `mysecretkey`.

From the root folder, run:

```powershell
cd api
node generateToken.js
```

Use the generated token in the `Authorization` header:

```http
Authorization: Bearer <token>
```

## Test the API

Send a task request through Nginx over HTTPS:

```powershell
curl -k -X POST https://localhost/task -H "Authorization: Bearer <token>" -H "Content-Type: application/json" -d '{"task":"sample"}'
```

Expected response:

- `200 OK`
- JSON containing `task queued successfully`
- `request_id`
- `handled_by` set to one of `api1`, `api2`, or `api3`

## Rate Limiting

Nginx limits requests by client IP at `10r/m` with a `burst=5` policy.

Excessive requests should return a `429 Too Many Requests` response.

## RabbitMQ and Worker Flow

1. API validates JWT and generates a unique request ID.
2. API logs audit and state entries in PostgreSQL.
3. API sends the task to RabbitMQ.
4. The worker consumes the task and verifies the internal service token.
5. The worker logs `CONSUMED` and `PROCESSED` states.

## Database Schema

The PostgreSQL initialization script is at `db/init.sql`.

It creates:

- `audit_logs`
- `request_states`

## Testing Requirements

Run the comprehensive test suite:

```powershell
.\run-tests.bat
```

This executes all tests in sequence:
- Normal request flow
- Load balancing verification
- Unauthorized access testing
- Rate limiting demonstration
- Worker processing check
- Database audit log verification

Individual test scripts are in the `scripts/` directory for targeted testing.

## HTTPS vs HTTP / MITM Testing

Check the MITM-Testing-guide.md

## Notes

- The Nginx configuration file is `nginx/nginx.conf`.
- The self-signed cert and key are stored in `nginx/certs/server.crt` and `nginx/certs/server.key`.
- The API middleware is located at `api/middleware/auth.js`.
- The request tracking logic is implemented in `api/db.js` and `worker/db.js`.

## Helpful Commands

```powershell
# Start the full stack
docker-compose up --build

# Stop the stack
docker-compose down

# View Nginx logs
docker logs secure_nginx

# View RabbitMQ management UI
# Open browser: http://localhost:15672

# View database container logs
docker logs secure_db
```
#
