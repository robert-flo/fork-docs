# Fork Docs — Arquitectura & Estándar de Oro

Portal web de documentación canónica para el ecosistema del fork personal sobre Arch Linux y Hyprland.

* **URL Pública en Vivo:** [https://robert-flo.github.io/fork-docs/](https://robert-flo.github.io/fork-docs/)
* **Motor:** Jekyll con [`jekyll-vitepress-theme`](https://jekyll-vitepress.dev/)
* **Despliegue:** GitHub Pages automatizado mediante GitHub Actions

---

## 🧭 Misión y Filosofía

Este portal es el **Estándar de Oro y la Fuente Única de la Verdad** del proyecto. Reemplaza y unifica las notas dispersas de `scratchpad` y las decisiones técnicas de los distintos repositorios en una suite documental estructurada, navegable y pedagógica tanto para humanos como para agentes de inteligencia artificial.

**La Regla de Oro:** Todo cambio en la distribución debe viajar a las máquinas cliente **exclusivamente a través de `omarchy update`**. Nada de dotfiles sueltos ni scripts manuales por máquina.

---

## 📚 Estructura de Secciones

* **[Guía de Usuario](https://robert-flo.github.io/fork-docs/guide/01-introduccion/):** Filosofía del proyecto, onboarding desatendido en 3 comandos y uso diario.
* **[Arquitectura](https://robert-flo.github.io/fork-docs/architecture/01-topologia/):** Topología de los 4 repositorios, Matriz de Decisión estricta, sombreado `pkgrel=99`, pipeline de las 04:00 AM y modelo de seguridad GPG.
* **[Operaciones](https://robert-flo.github.io/fork-docs/operations/01-flujo-desarrollo/):** Ciclo de desarrollo `pkg-test`, creación de paquetes con `"personal": true`, rotación de claves GPG (ADR-006 DR) y runbook de contingencias.
* **[ADRs](https://robert-flo.github.io/fork-docs/adrs/):** Colección formal de los 9 Architecture Decision Records (ADR-001 al ADR-009).
* **[Referencia](https://robert-flo.github.io/fork-docs/reference/glosario/):** Glosario de términos canónicos y registro cronológico consolidado de cambios.

---

## 🛠️ Desarrollo Local

```bash
# 1. Instalar dependencias
bundle install

# 2. Compilar y servir localmente con livereload
bundle exec jekyll serve --livereload
```
