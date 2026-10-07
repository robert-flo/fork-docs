---
layout: default
title: Runbook de Contingencias
description: "Runbook de resolución de incidencias: colisiones de rebase, firmas corruptas y fallos de CI."
---

# Runbook de Contingencias & Resolución de Incidencias

Este documento recoge los procedimientos operativos de emergencia para diagnosticar y solucionar cualquier incidente en el ecosistema del fork.

---

## 1. Incidencia: El Bot Abre un Issue `[Conflicto Rebase]`

### Síntoma:
Recibes una notificación de GitHub o encuentras un issue abierto por el bot de cadencia indicando:  
`[Conflicto Rebase] Sincronización de personal requiere intervención manual`.

### Causa:
Upstream (`omacom/omarchy`) modificó una o más líneas de código en un archivo que también ha sido personalizado en nuestra rama `personal`. El rebase automático abortó limpiamente para no generar paquetes rotos.

### Procedimiento de Resolución:

1. **Abre una terminal en tu directorio local de `omarchy`:**
   ```bash
   cd ~/Work/omarchy/robert-flo_omarchy-personal
   ```

2. **Obtén las ramas más recientes y reproduce el rebase:**
   El *remote* git `upstream` apunta a omacom (su rama sigue llamándose `quattro`). El espejo Fast-Forward en `robert-flo/omarchy` se llama `upstream` (ADR 0024).
   ```bash
   git fetch upstream quattro --tags
   git checkout -B upstream upstream/quattro
   git checkout personal
   git rebase upstream
   ```

3. **Inspecciona los archivos en conflicto:**
   ```bash
   git status
   # Los archivos con conflicto aparecerán bajo "Both modified"
   ```

4. **Resuelve las marcas de conflicto (`<<<<<<<`, `=======`, `>>>>>>>`):**
   Abre los archivos en tu editor preferido. Conserva las personalizaciones de Roberto Flores y adopta las mejoras o cambios de nombres de variables de upstream.

5. **Continúa y sube el rebase:**
   ```bash
   git add <archivos-resueltos>
   git rebase --continue
   git push --force-with-lease origin personal
   ```

6. **Cierra el issue y redispara la publicación:**
   Cierra el GitHub Issue indicando que el rebase fue resuelto y dispara la Action:
   ```bash
   gh workflow run release-personal.yml -R robert-flo/omarchy-pkgs \
     --ref personal -f version=vX.Y.Z
   ```

---

## 2. Incidencia: Pacman Reporta "Firma de origen desconocido" o "Corrupted Package"

### Síntoma:
Al ejecutar `omarchy update` o `sudo pacman -Syu`, pacman se detiene con:
```text
error: omarchy: signature from "Roberto Flores <25asab015@ujmd.edu.sv>" is unknown trust
error: failed to commit transaction (invalid or corrupted package)
```

### Causa:
La máquina cliente no tiene la clave pública importada en su llavero de pacman o la clave fue rotada recientemente.

### Solución:

1. **Reimporta y confía en la clave pública:**
   ```bash
   curl -fsSL https://robert-flo.github.io/omarchy-personal-repo/keys/omarchy-personal-repo.pub.asc -o /tmp/omarchy-personal-repo.pub.asc
   sudo pacman-key --add /tmp/omarchy-personal-repo.pub.asc
   sudo pacman-key --lsign-key 76AFFCC217DB9FC4
   rm -f /tmp/omarchy-personal-repo.pub.asc
   ```

2. **Limpia la base de datos descargada localmente y reintenta:**
   ```bash
   sudo rm -f /var/lib/pacman/sync/omarchy-personal.*
   omarchy update
   ```

---

## 3. Incidencia: Pacman Instala la Versión Oficial sobre la Personal

### Síntoma:
Tras ejecutar `omarchy update`, ejecutas `pacman -Q omarchy` y muestra una versión oficial (ej. `4.0.4-1`) en lugar de la versión sombreada (`4.0.4-99`). Tus configuraciones personalizadas desaparecen.

### Diagnóstico y Solución:

1. **Verifica el orden en `/etc/pacman.conf`:**
   Abre `/etc/pacman.conf` y asegúrate de que la sección `[omarchy-personal]` esté **antes** que `[omarchy]` y `[core]`. Si está después, pacman instalará el paquete del primer repositorio que coincida.

