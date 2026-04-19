# Blog Infrastructure

This repository provides the infrastructure for deploying a blog platform using Docker Compose, Caddy, and Kuno (backend/frontend). The setup is designed for ARM64 architecture and supports both single and multiple global Caddy service modes.

---

## Contents
- [Overview](#overview)
- [Directory Structure](#directory-structure)
- [Environment Variables](#environment-variables)
- [Build Instructions](#build-instructions)
- [Running the Stack](#running-the-stack)
- [Caddy Configuration](#caddy-configuration)
- [Docker Compose Services](#docker-compose-services)
- [Notes](#notes)

---

## Overview
- **Kuno**: Main blog service (backend/frontend) built for ARM64.
- **Caddy**: Reverse proxy and TLS termination, with Cloudflare DNS support.
- **Docker Compose**: Orchestrates containers and networks.

---

## Directory Structure
- `run.sh` – Main entry script to build, configure, and run the stack.
- `build.sh` – Builds the Kuno Docker image for ARM64.
- `docker-compose.yml` – Defines the Kuno service and networks.
- `docker-compose.root-caddy.yml` – Defines the Caddy service and volumes.
- `.env.sample` – Sample environment variables for configuration.
- `.gitignore` – Files and directories to ignore in git.
- `caddy_global/Caddyfile` – Caddy reverse proxy configuration.
- `caddy_global/Dockerfile` – Dockerfile for building Caddy with Cloudflare DNS plugin.

---

## Environment Variables
Copy `.env.sample` to `.env` and adjust as needed:

- `ADMIN_USERNAME`, `ADMIN_PASSWORD`: Registration service credentials
- `MULTIPLE_CADDY_GLOBAL`: Set to `true` for multiple global Caddy services
- `KUNO_SERVER_ADDRESS`: IP or domain for the server
- `KUNO_DATA_PATH`: Path for Kuno data (default: `./blog-data`)
- `JWT_SECRET`: Secret for JWT authentication
- `HTTP_PORT`, `HTTPS_PORT`: Ports for Caddy
- `CF_API_TOKEN`: Cloudflare API token for DNS-based TLS

---

## Build Instructions
To build the Kuno image for ARM64:

```sh
./build.sh
```
This will clone the Kuno repo and build the Docker image using `docker buildx`.

---

## Running the Stack
Use the `run.sh` script to start the stack:

```sh
./run.sh [build|up|down|...]
```
- `build`: Builds the Kuno image (clones repo and builds with buildx)
- Other arguments are passed to `docker compose` (e.g., `up -d`, `down`)

The script:
- Ensures required Docker networks exist
- Sources environment variables from `.env`
- Sets up Compose files and TLS config based on environment
- Runs `docker compose` with the provided arguments

---

## Caddy Configuration
- The Caddyfile (`caddy_global/Caddyfile`) sets up a reverse proxy for the Kuno service.
- TLS is configured based on whether the server address is an IP (internal TLS) or domain (Cloudflare DNS-based TLS).
- The Caddy Docker image is built with the Cloudflare DNS plugin (see `caddy_global/Dockerfile`).

---

## Docker Compose Services
### docker-compose.yml
- **kuno**: Main service
  - Image: `ictrun/kuno:arm64`
  - Networks: `kuno_internal_net`, `caddy_net`
  - Volumes: Data path for persistent storage
  - Environment: API URL, DB path, upload dir, JWT secret, etc.

### docker-compose.root-caddy.yml
- **caddy**: Reverse proxy
  - Build context: `./caddy_global`
  - Ports: 80 (HTTP), 443 (HTTPS)
  - Volumes: Caddyfile, data, config
  - Networks: `caddy_net`

---

## Notes
- `.gitignore` excludes `.env`, `caddy_certs`, and the `kuno` directory.
- For production, ensure secrets are set securely and not committed to version control.
- For more advanced deployment, see the scripts and comments in `run.sh` and `build.sh`.

---

## Example Usage
```sh
cp .env.sample .env
# Edit .env as needed
./build.sh
./run.sh up -d
```

To stop:
```sh
./run.sh down
```

---

## License
See upstream Kuno repository for license details.
