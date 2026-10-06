---
layout: default
title: Comandos y Archivos Clave del Motor Omarchy
description: "Referencia técnica canónica de los 9 comandos y archivos estructurales esenciales del motor Omarchy."
---

# Comandos y Archivos Clave del Motor Omarchy

> **Referencia Canónica del Motor:**  
> Esta tabla maestra reúne los 9 comandos, ejecutables y documentos arquitectónicos centrales de Omarchy. Sirve como referencia técnica permanente para desarrolladores de la flota y agentes de inteligencia artificial antes de introducir cambios, crear migraciones o alterar configuraciones.

---

## 1. Tabla Maestra de Componentes Estructurales

| Componente | Tipo | Ruta Original en el Árbol (`fo-omarchy`) | Ubicación y Comportamiento en el Sistema Instalado | Propósito Fundamental |
| :--- | :--- | :--- | :--- | :--- |
| **`omarchy dev pkg-test`** | Binario / CLI | `bin/omarchy-dev-pkg-test` | `/usr/bin/omarchy-dev-pkg-test` | Compila e instala paquetes locales provisionales `dev.<sha>` en `/tmp` para validación pre-flight de rutas fijas (`/etc/`, systemd, udev, `/etc/skel/`). |
| **`omarchy dev link`** | Binario / CLI | `bin/omarchy-dev-link` | `/usr/bin/omarchy-dev-link` | Modo Live: enlaza el sistema operativo en tiempo real a un checkout local, escribiendo `/etc/omarchy.conf` y `/etc/sudoers.d/omarchy-dev-path`. |
| **`omarchy-migrate`** | Binario / Motor | `bin/omarchy-migrate` | `/usr/bin/omarchy-migrate` | Runner de migraciones: procesa scripts pendientes en `/usr/share/omarchy/migrations/` y guarda el estado por usuario en `~/.local/state/omarchy/migrations/`. |
| **`omarchy refresh config`** | Binario / CLI | `bin/omarchy-refresh-config` | `/usr/bin/omarchy-refresh-config` | Reconcilia un archivo de configuración específico desde las plantillas de Omarchy hacia `~/.config/<ruta>` del usuario activo. |
| **`omarchy reinstall configs`** | Binario / CLI | `bin/omarchy-reinstall-configs` | `/usr/bin/omarchy-reinstall-configs` | Restablece **destructivamente** todas las configuraciones empaquetadas en `$HOME/.config/` al estado original de `/etc/skel/` (creando respaldos `.bak`). |
| **`omarchy dev add-migration`** | Binario / CLI | `bin/omarchy-dev-add-migration` | `/usr/bin/omarchy-dev-add-migration` | Genera un nuevo archivo de migración ordenado por timestamp Unix (`migrations/<timestamp>.sh`) con permisos `0644`. |
| **`omarchy-update-dev`** | Binario / Motor | `bin/omarchy-update-dev` | `/usr/bin/omarchy-update-dev` | Manejador interno ejecutado por `omarchy update` para advertir y gestionar el estado cuando se opera sobre un canal `-dev` o un checkout linkeado. |
| **`file-layout.md`** | Documento / Spec | `docs/file-layout.md` | Documentación técnica en el repositorio del fork | Mapa topológico canónico de todo el árbol de archivos de Omarchy (`bin/`, `default/`, `etc/`, `install/`, `migrations/`, etc.). |
| **`migrations.md`** | Documento / Spec | `agents/skills/migrations.md` | Manual de ingeniería para agentes y desarrolladores | Estándar de oro para la autoría, semántica, pruebas y restricciones de migraciones idempotentes de un solo uso. |

---

## 2. Detalle Técnico de los Componentes

