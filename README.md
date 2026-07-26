This repository contains the instruction and commands for running Espial from the pre-built docker images on Docker Hub.

# Espial

Espial is an open-source, web-based bookmarking server.

It allows mutiple accounts, but currently intended for self-host scenarios.

The bookmarks are stored in a sqlite3 database, for ease of deployment & maintenence.

The easist way for logged-in users to add bookmarks, is with the "bookmarklet", found on the Settings page.

## Source Repository

https://github.com/jonschoning/espial

## Running the pre-built Docker Hub Image

 - These commands use `docker compose` with settings in `docker-compose.yml`
 - Requires [Docker](https://docs.docker.com/get-docker/) (with Compose v2) on any platform: Linux, macOS, or Windows
 - POSIX shells (Linux, macOS, WSL, Git Bash) use `make`/`./espial-svc-*` — see `Makefile` for additional commands
 - Windows PowerShell uses `espial.ps1`/`espial-svc-*.ps1`, which mirror the same targets

1. Clone this repository

```
git clone https://github.com/jonschoning/espial-docker
cd espial-docker
```

2. Pull the image from Docker Hub

POSIX:

```
make pull
```

Windows (PowerShell):

```powershell
.\espial.ps1 pull
```

3. Start Espial

POSIX:

```
./espial-svc-start
```

Windows (PowerShell):

```powershell
.\espial-svc-start.ps1
```

 - When the app starts, it should create the DB `espial.sqlite3` in the current directory (or according to `docker-compose.yml`)

4. Create a user

```
docker compose exec espial ./migration createuser --userName myusername --userPassword myuserpassword
```

 - see `docker compose exec espial ./migration` for all available cli commands
 - use the `/app/data/` file prefix to access files on the host according to the bind mount volume inside the container, see `docker-compose.yml`

5. Import a pinboard bookmark file for a user (optional)

```
docker compose exec espial ./migration importbookmarks --userName myusername --bookmarkFile /app/data/sample-bookmarks.json
```

6. Import a firefox bookmark file for a user (optional)

```
docker compose exec espial ./migration importfirefoxbookmarks --userName myusername --bookmarkFile /app/data/firefox-bookmarks.json
```
    
7. Stop Espial

POSIX:

```
./espial-svc-stop
```

Windows (PowerShell):

```powershell
.\espial-svc-stop.ps1
```

> Note: `docker compose exec` commands (steps 4-6) are identical on every platform since they run inside the container.

## Running at Startup

### Linux: SystemD Service

copy this repo to `/opt/espial/`

a serivce unit is provided at `etc/systemd/system/espial.service`

which references:
  - `espial-svc-start`
  - `espial-svc-stop`

adjust `espial-svc-start` to control where logs are stored.

### Windows

`docker-compose.yml` already sets `restart: unless-stopped`, so once Docker Desktop is running, Espial restarts automatically along with it — no separate service is required.

If you want Espial to start as soon as you log in (before manually opening Docker Desktop), add a shortcut to `espial-svc-start.ps1` to your Startup folder (`shell:startup`), or register a scheduled task with Task Scheduler that runs:

```powershell
powershell.exe -ExecutionPolicy Bypass -File "C:\path\to\espial-docker\espial-svc-start.ps1"
```

## Base Image

`jonschoning/espial:espial`

is based on 

`gcr.io/distroless/base-debian12`

## Defaults

As specified in `docker-compose.yml`:
 - internal app port `3000` is exposed to port `80` on host
 - adjust as necessary

### Request IP Logging

Espial supports the `IP_FROM_HEADER` environment variable for request logging.

- `IP_FROM_HEADER=true`: log the client IP from the `X-Real-IP` or `X-Forwarded-For` header when present, and fall back to the peer address if neither header is available.
- `IP_FROM_HEADER=false`: log the peer address from the HTTP connection.

Only set `IP_FROM_HEADER=true` if your application is safely positioned **behind a trusted reverse proxy**.

### Session Key (`client_session_key.aes`)

Espial encrypts and signs login session cookies with a key at  `config/client_session_key.aes` inside the container. 
If it does not exist, a key is auto-generated inside the container.
However, switching to a new espial will cause a new key to be re-generating, forcing users to log in again.

To avoid the having to re-login when switching to a new docker image, Set `CLIENT_SESSION_KEY` to pin a stable key across recreations instead:

```yaml
environment:
  - CLIENT_SESSION_KEY=<base64-value>
```

To generate `<base64-value>`, use the `generatesessionkey` migration command:

```
docker compose exec espial ./migration generatesessionkey
```

Copy the printed value into `docker-compose.yml` (or an `.env` file) so it stays fixed across future deployments. Treat it like a secret: anyone with the key can forge valid session cookies.

### TLS / Reverse Proxy

A reverse proxy is the recommended approach for production deployments. Set `SSL_ONLY=true` whenever Espial is served over HTTPS to enable the `Secure` cookie flag and HTTP→HTTPS redirects.

#### Recommended: Reverse Proxy (Caddy, nginx, Cloudflare Tunnel, …)

Run Espial behind a reverse proxy that terminates TLS and forwards plain HTTP to Espial. This gives you automatic certificate management, HTTP/2 and HTTP/3 at the edge, and cleaner separation of concerns.

Minimal [Caddy](https://github.com/caddyserver/caddy) example:

Localhost without a real domain:

```caddyfile
https://localhost:3050 {
    reverse_proxy localhost:3000
}
```

or with a domain:

```caddyfile
espial.example.com {
  reverse_proxy 127.0.0.1:3000
}
```

With the domain setup:

- Caddy terminates TLS for `espial.example.com`.
- Espial continues listening on HTTP, locally on `127.0.0.1:3000`
  - If using Docker Compose, it would look like `espial:3000`
- Set `IP_FROM_HEADER=true` only when Espial is reachable solely through that trusted proxy.

If you are using Cloudflare:

- Prefer Cloudflare SSL mode `Full (strict)`.
- use `header_up X-Forwarded-For {http.request.header.CF-Connecting-IP}`
- If traffic can reach Espial directly without passing through your trusted proxy, do not enable `IP_FROM_HEADER=true`, because client IP headers can be spoofed.

#### Optional: In-Process TLS

For simple local or LAN deployments where a reverse proxy is impractical, Espial can terminate TLS directly. Mount your certificate and key files into the container and set the environment variables:

```yaml
environment:
  TLS_CERT_FILE: /app/data/tls/cert.pem
  TLS_KEY_FILE:  /app/data/tls/key.pem
  SSL_ONLY: true
volumes:
  - './tls:/app/data/tls:ro'
```

Espial reloads the certificate from disk automatically every 12 hours. To trigger an immediate reload without restarting the container:

```bash
docker compose kill -s HUP espial
```

See the [Espial README](https://github.com/jonschoning/espial#tls--reverse-proxy) for full details including Let's Encrypt and self-signed certificate setup.
