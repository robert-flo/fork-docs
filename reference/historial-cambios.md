---
layout: default
title: Historial de Cambios Consolidado
description: "Registro cronológico consolidado de todas las versiones, commits y cambios del proyecto."
---

# Historial de Cambios Consolidado

Este documento unifica y centraliza el registro histórico de cambios, hitos de infraestructura y evoluciones técnicas del ecosistema del fork personal.

---

## Estado Actual del Sistema

> **Esta tabla es la fuente única de verdad para los valores operacionales del proyecto.**
> Cuando la clave GPG rote, el par se actualice o el CDN cambie, **solo esta sección debe editarse**.
> Todos los demás documentos del portal deben hacer referencia aquí en lugar de hardcodear estos valores.

| Campo | Valor actual |
| :--- | :--- |
| **Par lockstep (pkgver-pkgrel)** | `4.0.4-99` (Omarchy upstream v4.0.4) |
| **Key ID GPG** | `76AFFCC217DB9FC4` |
| **Fingerprint GPG** | `CD92 AB07 B1D2 4DC9 A74E  B60E 76AF FCC2 17DB 9FC4` |
| **Tipo de clave** | RSA 4096-bit |
| **CDN URL** | `https://robert-flo.github.io/omarchy-personal-repo/stable/x86_64` |
| **Clave pública (.asc)** | `https://robert-flo.github.io/omarchy-personal-repo/keys/omarchy-personal-repo.pub.asc` |
| **Empaquetador canónico** | `Roberto Flores <25asab015@ujmd.edu.sv>` |
| **Última rotación de clave** | 2026-09-30 |

**Cómo actualizar esta tabla:**
- **Nuevo pkgver/pkgrel:** editar la fila "Par lockstep" con la versión publicada más reciente.
- **Rotación de clave GPG:** editar las filas Key ID, Fingerprint y fecha. Ver procedimiento completo en [Rotación de Claves GPG & DR](/fork-docs/operations/03-rotacion-claves/).

---

## [2026-10-06] — Paquetes de Arch y del AUR por lista

