---
layout: default
title: Recetas Rápidas (W1–W10)
description: "Índice de referencia rápida: qué hacer para cada tipo de cambio en el fork personal. La puerta de entrada antes de tocar cualquier archivo."
---

# Recetas Rápidas (W1–W10)

> **Puerta obligatoria.** Antes de tocar cualquier archivo del fork, identifica en qué receta encaja tu cambio. Si no encaja en ninguna, es señal de que debes re-preguntar — el modelo upstream es la única verdad (ver [Matriz de Decisión](/fork-docs/architecture/02-matriz-de-decision/)).

> **Caso 2026-10-05 — espacios Herdr.** No se publica `session.json` ni se aplica el home con `omarchy-reinstall-configs`. El procedimiento está en [Espacios Herdr de la flota](/fork-docs/operations/05-espacios-herdr/).

---

## Índice de recetas

| Receta | Tipo de cambio | Dónde en el fork | Validación local | Llega a otras máquinas |
| :--- | :--- | :--- | :--- | :--- |
| **W1** — Webapp o launcher | Archivo `.desktop` + icono | `applications/` | `omarchy dev pkg-test` + `omarchy refresh-applications` | `omarchy update` |
| **W2** — Comando / ejecutable propio | Script `omarchy-*` | `bin/omarchy-*` | `omarchy dev pkg-test` | `omarchy update` |
| **W3** — Wrapper de terceros (CLI, mise) | Instalador en `install/user/*.sh` | `install/user/` | `omarchy refresh-applications` | `omarchy update` |
| **W4** — Config de usuario | Archivo en `config/<app>/` | `config/` | `omarchy dev pkg-test` + `omarchy refresh config <archivo>` | `omarchy update` |
| **W5** — Tema | Archivos en `themes/` | `themes/` | `omarchy dev pkg-test` + `omarchy refresh theme` | `omarchy update` |
| **W6** — Paquetes del sistema | Lista en `install/*.packages` | `install/` | `omarchy reinstall pkgs` | `omarchy update` |
| **W7** — Publicar al CDN | Dispatch del workflow CI/CD | `omarchy-pkgs` | `gh workflow run ... -f dry_run=true` | automático tras el push |
| **W8** — Onboarding de máquina nueva | Script de bootstrap o 7 pasos manuales | — | ver [Onboarding](/fork-docs/guide/02-onboarding-maquinas/) | — |
| **W9** — Cadencia / sync con upstream | Rebase de `personal` sobre el espejo local `upstream` (fetch desde `omacom:quattro`) | `robert-flo/omarchy` | dispatch con nuevo `pkgver` | `omarchy update` |
| **W10** — Migración de usuarios existentes | Script en `migrations/<ts>.sh` | `migrations/` | `omarchy dev pkg-test` + ejecutar migración local | `omarchy update` (automático) |

---

## W1 — Agregar o actualizar una webapp / launcher

**Cuándo:** Quieres añadir un acceso directo (webapp, app nativa o comando TUI) al menú de aplicaciones.

```bash
# 1. Crea el archivo .desktop en el fork
vim applications/MiApp.desktop

# 2. Opcionalmente añade el icono (PNG o SVG)
cp mi-icono.png applications/icons/mi-app.png

# 3. Valida localmente
omarchy dev pkg-test
omarchy refresh-applications   # materializa en ~/.local/share/applications/

# 4. Publica cuando estés satisfecho (W7)
gh workflow run release-personal.yml -R robert-flo/omarchy-pkgs \
  --ref personal -f version=v<TAG>
```

Referencia completa: [Guía de Webapps](/fork-docs/guide/03-uso-diario/).

---

## W2 — Agregar un ejecutable / comando propio (`omarchy-*`)

**Cuándo:** Quieres añadir un nuevo subcomando al CLI de Omarchy (`omarchy mi-comando`).

