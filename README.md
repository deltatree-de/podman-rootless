# Rootless Podman mit Docker-API im Container

Dieses Repository enthält ein Dockerfile, das ein Ubuntu-basiertes Container-Image mit **Podman im Rootless-Modus** aufbaut. Die Containerinstanz stellt die **Docker-kompatible REST-API** über **Port `2375` (TCP)** bereit.

---

## 🔧 Features

- **Podman rootless** (kein Root im Container)
- **Docker-kompatible API** (`podman system service`)
- Konfiguriertes `fuse-overlayfs` + isoliertes Storage-Verzeichnis (`/tmp/storage`)
- Unterstützt Image-Builds, Container-Start, Docker-CLI (via `DOCKER_HOST`)
- Keine Host-Volumes oder externe Konfiguration notwendig

---

## 🚀 Verwendung

### 1. Image bauen

```bash
podman build -t podman-docker-api .
```

### 2. Container starten

```bash
podman run -it --rm \
  -p 2375:2375 \
  podman-docker-api
```

### 3. Docker-kompatible Tools verbinden

```bash
export DOCKER_HOST=tcp://localhost:2375
docker info
docker run --rm alpine echo "läuft"
```

---

## ⚠ Wichtige Hinweise zur Umgebung

Rootless Podman im Container benötigt:

- Einen Linux-Host mit aktiver Unterstützung für User-Namespaces:
  - `kernel.unprivileged_userns_clone = 1`
  - funktionierendes `newuidmap` / `newgidmap` (mit SUID)
  - OverlayFS & fuse unterstützt

---

## 🔒 Sicherheit

- Die Docker-kompatible API auf Port `2375` ist **nicht gesichert** (kein Auth, kein TLS)
- Nur im lokalen, isolierten Netzwerk einsetzen
- Alternativ: nur `127.0.0.1` binden oder via SSH tunnel

---

## ✅ Alternative

Statt Rootless-Podman im Container zu betreiben, wird empfohlen:

```bash
podman system service --time=0 tcp:0.0.0.0:2375
```

→ Direkt auf dem Host starten (z. B. für CI/CD oder Entwickler-PC)

---