2. **Verifica la versión servida en el CDN:**
   ```bash
   curl -s https://robert-flo.github.io/omarchy-personal-repo/stable/x86_64/omarchy.db.tar.zst | bsdtar -xOf - omarchy/desc | grep -A1 "%VERSION%"
   ```
   Si la versión en el CDN no tiene sufijo `-99` o superior, redispara `release-personal.yml` con el parámetro `version=vX.Y.Z`.

---

## 4. Incidencia: El Runner de GitHub Actions Falla al Compilar

### Síntoma:
El workflow `release-personal.yml` falla con cruz roja en el paso `Compila paquetes en Docker`.

### Diagnóstico y Solución:

1. **Inspecciona los logs con la CLI:**
   ```bash
   gh run list -R robert-flo/omarchy-pkgs
   gh run view <run-id> -R robert-flo/omarchy-pkgs --log-failed
   ```

2. **Causa común: Dependencias de Arch Linux desactualizadas:**  
   Arch Linux es *rolling-release*. Ocasionalmente una librería base se renombra. Actualiza la imagen Docker ejecutando el workflow de mantenimiento:
   ```bash
   gh workflow run builder-images.yml -R robert-flo/omarchy-pkgs
   ```

---

## 5. Incidencia: Fallo Transitorio de Red (TLS / Rate Limit de GitHub)

### Síntoma:
El workflow `release-personal.yml` falla con error de conexión durante la descarga de paquetes de Arch Linux (`archlinux.org` TLS error) o debido a un rate limit de la API de GitHub.

### Causa:
Fallo de red transitorio en el runner de GitHub Actions. No es un error del código ni del repositorio.

### Solución:
Re-disparar el workflow tal cual. El proceso es **idempotente**: si el pin ya fue commiteado a la rama `personal` antes del fallo, el re-dispatch lo detecta y continúa desde ese estado:

```bash
gh workflow run release-personal.yml -R robert-flo/omarchy-pkgs \
  --ref personal -f version=vX.Y.Z
```

> **Nota:** Si el fallo ocurrió **después** de publicar en Pages (por ejemplo, el paso de validación HTTP), consulta la Incidencia 3 (firma corrupta o push fallido).

---

## 6. Incidencia: Rotación o Pérdida de Clave GPG / Deploy Key

### Síntoma:
La clave privada GPG o la deploy key SSH podrían haberse comprometido, perdido o requieren rotación periódica por política de seguridad.

### Solución:
Ver el procedimiento completo en **[Rotación de Claves GPG & DR](/fork-docs/operations/03-rotacion-claves/)**.

**Resumen de urgencia:**

| Clave perdida | Acción inmediata |
| :--- | :--- |
| `GPG_PRIVATE_KEY` | Genera nuevo par RSA 4096-bit → actualiza secret en `omarchy-pkgs` → publica nueva `.asc` pública → en cada máquina: `pacman-key --add` + `--lsign-key` de la nueva clave **antes** de cualquier `omarchy update`. |
| `SSH_DEPLOY_KEY` | Regenerar en `omarchy-personal-repo` (Settings → Deploy keys) → actualizar secret en `omarchy-pkgs`. |
| `SSH_OMARCHY_SOURCE_KEY` | Regenerar en `robert-flo/omarchy` (Settings → Deploy keys) → actualizar secret en `omarchy-pkgs`. |

> **Atención:** La clave privada GPG **solo existe como secret de GitHub Actions**. Nunca se versiona en ningún repositorio. Cualquier sospecha de filtración = rotación inmediata.

---

## 7. Incidencia: Rescate Manual de una Máquina

### Síntoma:
Una máquina quedó instalada con la versión oficial del par (perdió las personalizaciones) y no puedes esperar al próximo `omarchy update`.

### Causa:
El par oficial (`pkgrel=1`) reemplazó al par personal (`pkgrel=99+`) porque el repositorio personal estaba caído o la sección `[omarchy-personal]` no estaba antes de `[omarchy]` en `pacman.conf`.

### Procedimiento de recuperación:

