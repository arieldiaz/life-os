# Secrets layer runbook — self-hosted Infisical

One owned source of truth for every secret and env variable in your life-os:
a single self-hosted [Infisical](https://infisical.com) instance on your
always-on machine (the "mini" elsewhere in this repo), replacing scattered
`.env` files, keychain hacks, and copy-paste ramp-up. Repos hold no plaintext
secrets; processes hydrate their environment from Infisical at launch; agents
authenticate with machine identities that expose only their own credentials.

**Pinned version: `infisical/infisical:v0.161.14`** (modern Infisical images
use plain `vX.Y.Z` tags; the old `-postgres` suffix is gone). Update the pin
here and in `docker-compose.yml` together.

## Layout

| Piece | Where |
|-------|-------|
| Compose stack (backend, db, redis, migration) | `infra/secrets/docker-compose.yml` |
| Bootstrap secrets (`ENCRYPTION_KEY`, `AUTH_SECRET`, PG creds) | `infra/secrets/.env` — gitignored, mode 600 |
| Reverse-proxy vhost | `infra/secrets/Caddyfile.snippet` |
| Nightly backup | `infra/secrets/backup/` (script + LaunchAgent template) |
| Agent integration smoke test | `infra/secrets/verify-agents.sh` |

Host port: **8090 → container 8080**. Postgres and Redis are never exposed on
the host — compose network only. Keep the hostname reachable only on your
tailnet/LAN (private-IP DNS record); Infisical needs no public exposure.

## Bring-up

1. `cp .env.example .env && chmod 600 .env`, fill it in (`openssl rand -hex 16`
   for `ENCRYPTION_KEY`, `openssl rand -base64 32` for `AUTH_SECRET`, a long
   random `POSTGRES_PASSWORD`). Confirm `.env` is gitignored BEFORE the first
   commit.
2. `docker compose up -d` in `infra/secrets/`. Verify
   `curl -s -o /dev/null -w "%{http_code}" http://localhost:8090` → 200.
3. Make Docker survive reboots. On a Mac mini with Colima:
   `brew services start colima` (the compose services are
   `restart: unless-stopped`, so they follow the daemon up).
4. Append `Caddyfile.snippet` to your Caddyfile (edit the domain), reload
   Caddy, add the DNS record pointing at the machine's private/tailnet IP.
5. First run in the browser: create the admin account, **download the
   Emergency Kit**, then Server Admin Console → Settings → **disable signups**.
6. Store the Emergency Kit and a copy of `infra/secrets/.env` OFF this
   machine (password manager, encrypted drive — your call). Without the
   `ENCRYPTION_KEY`, every backup is unrecoverable.

## Structure

One org. Projects that mirror how you slice your world — a `core` project for
shared infra keys (DNS API token, tailnet keys, LLM API keys, git PATs) and an
`agents` project with one folder path per agent (`/liv/...`, `/max/...`).
Environments `dev` and `prod`; skip staging. Key naming: `SCREAMING_SNAKE`
prefixed by service — `SLACK_BOT_TOKEN`, `NOTION_TOKEN`, `NOTION_DB_ID_TASKS`.
The secret name always matches what the code reads.

## Day-to-day use

CLI on every machine, pointed at YOUR instance (never Infisical Cloud):

```
brew install infisical/get-cli/infisical
export INFISICAL_API_URL=https://secrets.your-domain.com/api
infisical login
```

Per repo: `infisical init` once (writes a committed `.infisical.json`), then

```
infisical run --env=dev -- <command>
```

No `.env` files with real values anywhere, ever; `.env.example` placeholders
are fine. For launchd/systemd services that can't wrap commands, hydrate at
launch inside the start script — login with a machine identity, then
`eval "$(infisical export --format=dotenv-export ...)"` and exec the daemon.
Never a static dotenv file on disk.

## Machine identities (agents)

One identity per agent, **Universal Auth**, **read-only**, scoped to the
agent's own path (`/liv/**` for Liv). Humans write and rotate secrets;
identities only read. The identity's client id/secret is the single bootstrap
credential stored with the agent runtime (login keychain or a mode-600 file) —
rotating everything downstream never touches agent config again.

Runtime pattern:

```
export INFISICAL_TOKEN=$(infisical login --method=universal-auth --client-id=$CLIENT_ID --client-secret=$CLIENT_SECRET --plain --silent)
infisical run --projectId <agents-project-id> --path /liv --env prod -- <agent start command>
```

`verify-agents.sh` smoke-tests each identity: login works, its own secrets
pull, one harmless authenticated call per integration (Slack `auth.test`,
Notion `users/me`), and — the part worth automating — a scoping check that
each agent's identity FAILS to read the other agents' paths.

## Backups

`backup/backup-infisical.sh` (template — edit the repo path): nightly
`pg_dump` from the db container, gzipped and dated, 14 days retained, plus a
copy of the bootstrap `.env` beside the dumps. Schedule it with the LaunchAgent
template (or cron/systemd-timer). **A dump without the `ENCRYPTION_KEY` is
noise, not a backup** — the off-machine copy of `.env` is the actual
disaster-recovery plan.

Restore test (scratch container, safe anytime):

```
docker run -d --name pg-restore-test -e POSTGRES_PASSWORD=scratch postgres:14-alpine
sleep 6
docker exec pg-restore-test psql -U postgres -qc "create role infisical login;"
gunzip -c ~/backups/infisical/infisical-<date>.sql.gz | docker exec -i pg-restore-test psql -U postgres -q
docker exec pg-restore-test psql -U postgres -tc "select count(*) from organizations;"
docker rm -f pg-restore-test
```

(The `create role` line matches the dump's object owner; without it the
restore works but spews ownership errors.)

## Upgrades

Release notes → manual backup → bump both `image:` pins in
`docker-compose.yml` → `docker compose up -d` (the `db-migration` service runs
schema migrations before the backend starts) → verify 200 + UI login → update
the pin at the top of this file, commit.

## Bootstrap exceptions

Three secrets can't live in Infisical, by construction. Name them explicitly
in your instance's runbook and nowhere else:

1. `infra/secrets/.env` — decrypts Infisical itself.
2. Your reverse proxy's DNS API token — the proxy fronts Infisical, so it must
   start before/without it.
3. Machine-identity client credentials — the key that unlocks the rest.

## Governance

- No secret values in git commits, agent instruction files, logs, task
  descriptions, or session summaries. Names only.
- Machine identities are read-only. Humans write and rotate.
- A secret printed or committed by accident = stop, rotate, scrub, continue.
- Owned-first: no cloud syncs (Vercel, GitHub Actions, …) until they earn a
  deliberate decision.
