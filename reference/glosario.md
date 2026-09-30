---
layout: default
title: Glosario de Términos
description: "Glosario técnico canónico de conceptos, herramientas y convenciones del ecosistema."
---

# Glosario de Términos

Este glosario define el vocabulario técnico canónico empleado en este portal y en el código de los cuatro repositorios del ecosistema.

---

| Término | Definición y Significado en el Ecosistema |
| :--- | :--- |
| **`quattro`** | Rama upstream oficial de Omarchy y rama de sincronización en nuestro fork. Se mantiene siempre como un espejo 1:1 de `omacom/omarchy:quattro` mediante avances estrictos por *Fast-Forward*. |
| **`personal`** | Rama de trabajo activa en `robert-flo/omarchy` y `robert-flo/omarchy-pkgs`. Contiene las personalizaciones y se rebasea sobre la punta de `quattro`. |
| **Sombreado Parcial (*Shading*)** | Técnica que consiste en listar `[omarchy-personal]` antes de `[omarchy]` en `/etc/pacman.conf` para que pacman resuelva prioritariamente nuestros paquetes con nombre idéntico sobre los oficiales. |
| **Par Lockstep** | El binomio fundamental compuesto por `omarchy` (motor y binarios en `/usr/bin/`) y `omarchy-settings` (archivos en `/etc/skel/` y `/usr/share/omarchy/`). Se compilan siempre del mismo commit y con versión sincronizada. |
| **`pkgver`** | Componente de versión base de Arch Linux (`4.0.4`). En nuestro fork coincide exactamente con el tag oficial de Omarchy upstream sobre el cual se basan los cambios. |
| **`pkgrel`** | Número de sub-versión o release de empaquetado (`99`, `100`, `101`). En el par personal parte de la base alta `99` para ganar a la versión oficial (`1`) según las reglas de `vercmp`. |
| **Autoderivación de `pkgrel`** | Lógica en el workflow `release-personal.yml` que consulta dinámicamente el CDN y calcula si el `pkgrel` debe ser `99` (versión nueva) o incrementarse en `+1` (republicación). |
| **Deploy Key SSH** | Claves criptográficas SSH (`SSH_DEPLOY_KEY` y `SSH_OMARCHY_SOURCE_KEY`) configuradas en GitHub Actions para permitir la escritura cruzada entre repositorios con mínimos privilegios. |
| **Escudo de Conflictos (*Conflict Shield*)** | Mecanismo de contención en el CI/CD que detecta colisiones durante el `git rebase quattro`, ejecuta `git rebase --abort` y abre un GitHub Issue de alerta urgente sin publicar paquetes rotos. |
| **`omarchy dev pkg-test`** | Comando de desarrollo local que compila e instala paquetes provisionales `dev.<sha>` para validar cambios en caliente sin tocar el CDN de producción. |
| **`omarchy update`** | Comando único de distribución en máquinas clientes. Ejecuta `pacman -Syu`, dispara `omarchy-migrate` y procesa los hooks post-instalación. |
| **`omarchy-migrate`** | Gestor de migraciones idempotentes de Omarchy. Ejecuta scripts de `/usr/share/omarchy/migrations/` registrando su marca de tiempo en `~/.config/omarchy/migrations.applied`. |
| **Marcador `"personal": true`** | Bandera booleana en `.omarchy/package.json` que indica al compilador de `omarchy-pkgs` que debe procesar y firmar ese paquete en el repositorio personal. |
| **`omarchy.db.tar.zst`** | Archivo tar comprimido con zstandard que actúa como índice oficial de la base de datos de paquetes del repositorio pacman en GitHub Pages. |