### 1. `bin/omarchy-dev-pkg-test`
* **Árbol de fuentes:** `bin/omarchy-dev-pkg-test`
* **Instalación:** `/usr/bin/omarchy-dev-pkg-test` (paquete `omarchy`).
* **Comportamiento técnico:**
  * Crea un espacio temporal en `/tmp/omarchy-dev-pkg-test.XXXXXX`.
  * Genera paquetes locales para `omarchy-dev` y `omarchy-settings-dev` reemplazando dinámicamente la función `pkgver()` por `dev.<short-sha>[.dirty]`.
  * Ejecuta `makepkg` e instala los `.pkg.tar.zst` resultantes mediante `pacman -U` localmente.
  * No altera ningún repositorio remoto ni requiere sincronizaciones de red.
* **Cuándo usar:** Obligatorio para probar drop-ins en `/etc/`, servicios systemd en `/usr/lib/systemd/`, reglas udev o semillas en `/etc/skel/`.
* **Ejemplos:**
  ```bash
  omarchy dev pkg-test
  omarchy dev pkg-test omarchy-settings-dev
  omarchy dev pkg-test omarchy-dev ~/Work/tries/pj-omarchy/fo-omarchy
  ```

---

### 2. `bin/omarchy-dev-link`
* **Árbol de fuentes:** `bin/omarchy-dev-link`
* **Instalación:** `/usr/bin/omarchy-dev-link` (paquete `omarchy`).
* **Comportamiento técnico:**
  * Requiere ejecutarse como usuario normal (falla explícitamente si se invoca con `sudo`).
  * Escribe `/etc/omarchy.conf` exportando `OMARCHY_PATH="<path-to-checkout>"`.
  * Genera `/etc/sudoers.d/omarchy-dev-path` con `Defaults secure_path="<target>/bin:..."`, verificado estrictamente con `visudo -cf`.
  * Permite que tanto llamadas regulares como `sudo omarchy-*` ejecuten los scripts del checkout en caliente.
* **Cuándo usar:** Iteración rápida (Modo Live) sobre scripts en `bin/`, configuraciones en `default/`, temas y Quickshell.
* **Ejemplos:**
  ```bash
  omarchy dev link ~/Work/tries/pj-omarchy/fo-omarchy
  omarchy dev status
  omarchy dev unlink
  ```

---

### 3. `bin/omarchy-migrate`
* **Árbol de fuentes:** `bin/omarchy-migrate`
* **Instalación:** `/usr/bin/omarchy-migrate` (paquete `omarchy`).
* **Comportamiento técnico:**
  * Espera de forma segura a que cualquier transacción pacman en curso termine.
  * Lee el directorio `/usr/share/omarchy/migrations/` (o `$OMARCHY_PATH/migrations/`).
  * Ejecuta de forma estrictamente secuencial cualquier script `.sh` que carezca del marcador de estado en `~/.local/state/omarchy/migrations/<archivo>.sh`.
  * Si un script falla (código != 0), la cola se detiene de inmediato para no corromper estados posteriores dependientes.
* **Cuándo usar:** Se invoca automáticamente durante `omarchy update` y en login interactivo a través de `omarchy-migrate-notify.service`.
* **Ejemplos:**
  ```bash
  omarchy-migrate
  omarchy-migrate --pending
  ```

---

### 4. `bin/omarchy-refresh-config`
* **Árbol de fuentes:** `bin/omarchy-refresh-config`
* **Instalación:** `/usr/bin/omarchy-refresh-config` (paquete `omarchy`).
* **Comportamiento técnico:**
  * Acepta una ruta relativa como argumento (ej. `hypr/hyprland.conf`, `kitty/kitty.conf`).
  * Inspecciona la plantilla en `$OMARCHY_PATH/config/<ruta>` o `$OMARCHY_PATH/default/<ruta>`.
  * Reconcilia la configuración en `~/.config/<ruta>`. Dependiendo de la app, puede respaldar la versión anterior en `.bak` o actualizar directivas clave.
* **Cuándo usar:** Tras modificar una plantilla de configuración en desarrollo para propagarla al usuario local sin reinstalar todo el home.
* **Ejemplos:**
  ```bash
  omarchy refresh config hypr/hyprland.conf
  omarchy refresh config foot/foot.ini
  ```

