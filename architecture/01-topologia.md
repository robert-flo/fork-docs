---
layout: default
title: Topología del Ecosistema
description: "Estructura de 4 pilares: repositorio fuente, fábrica CI/CD en Docker, CDN de binarios y portal documental."
---

# Topología del Ecosistema

Para lograr una distribución modular, mantenible y desacoplada de upstream, el proyecto se divide estrictamente en **cuatro repositorios independientes**, cada uno con una responsabilidad delimitada y protocolos de comunicación seguros.

---

## 1. Mapa de Repositorios

```mermaid
graph TD
    subgraph Upstream ["Upstream Oficial"]
        UP[omacom/omarchy]
    end

    subgraph Core ["1. Código Fuente: robert-flo/omarchy"]
        Q[rama quattro: espejo 1:1]
        P[rama personal: customizaciones]
    end

    subgraph Factory ["2. Fábrica de Compilación: robert-flo/omarchy-pkgs"]
        W1[sync-check.yml: cron 04:00 AM]
        W2[release-personal.yml: Docker + GPG]
    end

    subgraph CDN ["3. Repositorio Pacman: robert-flo/omarchy-personal-repo"]
        DB[(omarchy.db.tar.zst)]
        PKG[(omarchy-*.pkg.tar.zst)]
    end

    subgraph Docs ["4. Estándar de Oro: robert-flo/fork-docs"]
        DOCS[Portal Web en GitHub Pages]
    end

    UP -->|git fetch diario| Q
    Q -->|git rebase automático| P
    W1 -->|detecta nuevo tag| W2
    W2 -->|SSH Deploy Key| P
    W2 -->|Docker Build & GPG Sign| CDN
    CDN -->|HTTPS / pacman -Syu| User[Máquinas del Usuario]
    Docs -.->|Guía y reglas autoritativas| Core
    Docs -.->|Guía y reglas autoritativas| Factory
```

---

## 2. Los Cuatro Pilares

### Pilar 1: Repositorio de Código Fuente (`robert-flo/omarchy`)
* **Propósito:** Contener el árbol de código fuente del sistema (scripts en `bin/`, configuraciones en `config/`, aplicaciones en `applications/`, recetas en `install/` y migraciones en `migrations/`).
* **Ramas Canónicas:**
  * **`quattro`:** Espejo 1:1 de la rama `omacom/omarchy:quattro`. Se actualiza exclusivamente por *Fast-Forward* para garantizar que nunca diverja ni genere commits sintéticos.
  * **`personal`:** Rama activa donde residen las personalizaciones. Vive siempre rebaseada sobre la punta de `quattro`.
* **Seguridad:** Autoriza la clave SSH Deploy Key `omarchy-source-sync` con permisos de escritura para permitir que la fábrica de empaquetado actualice las ramas de forma desatendida.

### Pilar 2: Fábrica de Compilación (`robert-flo/omarchy-pkgs`)
* **Propósito:** Orquestar la integración continua, detección de versiones y construcción containerizada de paquetes de Arch Linux.
* **Componentes:**
  * **Recetas PKGBUILD:** Fichas de empaquetado del par `omarchy` y `omarchy-settings`, además de paquetes personales adicionales como `hola-mundo`.
  * **Contenedores Docker:** Entornos efímeros y puros de Arch Linux donde se ejecutan `makepkg` y `repo-add` sin contaminar el host.
  * **Workflows de GitHub Actions:**
    * `sync-check.yml`: Cron a las 04:00 AM que compara tags upstream.
    * `release-personal.yml`: Pipeline que sincroniza ramas, compila con Docker, firma con GPG y publica en el CDN.
* **Secretos:** Custodia `GPG_PRIVATE_KEY` (clave privada para firmar) y `SSH_OMARCHY_SOURCE_KEY` (deploy key para hacer push al repositorio fuente).

### Pilar 3: CDN de Distribución Pacman (`robert-flo/omarchy-personal-repo`)
* **Propósito:** Servidor de paquetes binarios consumible directamente por `pacman`.
* **Alojamiento:** Servido estáticamente mediante GitHub Pages en la rama `gh-pages`.
* **Estructura de Directorios:**
  ```text
  stable/
  └── x86_64/
      ├── omarchy.db.tar.zst        # Base de datos del repositorio
      ├── omarchy.db.tar.zst.sig    # Firma GPG de la base de datos
      ├── omarchy.files.tar.zst     # Índice de archivos
      ├── omarchy-4.0.4-99-any.pkg.tar.zst
      ├── omarchy-4.0.4-99-any.pkg.tar.zst.sig
      ├── omarchy-settings-4.0.4-99-any.pkg.tar.zst
      └── omarchy-settings-4.0.4-99-any.pkg.tar.zst.sig
  keys/
  └── omarchy-personal-repo.pub.asc  # Clave pública para clientes
  ```

### Pilar 4: Portal de Documentación Canónica (`robert-flo/fork-docs`)
* **Propósito:** Este sitio web. Es la **única fuente de la verdad** y el estándar arquitectónico.
* **Rol:** Describe formalmente cómo opera el sistema, almacena los ADRs, define la Matriz de Decisión y guía tanto a agentes de IA como a desarrolladores humanos.
