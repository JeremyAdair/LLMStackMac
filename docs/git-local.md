# Local Git server (Forgejo)

This stack includes an optional Forgejo service for a local, lightweight git server.
Forgejo is a community-run, GPL-licensed fork of Gitea that works well in homelab and
air-gapped environments because it is self-contained and has minimal external
dependencies.

## Start the git server

```bash
docker compose \
  -f compose/docker-compose.yml \
  -f compose/forgejo/docker-compose.yml \
  up -d
```

The web UI is exposed on `http://localhost:3000`. SSH access is exposed on port 2222.

Forgejo runs as a non-root user. If you need to match host ownership, set
`FORGEJO_UID` and `FORGEJO_GID` in `.env` before starting the service.

## Create an admin user

1) Open `http://localhost:3000`.
2) Complete the setup form, including creating the first admin user.
3) Log in and confirm the instance is reachable.

## Add an SSH key

1) In Forgejo, open Settings and select SSH Keys.
2) Add your public key.

## Create a repo

1) Click New Repository.
2) Choose a name and visibility, then create the repository.

## Clone from another machine

Use the SSH endpoint on port 2222:

```bash
git clone ssh://git@<host-ip>:2222/<user>/<repo>.git
```

## Common commands

```bash
git status
git add .
git commit -m "Describe change"
git push
```

## Backup and restore

Forgejo stores all data in the named Docker volume `forgejo_data`. Back it up with a
one-off container and a tarball on the host:

```bash
mkdir -p backups
docker run --rm \
  -v forgejo_data:/data:ro \
  -v "$(pwd)/backups:/backups" \
  alpine \
  tar -czf /backups/forgejo-data-$(date +%F).tar.gz -C /data .
```

To restore, stop Forgejo and extract the tarball into the volume:

```bash
docker compose \
  -f compose/docker-compose.yml \
  -f compose/forgejo/docker-compose.yml \
  down

docker run --rm \
  -v forgejo_data:/data \
  -v "$(pwd)/backups:/backups" \
  alpine \
  sh -c "rm -rf /data/* && tar -xzf /backups/forgejo-data-YYYY-MM-DD.tar.gz -C /data"
```

Do not mount the `forgejo_data` volume into other containers.