---

### 5. `bin/omarchy-reinstall-configs`
* **Árbol de fuentes:** `bin/omarchy-reinstall-configs`
* **Instalación:** `/usr/bin/omarchy-reinstall-configs` (paquete `omarchy`).
* **Comportamiento técnico:**
  * **Comando destructivo de recuperación / fábrica**: barre de manera global todas las configuraciones sembradas en `/etc/skel/.config/` y las replica sobre `~/.config/`.
  * Genera copias de respaldo de archivos preexistentes, pero aplasta personalizaciones arbitrarias.
* **Regla de oro:** **NUNCA** debe ejecutarse automáticamente en scripts de actualización, flotas o migraciones. Solo para restauración manual explícita por el usuario.
* **Ejemplos:**
  ```bash
  omarchy reinstall configs
  ```

---

### 6. `bin/omarchy-dev-add-migration`
* **Árbol de fuentes:** `bin/omarchy-dev-add-migration`
* **Instalación:** `/usr/bin/omarchy-dev-add-migration` (paquete `omarchy`).
* **Comportamiento técnico:**
  * Obtiene el timestamp Unix actual (`date +%s`).
  * Crea un archivo `migrations/<timestamp>.sh` con permisos `0644`.
  * Inserta la estructura base requerida (sin shebang, listo para ejecutarse con `bash -euo pipefail`).
* **Cuándo usar:** Al preparar una reparación o cambio de estado de un solo uso para usuarios existentes.
* **Ejemplos:**
  ```bash
  omarchy dev add-migration --no-edit
  ```

---

### 7. `bin/omarchy-update-dev`
* **Árbol de fuentes:** `bin/omarchy-update-dev`
* **Instalación:** `/usr/bin/omarchy-update-dev` (paquete `omarchy`).
* **Comportamiento técnico:**
  * Detecta si el sistema cliente tiene paquetes con etiqueta `dev.*` o si `/etc/omarchy.conf` apunta a un checkout git activo.
  * Coordina advertencias antes de actualizar paquetes del sistema para evitar que `pacman -Syu` inadvertidamente pise código fuente activo sin conocimiento del desarrollador.
* **Cuándo usar:** Invocado internamente por el pipeline de `omarchy update`.

---

### 8. `docs/file-layout.md`
* **Árbol de fuentes:** `docs/file-layout.md`
* **Naturaleza:** Especificación de arquitectura y topología de archivos en el repositorio del fork.
* **Contenido esencial:**
  * Explica qué vive en cada carpeta del repositorio (`bin/`, `default/`, `config/`, `etc/`, `install/`, `migrations/`, `shell/`, `themes/`).
  * Documenta la resolución de variables (`$OMARCHY_PATH`, bootstrap en `default/bash/env-bootstrap`).
  * Detalla las integraciones del runtime con systemd, udev y el protocolo de inicio bajo uwsm.
* **Consulta obligatoria:** Antes de crear cualquier nuevo subdirectorio o archivo en `fo-omarchy`.

---

### 9. `agents/skills/migrations.md`
* **Árbol de fuentes:** `agents/skills/migrations.md`
* **Naturaleza:** Skill canónica y estándar de ingeniería de migraciones.
* **Reglas mandatorias documentadas:**
  1. Permisos estrictos `0644` (ejecutados por el runner vía `bash -euo pipefail`).
  2. Prohibido incluir shebang (`#!/bin/bash`).
  3. Comenzar siempre con un `echo` explicativo de la acción.
  4. Idempotencia absoluta: validar estado antes de aplicar cambios.
  5. Registro persistente por usuario en `~/.local/state/omarchy/migrations/`.
  6. **Prohibido reiniciar el shell** dentro de una migración (`omarchy update` ya gestiona el reinicio controlado).
* **Prueba estándar recomendada:**
  ```bash
  HOME=$(mktemp -d) bash -euo pipefail migrations/<timestamp>.sh
  ```
