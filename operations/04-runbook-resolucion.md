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
   ```bash
   git fetch upstream
   git checkout personal
   git rebase upstream/quattro
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