* **Código:** [robert-flo/omarchy#17](https://github.com/robert-flo/omarchy/pull/17) (issue [#16](https://github.com/robert-flo/omarchy/issues/16)), todavía sin merge. El par lockstep de la tabla de arriba sigue en `4.0.4-99` hasta un `release-personal.yml`.
* **Mecanismo:** un paquete de Arch es una línea en `install/omarchy-base.packages` (ejemplo `meld`). Uno del AUR es una línea en `install/omarchy-aur.packages` (ejemplo `elio-bin`); no va en la lista base. `omarchy-pkg-sync` instala solo lo que falta. En gracie el gatillo es `omarchy dev pkg-test`, no `omarchy update`. En las hijas, tras publicar (W7), `omarchy update` corre `--repos` con sudo todavía autorizado y `--aur` en la fase fría.
* **Qué queda fuera:** `install/omarchy-other.packages` (`omarchy-pkg-sync` no la lee), un launcher web (W1), un PKGBUILD propio ([Añadir un Paquete Personal](/fork-docs/operations/02-anadir-paquete/)), una migración nueva y un hook `post-update`. `migrations/1791260741.sh` queda como precedente. La entrada del 2026-10-05 describe ese camino viejo y no se reescribe.
* **Receta:** [W6](/fork-docs/operations/00-recetas-rapidas/#w6).

---

## [2026-10-05] — Espacios Herdr de la flota

* **Código:** [robert-flo/omarchy#7](https://github.com/robert-flo/omarchy/pull/7) en `personal`. Aún no hay republicación: el par lockstep de esta tabla sigue en `4.0.4-99` hasta un `release-personal.yml`.
* **Mecanismo:** `default/herdr/spaces` más `omarchy-herdr-seed-spaces`. `omarchy refresh herdr` refresca `config.toml` y, con Herdr abierto, siembra los espacios. `elio-bin` entra por la migración `1791260741.sh` (`omarchy-pkg-aur-add`), no por `omarchy-base.packages`.
* **Qué quedó descartado:** publicar `session.json`, y aplicar dotfiles de máquinas existentes con `omarchy-reinstall-configs` / `/etc/skel`.
* **How-to:** [Espacios Herdr de la flota](/fork-docs/operations/05-espacios-herdr/).

---

## [2026-10-05] — Espejo local `upstream` (ADR 0024)

* **Terminología del fork:** En `robert-flo/omarchy` el espejo Fast-Forward deja de llamarse `quattro` y pasa a llamarse `upstream`. **omacom sigue publicando en la rama `quattro`**; el fetch diario no cambió de origen, solo el nombre del espejo en nuestro fork.
* **Default de GitHub:** `personal` permanece como rama larga de personalizaciones y es la rama por defecto del repositorio.
* **Docs:** Glosario, topología, cadencia, ADR-008 y guía de introducción distinguen `omacom/omarchy:quattro` del espejo local `upstream`.
* Refs: [robert-flo/omarchy#4](https://github.com/robert-flo/omarchy/issues/4) / ADR 0024.

---

## [2026-09-30] — Cadencia Desatendida, Rotación GPG y Portal Canónico

### 1. Desacoplamiento Documental y Portal Web (`fork-docs`)
* **Resolución Integral de Fase 5:** Sustitución de notas dispersas en `scratchpad` por este portal web público e independiente, construido con `jekyll-vitepress-theme` y desplegado en GitHub Pages.
* **Formalización de ADR-009:** Archivo definitivo del repositorio `robert-flo-scratchpad` como solo lectura histórico.

### 2. Automatización Desatendida de las 04:00 AM & Sincronización Upstream
* **Workflows Cruzados:**
  * Configurada deploy key SSH `omarchy-source-sync` en `robert-flo/omarchy` y secreto `SSH_OMARCHY_SOURCE_KEY` en `robert-flo/omarchy-pkgs`.
  * Integrado paso en `release-personal.yml` que ejecuta Fast-Forward del espejo local (entonces llamado `quattro` en el fork) hacia `omacom/omarchy:quattro` (ref de seguimiento `upstream/quattro` del *remote* omacom) y rebase automático de `personal` sobre ese espejo. omacom no cambió el nombre de su rama; el espejo local se renombró a `upstream` el 2026-10-05 (ADR 0024).
  * Creado workflow manual [`.github/workflows/sync-upstream.yml`](https://github.com/robert-flo/omarchy/blob/personal/.github/workflows/sync-upstream.yml) en el repositorio de código fuente.
* **Escudo ante Conflictos:** Detección de colisiones durante el rebase, aborto seguro con `git rebase --abort`, detención del pipeline de compilación y apertura de issue de alerta detallada con guía de resolución manual.
* **Ciclo Automático de Issues:** Apertura de issue de seguimiento al detectar nuevo tag en `sync-check.yml` y auto-cierre tras confirmar respuesta HTTP 200 en GitHub Pages.
* **Issues Cerrados:** [robert-flo/omarchy-pkgs#5](https://github.com/robert-flo/omarchy-pkgs/issues/5) y [robert-flo/omarchy#1](https://github.com/robert-flo/omarchy/issues/1).

### 3. Rotación Criptográfica GPG & Disaster Recovery (ADR-006 DR)
* **Clave RSA 4096-bit:** Generada y desplegada clave dedicada `CD92AB07B1D24DC9A74EB60E76AFFCC217DB9FC4` (`76AFFCC217DB9FC4`).
* **Actualización en Cascada:**
  * Secreto `GPG_PRIVATE_KEY` actualizado en `omarchy-pkgs`.
  * Clave pública actualizada en `omarchy-personal-repo` y `omarchy`.
  * Recompilados y firmados todos los paquetes en producción con `pkgrel=99` alineados a Omarchy `v4.0.4`.

---

## [2026-09-29] — Sombreado en Producción y Migración de Scratchpad

* **Configuración de Pacman:** Inyección de la directiva `[omarchy-personal]` en `default/pacman/pacman-stable.conf` de `robert-flo/omarchy` (`acad076a`).
* **Migración de Scratchpad:** Reorganización del repositorio de notas a la raíz del espacio de trabajo y publicación como respaldo persistente en GitHub.

---

## [2026-09-01 al 2026-09-10] — Fundamentos Arquitectónicos del Fork

* **ADR-001:** Creación del repositorio `omarchy-personal-repo` en GitHub Pages y pipeline de compilación en `omarchy-pkgs`.
* **ADR-002:** Restricción al canal único `stable`.
* **ADR-003:** Estrategia de sombreado parcial de paquetes oficiales.
* **ADR-004:** Regla de versionado `pkgrel=99+` y autoderivación automática en CI/CD.
* **ADR-005:** Marcador `"personal": true` en `.omarchy/package.json` y validación con el paquete `hola-mundo`.
* **ADR-007:** Entorno de compilación containerizado en Docker Arch Linux.
