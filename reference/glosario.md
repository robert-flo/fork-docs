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
| **`quattro`** | Rama de línea de desarrollo en **omacom/omarchy**. Sigue siendo la rama real que rastreamos: el fetch diario parte de `omacom/omarchy:quattro`. No es el nombre del espejo en nuestro fork. |
| **`upstream` (rama del fork)** | Espejo Fast-Forward 1:1 de `omacom/omarchy:quattro` en `robert-flo/omarchy` (ADR 0024). Solo avanza por *Fast-Forward*; nunca recibe commits propios. Antes se llamaba `quattro` **en el fork**; omacom no renombró su rama. Distinto del *remote* git homónimo que apunta a omacom. |
| **`personal`** | En `robert-flo/omarchy`: rama de trabajo activa y **rama por defecto de GitHub**; contiene las personalizaciones y se rebasea sobre la punta del espejo local `upstream`. En `robert-flo/omarchy-pkgs`: rama **curada** de pin/release (pin del par lockstep + recetas `"personal": true`); **no** es la rama por defecto (esa es `master`). Excepción documentada al [ADR 0024](https://github.com/robert-flo/fleet/blob/main/docs/adr/0024-personal-y-upstream-en-cada-fork.md) de fleet ([omarchy-pkgs#8](https://github.com/robert-flo/omarchy-pkgs/issues/8)). |
| **Sombreado Parcial (*Shading*)** | Técnica que consiste en listar `[omarchy-personal]` antes de `[omarchy]` en `/etc/pacman.conf` para que pacman resuelva prioritariamente nuestros paquetes con nombre idéntico sobre los oficiales. |
| **Par Lockstep** | El binomio fundamental compuesto por `omarchy` (motor y binarios en `/usr/bin/`) y `omarchy-settings` (archivos en `/etc/skel/` y `/usr/share/omarchy/`). Se compilan siempre del mismo commit y con versión sincronizada. |
| **`pkgver`** | Componente de versión base de Arch Linux (`4.0.4`). En nuestro fork coincide exactamente con el tag oficial de Omarchy upstream sobre el cual se basan los cambios. |
| **`pkgrel`** | Número de sub-versión o release de empaquetado (`99`, `100`, `101`). En el par personal parte de la base alta `99` para ganar a la versión oficial (`1`) según las reglas de `vercmp`. |
| **Autoderivación de `pkgrel`** | Lógica en el workflow `release-personal.yml` que consulta dinámicamente el CDN y calcula si el `pkgrel` debe ser `99` (versión nueva) o incrementarse en `+1` (republicación). |
| **Deploy Key SSH** | Claves criptográficas SSH (`SSH_DEPLOY_KEY` y `SSH_OMARCHY_SOURCE_KEY`) configuradas en GitHub Actions para permitir la escritura cruzada entre repositorios con mínimos privilegios. |
| **Escudo de Conflictos (*Conflict Shield*)** | Mecanismo de contención en el CI/CD que detecta colisiones durante el `git rebase upstream` (espejo local sobre `personal`), ejecuta `git rebase --abort` y abre un GitHub Issue de alerta urgente sin publicar paquetes rotos. |
| **`omarchy dev pkg-test`** | Comando de desarrollo local que compila e instala paquetes provisionales `dev.<sha>` para validar cambios en caliente sin tocar el CDN de producción. |
| **`omarchy update`** | Comando único de distribución en máquinas clientes. Ejecuta `pacman -Syu`, dispara `omarchy-migrate` y procesa los hooks post-instalación. |
| **`omarchy-migrate`** | Gestor de migraciones de Omarchy. Ejecuta cada script de `/usr/share/omarchy/migrations/` una sola vez por usuario y deja la marca en `~/.local/state/omarchy/migrations/`. Con la marca puesta no lo vuelve a correr; el siguiente cambio a un `$HOME` existente va en una migración nueva. |
| **Marcador `"personal": true`** | Bandera booleana en `.omarchy/package.json` que indica al compilador de `omarchy-pkgs` que debe procesar y firmar ese paquete en el repositorio personal. |
| **`omarchy.db.tar.zst`** | Archivo tar comprimido con zstandard que actúa como índice oficial de la base de datos de paquetes del repositorio pacman en GitHub Pages. |
| **`pin / pin engine`** | Motor del workflow `release-personal.yml` que reescribe los campos `_tag`, `_commit`, `pkgver` y `sha256sums` de los PKGBUILD del par antes de compilar, fijándolos al commit base de la rama `personal`. Garantiza que los binarios publicados son reproducibles y rastreables. |
| **`pinned`** | Marca booleana (`"pinned": true`) en `.omarchy/package.json` de un PKGBUILD. Significa que el paquete es gestionado por el pin engine y no buildea contra `stable` directamente. El par lockstep usa esta marca; el workflow la desactiva temporalmente durante la compilación personal. |
| **`guard §5.3`** | Paso de validación en el workflow que aborta la publicación si el `pkgrel` resultante del par personal quedaría igual o por debajo del par oficial en el repositorio `[omarchy]`. Protege el sombreado. |
| **`guard fail-fast`** | Paso de validación en el workflow que aborta **inmediatamente** si el dispatch no se lanzó desde la rama `personal`. Protege contra publicaciones accidentales desde ramas incorrectas (`master`, `main`, feature branches). |
| **`omarchy provision user --force`** | Comando que materializa todos los archivos del par en el `$HOME` del usuario actual: launchers `.desktop`, stubs en `~/.local/bin/`, configuraciones en `~/.config/`. Obligatorio en el primer onboarding de una máquina (paso 6 de la guía). `omarchy update` no lo ejecuta automáticamente en `$HOME` existentes (ADR-009). |
| **`dry_run`** | Modo de ensayo del workflow `release-personal.yml` activado con `-f dry_run=true`. Ejecuta el ciclo completo (pin, build, sign, validate) sin hacer commit del pin a `personal` ni push a `gh-pages`. Ideal para validar antes de publicaciones delicadas o tras un fallo de F3. |
| **`clean / clean-repo`** | Paso del pipeline que poda el CDN en `gh-pages` dejando solo la versión más reciente de cada paquete. Consecuencia directa: **no existe rollback de repo** — si se publica algo incorrecto, se repara publicando una versión superior (roll-forward). |
| **`temporary un-pin`** | Truco usado por el workflow durante la compilación personal: establece temporalmente `"pinned": false` en el `package.json` del par (sin commitear) para que el compilador buildee contra `stable` en lugar del pin engine. Al terminar el build, el estado se descarta y el pin queda intacto en la rama `personal`. |
| **`bootstrap`** | Proceso de dejar una máquina nueva lista como cliente del repositorio personal. El proceso completo tiene 7 pasos (ver guía de onboarding). Se puede ejecutar de forma desatendida con el script `bootstrap-omarchy-machine.sh`. |
| **`cadencia / sync`** | Rutina periódica (automatizada a las 04:00 AM vía `sync-check.yml`) para mantener el fork alineado con el tag más reciente publicado sobre `omacom/omarchy:quattro`. Fast-Forward del espejo local `upstream`, rebase de `personal`, un nuevo par con el `pkgver` del tag nuevo y su distribución vía CDN. |
| **`vercmp`** | Comparador de versiones de pacman. Determina qué paquete gana cuando dos repos ofrecen el mismo nombre: a igual `pkgver`, gana el `pkgrel` más alto. Esta regla es la base del sombreado parcial (el par personal siempre tiene `pkgrel=99+` vs `pkgrel=1` del oficial). |
