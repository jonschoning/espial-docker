This repository contains the instruction and commands for running Espial from the pre-built docker images on Docker Hub.

# Espial

Espial is an open-source, web-based bookmarking server.

It allows mutiple accounts, but currently intended for self-host scenarios.

The bookmarks are stored in a sqlite3 database, for ease of deployment & maintenence.

The easist way for logged-in users to add bookmarks, is with the "bookmarklet", found on the Settings page.

## Source Repository

https://github.com/jonschoning/espial

## Running the pre-built Docker Hub Image (POSIX Only)

 - These commands use docker-compose with settings in `docker-compose.yml`
 - see `Makefile` for additional commands

1. Clone this repository

```
git clone https://github.com/jonschoning/espial-docker
cd espial-docker
```

2. Pull the image from Docker Hub

```
make pull
```

3. Start Espial

```
./espial-svc-start
```

 - When the app starts, it should create the DB `espial.sqlite` in the current directory (or according to `docker-compose.yml`)

4. Create a user

```
docker-compose exec espial ./migration createuser --conn /app/data/espial.sqlite3 --userName myusername --userPassword myuserpassword
```

 - see `docker-compose exec espial ./migration` for all available cli commands
 - the `/app/data/` prefix is necessary as it is the internal volume inside the container, see `docker-compose.yml` to adjust 

5. Import a bookmark file for a user (optional)

```
docker-compose exec espial ./migration importbookmarks --conn /app/data/espial.sqlite3 --userName myusername --bookmarkFile /app/data/sample-bookmarks.json
```

6. Stop Espial

```
./espial-svc-stop
```


## SystemD Service

copy this repo to `/opt/espial/`

a serivce unit is provided at `etc/systemd/system/espial.service`

which references:
  - `espial-svc-start`
  - `espial-svc-stop`

adjust `espial-svc-start` to control where logs are stored.

## Base Image

`jonschoning/espial:espial`

is based on 

`jonschoning/espial:scratch`

which can be found here:

https://github.com/jonschoning/espial-scratch

## Defaults

default app http port: `3000`

ssl: use reverse proxy
