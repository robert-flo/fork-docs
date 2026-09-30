---
layout: default
title: Historial de Cambios Consolidado
description: "Registro cronológico consolidado de todas las versiones, commits y cambios del proyecto."
---

# Historial de Cambios Consolidado

Este documento unifica y centraliza el registro histórico de cambios, hitos de infraestructura y evoluciones técnicas del ecosistema del fork personal.

---

## [2026-09-30] — Cadencia Desatendida, Rotación GPG y Portal Canónico

### 1. Desacoplamiento Documental y Portal Web (`fork-docs`)
* **Resolución Integral de Fase 5:** Sustitución de notas dispersas en `scratchpad` por este portal web público e independiente, construido con `jekyll-vitepress-theme` y desplegado en GitHub Pages.
* **Formalización de ADR-009:** Archivo definitivo del repositorio `robert-flo-scratchpad` como solo lectura histórico.

### 2. Automatización Desatendida de las 04:00 AM & Sincronización Upstream
* **Workflows Cruzados:**
  * Configurada deploy key SSH `omarchy-source-sync` en `robert-flo/omarchy` y secreto `SSH_OMARCHY_SOURCE_KEY` en `robert-flo/omarchy-pkgs`.
  * Integrado paso en `release-personal.yml` que ejecuta Fast-Forward de `quattro` directo a `upstream/quattro` y rebase automático de `personal` sobre `quattro`.
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