```bash
# 1. Descarga el par actual directamente desde el CDN
REPO="https://robert-flo.github.io/omarchy-personal-repo/stable/x86_64"
VER="<versión-actual>"   # consulta reference/historial-cambios para el valor actual

curl -O "$REPO/omarchy-${VER}-any.pkg.tar.zst"
curl -O "$REPO/omarchy-${VER}-any.pkg.tar.zst.sig"
curl -O "$REPO/omarchy-settings-${VER}-any.pkg.tar.zst"
curl -O "$REPO/omarchy-settings-${VER}-any.pkg.tar.zst.sig"

# 2. Instala ambos al mismo tiempo (lockstep obligatorio)
sudo pacman -U omarchy-${VER}-any.pkg.tar.zst \
               omarchy-settings-${VER}-any.pkg.tar.zst

# 3. Reescribe pacman.conf con el orden correcto de repositorios
sudo omarchy refresh pacman

# 4. Actualiza normalmente
omarchy update -y
```

Después, la máquina regresa a la cadencia normal con `omarchy update`.

---

## 8. Incidencia: `omarchy update` Pide Contraseña y Falla

### Síntoma:
En sesiones sin terminal real (scripts de cron, SSH sin pseudo-terminal), `omarchy update` falla porque `sudo -v` pide contraseña interactivamente y no puede recibirla.

### Causa:
Quirk de `sudo -v` en el cliente `omarchy` cuando no hay TTY disponible. No es un fallo del repositorio ni del par de paquetes.

### Solución:

```bash
# Opción A (recomendada): ejecutar desde una sesión de terminal real
omarchy update

# Opción B: pre-autenticar sudo antes del comando
sudo -v && omarchy update

# Opción C: drop-in temporal en sudoers solo para automatización puntual
echo "Defaults:$USER !authenticate" | sudo tee /etc/sudoers.d/omarchy-temp
omarchy update
sudo rm /etc/sudoers.d/omarchy-temp
```

---

## 9. Incidencia: Actualización del Sistema Sobrescribe Cambios Locales en Máquina DEV

### Síntoma:
Tras ejecutar `pacman -Syu`, `omarchy update` o una actualización con un helper AUR (como `yay`) en la estación de desarrollo (`gracie`), las personalizaciones en `/usr/share/omarchy/` (como configuraciones y atajos de Hyprland, scripts o temas) desaparecen repentinamente y el sistema revierte a los valores por defecto de upstream.

### Causa:
La máquina de desarrollo tenía instalados paquetes generados localmente con `omarchy dev pkg-test`, etiquetados con el prefijo `dev.<sha>-1`.  
El repositorio oficial upstream `[omarchy]` (`pkgs.omarchy.org/edge`) ofrece `omarchy-settings-dev` y `omarchy-dev` con numeración estándar (ej. `4.0.0.r6720.g8e02fc8-1`).  
La comparación de versiones de ALPM (`vercmp dev.<sha>-1 4.0.0.r...`) evalúa cualquier versión numérica por encima de `dev.`, por lo que pacman interpreta que upstream tiene una versión más reciente, descarga el paquete oficial y sobrescribe `/usr/share/omarchy/`.

### Procedimiento de Resolución y Blindaje:

1. **Reempaquetado e instalación limpia (sin tocar `/usr/share/omarchy/` a mano):**  
   Compila e instala ambos paquetes en lockstep desde el checkout de desarrollo activo:
   ```bash
   cd ~/Work/tries/pj-omarchy/fo-omarchy
   omarchy dev pkg-test
   ```
   *(O de forma individual: `omarchy dev pkg-test omarchy-settings-dev ~/Work/tries/pj-omarchy/fo-omarchy` y `omarchy dev pkg-test omarchy-dev ~/Work/tries/pj-omarchy/fo-omarchy`).*

2. **Blindaje permanente de la máquina en `pacman.conf`:**  
   Inyecta la directiva `IgnorePkg` bajo la sección `[options]` de `/etc/pacman.conf`:
   ```bash
   sudo sed -i '/^HoldPkg =/a IgnorePkg = omarchy-dev omarchy-settings-dev' /etc/pacman.conf
   ```

3. **Verificación:**  
   Comprueba que los paquetes queden marcados como ignorados:
   ```bash
   pacman -Qu
   # Salida esperada:
   # omarchy-dev dev.<sha>-1 -> 4.0.0... [ignored]
   # omarchy-settings-dev dev.<sha>-1 -> 4.0.0... [ignored]
   ```
   Y verifica que las opciones y atajos de tu escritorio vuelvan a responder normalmente (por ejemplo: `hyprctl getoption general:layout` y `hyprctl configerrors`).