```bash
# 1. Crea el script con los metadatos obligatorios
cat > bin/omarchy-mi-comando << 'EOF'
#!/usr/bin/env bash
# omarchy:summary=Descripción de una línea
# omarchy:args=
# omarchy:examples=omarchy mi-comando
set -euo pipefail
# ... lógica del comando
EOF
chmod +x bin/omarchy-mi-comando

# 2. Valida localmente
omarchy dev pkg-test
omarchy mi-comando   # prueba directa

# 3. Publica (W7)
gh workflow run release-personal.yml -R robert-flo/omarchy-pkgs \
  --ref personal -f version=v<TAG>
```

> **Regla:** los scripts en `bin/` llevan obligatoriamente los metadatos `omarchy:summary=`, `omarchy:args=` y `omarchy:examples=`.

---

## W3 — Agregar un wrapper de terceros (CLI de IA, mise, npm)

**Cuándo:** Quieres que un CLI instalado por `mise`, `npm`, o un instalador oficial esté disponible en todas las máquinas.

```bash
# 1. Agrega la instalación a install/user/mi-tool.sh (siguiendo la
#    estructura de install/user/mise.sh como plantilla)
vim install/user/mi-tool.sh

# 2. Valida localmente
omarchy refresh-applications   # ejecuta install/user/*.sh idempotentemente

# 3. Publica (W7)
gh workflow run release-personal.yml -R robert-flo/omarchy-pkgs \
  --ref personal -f version=v<TAG>
```

> **Antipatrón a evitar:** scripts sueltos por máquina o instalaciones manuales. Todo debe pasar por `install/user/*.sh` para viajar por `omarchy update`.

---

## W4 — Modificar una config de usuario (kitty, foot, hypr, shell…)

**Cuándo:** Quieres cambiar un archivo de configuración que vive en `~/.config/`.

```bash
# 1. Edita el archivo en el fork
vim config/kitty/kitty.conf

# 2. Valida localmente
omarchy dev pkg-test
omarchy refresh config kitty/kitty.conf   # aplica en ~/.config/ del usuario actual

# 3. Si el cambio debe materializarse en ~/ de usuarios EXISTENTES en otras máquinas,
#    considera también una migración (W10) para que sea automático.

# 4. Publica (W7)
gh workflow run release-personal.yml -R robert-flo/omarchy-pkgs \
  --ref personal -f version=v<TAG>
```

---

## W5 — Modificar o agregar un tema

**Cuándo:** Quieres añadir o cambiar el tema visual (colores, fuentes, wallpaper).

```bash
# 1. Modifica los archivos en themes/
vim themes/mi-tema/

# 2. Valida localmente
omarchy dev pkg-test
omarchy refresh theme   # aplica el tema en el entorno actual

# 3. Publica (W7)
gh workflow run release-personal.yml -R robert-flo/omarchy-pkgs \
  --ref personal -f version=v<TAG>
```

---

## W6 — Modificar el set de paquetes del sistema

**Cuándo:** Quieres añadir o quitar un paquete de la lista de instalación base del fork.

```bash
# 1. Edita la lista de paquetes
vim install/omarchy-base.packages   # o omarchy-other.packages

# 2. Valida localmente (instala los paquetes faltantes con --needed)
omarchy reinstall pkgs

# 3. Publica (W7)
gh workflow run release-personal.yml -R robert-flo/omarchy-pkgs \
  --ref personal -f version=v<TAG>
```

---

## W7 — Publicar un cambio al CDN (dispatch del CI/CD)

**Cuándo:** Tienes cambios commiteados en la rama `personal` y quieres distribuirlos a todas las máquinas.

```bash
# Siempre desde omarchy-pkgs, siempre --ref personal
# El pkgrel se deriva automáticamente (pkgver nuevo → 99; mismo pkgver → +1)

# Opcional: ensayo sin publicar (recomendado para primeras publicaciones)
gh workflow run release-personal.yml -R robert-flo/omarchy-pkgs \
  --ref personal -f version=v<TAG> -f dry_run=true

# Publicación real
gh workflow run release-personal.yml -R robert-flo/omarchy-pkgs \
  --ref personal -f version=v<TAG>

# Verificar que el run terminó verde
gh run watch --exit-status -R robert-flo/omarchy-pkgs
```

