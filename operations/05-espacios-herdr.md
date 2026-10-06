---
layout: default
title: Espacios Herdr de la flota
description: "How-to del 2026-10-05: los mismos espacios de Herdr en DEV y en las hijas, sin publicar session.json ni resetear el home."
---

# Espacios Herdr de la flota

Caso del **2026-10-05**. Las máquinas del fork deben abrir los mismos espacios de Herdr, uno por directorio de `~/Work/tries`, y en cada espacio las pestañas `agy`, `elio` y `nvim`.

El código quedó en `personal` con [robert-flo/omarchy#7](https://github.com/robert-flo/omarchy/pull/7). Este how-to es el procedimiento de los espacios. No sustituye a [W4](/fork-docs/operations/00-recetas-rapidas/), [W6](/fork-docs/operations/00-recetas-rapidas/#w6) ni [W7](/fork-docs/operations/00-recetas-rapidas/): los combina. `elio-bin` sigue [W6](/fork-docs/operations/00-recetas-rapidas/#w6). `migrations/1791260741.sh` es precedente; no es parte de este procedimiento.

---

## 1. Qué archivo es el default

| Pieza | Dónde se edita | Qué hace |
| :--- | :--- | :--- |
| Lista de espacios | `default/herdr/spaces` | Nombres de directorio bajo `~/Work/tries`. Viaja en `omarchy-settings`. |
| Seed | `bin/omarchy-herdr-seed-spaces` | Crea o reutiliza cada espacio por la API de Herdr y agrega las pestañas que falten. |
| Teclas y tema | `config/herdr/config.toml` | Sigue siendo config de usuario. `omarchy refresh herdr` la copia a `~/.config/herdr/config.toml`. |
| `elio` | `install/omarchy-aur.packages` | Una línea `elio-bin`. `omarchy-pkg-sync` lo instala con `omarchy-pkg-aur-add`. El paquete es `aur/elio-bin`. `migrations/1791260741.sh` queda como precedente, no como receta. |

`omarchy refresh herdr` refresca `config.toml` y, si el server de Herdr está corriendo, llama al seed. Si Herdr está cerrado, las teclas igual se actualizan y los espacios esperan a la próxima corrida con Herdr abierto.

El seed es idempotente: un espacio cuyo `cwd` ya existe se reutiliza (el de `pj-omarchy` que se llamaba `try: pj-omarchy` pasa a llamarse `pj-omarchy`). No cierra pestañas ajenas. Una segunda corrida no duplica.

La lista actual:

`_estrategia_de_sincronizacion`, `fo-omarchy-in-omarchy`, `fo-quickshell`, `pj-fleet`, `pj-funeraria-website`, `pj-omarchy`, `pj-paolino`, `rf-learn-astro`, `rf-learn-rust`, `rf-omarchy-bluesky-theme`, `rf-pstack`, `rf-reel`, `rf-Template`, `rf-try-clone`, `rf-x-bookmarks`.

Agregar un proyecto es una línea en `default/herdr/spaces`.

---

## 2. Qué no usar

**`~/.config/herdr/session.json` no se commitea.** Herdr lo reescribe mientras corre. El archivo guarda espacios, pestañas y el `cwd`. No guarda el comando de la pestaña, así que copiarlo deja shells vacíos y no arranca `agy`, `elio` ni `nvim`.

**`/etc/skel` no actualiza una máquina que ya tiene usuario.** `config/` se instala en `/etc/skel/.config/` para una cuenta nueva y, en paralelo, en `/usr/share/omarchy/config/` para el refresh. `omarchy-reinstall-configs` copia todo el skel encima de `$HOME`, sin backup. Eso es un reset del home, no el update de la flota.

**`elio-bin` entra por `install/omarchy-aur.packages`.** No va en `omarchy-base.packages`: `omarchy reinstall pkgs` y pacman no ven el AUR. `omarchy-pkg-sync` lee esa lista y llama `omarchy-pkg-aur-add`. `migrations/1791260741.sh` queda como precedente de cuando el paquete entró por migración; no es la receta del próximo paquete del AUR. La receta vigente es [W6](/fork-docs/operations/00-recetas-rapidas/#w6). El código está en [robert-flo/omarchy#17](https://github.com/robert-flo/omarchy/pull/17), todavía sin merge.

**Un push a `personal` no publica.** `release-personal.yml` solo corre por `workflow_dispatch`. No hace falta una release por cada commit, ni hay que esperar a que upstream saque `4.0.5`. Se publica cuando la flota debe recibir el cambio. El mismo `4.0.4` se republica subiendo el `pkgrel`. Si upstream etiqueta `4.0.5`, a las 04:00 `sync-check.yml` dispara la release, rebasea `personal` y, si no hay conflicto, publica `4.0.5-99` con los commits que ya estaban en `personal`.

---

## 3. Máquina DEV (gracie)

`~/Work/omarchy/omarchy-installer` apunta al checkout de `fo-omarchy`. Herdr tiene que estar abierto.

```bash
cd ~/Work/omarchy/omarchy-installer
omarchy dev pkg-test
omarchy refresh herdr
```

`omarchy dev pkg-test` instala `omarchy-settings-dev` y `omarchy-dev` como `dev.<sha>` y deja la máquina en el canal `-dev`. No sube nada a GitHub. Al final corre `omarchy-pkg-sync`, que instala lo que falte de `omarchy-base.packages` y `omarchy-aur.packages` (en gracie, `elio-bin` si no está). gracie no corre `omarchy update`. `omarchy refresh herdr` baja `config.toml` y siembra los espacios.

---

## 4. Máquinas hijas

El merge a `personal` no basta. Primero se publica, con el pkgver que ya está pinado (hoy `v4.0.4`; el `pkgrel` lo sube la Action):

```bash
gh workflow run release-personal.yml -R robert-flo/omarchy-pkgs \
  --ref personal -f version=v4.0.4
```

Cuando la Action termina en verde, en cada hija, con Herdr abierto:

```bash
omarchy update
omarchy refresh herdr
```

`omarchy update` instala los paquetes sombreados. `elio-bin`, si falta, entra por [W6](/fork-docs/operations/00-recetas-rapidas/#w6). No copia la sesión a `~/.config`. Los espacios los arma el refresh.
