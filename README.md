# Traefik + Mailcow (Let's Encrypt / IONOS)

Traefik als Reverse-Proxy mit **Let's Encrypt** (ACME) per **IONOS DNS-Challenge**. Erhält ein Zertifikat für die Mail-Domain inkl. `autoconfig`/`autodiscover`, leitet diese Subdomains auf die Mail-Oberfläche um und liefert die Zertifikate an **Mailcow** aus.

## Ablauf

- **Traefik**: ACME-Zertifikat für `MAIN_DOMAIN` + SANs (`BASE_DOMAIN`, `autoconfig.*`, `autodiscover.*`), Router für Mail-Host und Redirect von autoconfig/autodiscover.
- **traefik-certs-dumper**: Liest `acme.json`, schreibt Zertifikate in ein Dump-Verzeichnis, ruft nach Änderung ein Hook-Skript auf.
- **Hook** (`mailcow_hook.sh`): Kopiert Zertifikat und Key in das Mailcow-SSL-Verzeichnis; certs-dumper kann optional Mailcow-Container neu starten.

## Voraussetzungen

- Docker & Docker Compose
- Mailcow (z. B. unter `/opt/mailcow-dockerized`) mit Pfaden wie in `.env.example`
- IONOS API Key für DNS-Challenge

## Start

```bash
cp .env.example .env
# .env ausfüllen (IONOS_API_KEY, ACME_EMAIL, MAIN_DOMAIN, BASE_DOMAIN, …)

docker compose --env-file .env up -d
```

Secrets und Pfade stehen in `.env`; diese Datei nicht versionieren (siehe `.gitignore`).