> **Regla de oro:** dispatch SIEMPRE con `--ref personal`. Si el guard `fail-fast` aborta, es porque la rama era incorrecta — re-disparar con `--ref personal`.

---

## W8 — Onboarding de una máquina nueva

**Cuándo:** Quieres incorporar una laptop, desktop o VM Arch Linux nueva al sistema personal.

Ver la guía completa: **[Onboarding de Máquinas](/fork-docs/guide/02-onboarding-maquinas/)** (7 pasos).

Script desatendido:

```bash
curl -fsSL https://raw.githubusercontent.com/robert-flo/fork-docs/main/scripts/bootstrap-omarchy-machine.sh | bash
```

---

## W9 — Cadencia / Sync con upstream (nuevo release de Omarchy)

**Cuándo:** `omacom/omarchy` publicó un nuevo tag (`vX.Y.Z`) y quieres actualizar el fork para mantener las personalizaciones sobre la versión más nueva. El fetch sigue viniendo de `omacom/omarchy:quattro`; el espejo local en el fork es la rama `upstream`.

```bash
# Si el pipeline de las 04:00 AM ya lo detectó y no hubo conflictos,
# el proceso ya fue automático. Verifica:
gh issue list --label cadencia -R robert-flo/omarchy-pkgs

# Si hay conflicto (issue de alerta abierto) o quieres sincronizar manualmente:
cd ~/Work/omarchy/omarchy-installer   # rama personal
git fetch upstream quattro --tags     # remote `upstream` = omacom; rama `quattro` en omacom
git checkout -B upstream upstream/quattro   # Fast-Forward del espejo local
git checkout personal
git rebase upstream                   # rebase sobre el espejo; resolver conflictos si los hay
git push --force-with-lease origin personal

# Publicar con el nuevo pkgver (pkgrel se deriva: pkgver nuevo → 99)
gh workflow run release-personal.yml -R robert-flo/omarchy-pkgs \
  --ref personal -f version=vX.Y.Z
```

Checklist post-sync:
- [ ] Rebase limpio (sin conflictos, o resueltos)
- [ ] Push a `origin personal`
- [ ] Dispatch con `--ref personal` y el `pkgver` del tag nuevo
- [ ] Run verde y validación HTTP 200 en Pages
- [ ] `omarchy update` en la máquina dev confirma versión personal nueva
- [ ] No queda issue `[Cadencia]` abierto

---

## W10 — Agregar una migración para usuarios existentes

**Cuándo:** Tienes un cambio que afecta el `$HOME` de usuarios ya existentes en máquinas ya onboardeadas, y quieres que se aplique automáticamente en el próximo `omarchy update` de cada máquina.

```bash
# 1. Crea el script de migración con timestamp (idempotente obligatorio)
TIMESTAMP=$(date +%Y%m%d%H%M%S)
cat > migrations/${TIMESTAMP}_mi-migracion.sh << 'EOF'
#!/usr/bin/env bash
# Descripción: qué hace esta migración
set -euo pipefail

# Ejemplo: crear directorio de trabajo si no existe
mkdir -p "$HOME/src"

echo "Migration ${TIMESTAMP}_mi-migracion: done"
EOF
chmod +x migrations/${TIMESTAMP}_mi-migracion.sh

# 2. Valida localmente
omarchy dev pkg-test
bash migrations/${TIMESTAMP}_mi-migracion.sh   # prueba la migración

# 3. Publica (W7) — en el próximo omarchy update de cada máquina,
#    omarchy-migrate ejecutará este script automáticamente
gh workflow run release-personal.yml -R robert-flo/omarchy-pkgs \
  --ref personal -f version=v<TAG>
```

> **Regla de idempotencia:** el script debe ser seguro de ejecutar múltiples veces sin efectos secundarios. Usa `mkdir -p`, `cp -n`, `grep -q ... || echo ... >>`, etc.
