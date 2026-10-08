---
layout: default
title: Índice de ADRs
description: "Índice navegable de los 10 Architecture Decision Records (ADRs) del fork personal."
---

# Architecture Decision Records (ADRs)

Los **Architecture Decision Records (ADRs)** capturan las decisiones técnicas y de diseño fundamentales que gobiernan la arquitectura del fork personal, documentando el contexto histórico, la justificación, las alternativas descartadas y las consecuencias de cada elección.

Ningún cambio futuro debe contradecir un ADR vigente sin pasar previamente por una revisión formal y la redacción de un nuevo ADR derogatorio o sustitutivo.

---

## Tabla Resumen de Decisiones

| ID | Título | Estado | Fecha de Fijación | Impacto Principal |
| :--- | :--- | :--- | :--- | :--- |
| **[ADR-001](/fork-docs/adrs/ADR-001/)** | Hosting de Pacman en GitHub Pages | Aceptada | 2026-09-01 | Servidor estático HTTPS sin servidores ni costes de VPS. |
| **[ADR-002](/fork-docs/adrs/ADR-002/)** | Canal Único `stable` | Aceptada | 2026-09-01 | Simplificación operativa: no replicar edge/rc de upstream. |
| **[ADR-003](/fork-docs/adrs/ADR-003/)** | Sombreado Parcial de Paquetes | Aceptada | 2026-09-01 | `[omarchy-personal]` antes de `[omarchy]` en pacman.conf. |
| **[ADR-004](/fork-docs/adrs/ADR-004/)** | Regla del `pkgrel` Alto (99+) | Aceptada | 2026-09-01 | Prioridad estricta en pacman y autoderivación en CI/CD. |
| **[ADR-005](/fork-docs/adrs/ADR-005/)** | Marcador `"personal": true` | Aceptada | 2026-09-01 | Inclusión dinámica de paquetes propios en el empaquetado. |
| **[ADR-006](/fork-docs/adrs/ADR-006/)** | Claves GPG y Disaster Recovery | Aceptada | 2026-09-30 | Clave privada solo en CI; clave RSA 4096-bit canónica. |
| **[ADR-007](/fork-docs/adrs/ADR-007/)** | Compilación Containerizada | Aceptada | 2026-09-01 | Uso de `archlinux:base-devel` efímero en Docker. |
| **[ADR-008](/fork-docs/adrs/ADR-008/)** | Cadencia Desatendida 04:00 AM | Aceptada | 2026-09-30 | Sincronización 1:1, rebase automático y escudo de colisiones. |
| **[ADR-009](/fork-docs/adrs/ADR-009/)** | Desacoplamiento de la Documentación | Aceptada | 2026-09-30 | Portal web independiente Jekyll-VitePress ("Estándar de Oro"). |
| **[ADR-010](/fork-docs/adrs/ADR-010/)** | Espacios de Desarrollo y Navegación | Aceptada | 2026-10-07 | Aislamiento modular de workspaces (8, 9, 10) y exclusiones flotantes. |

