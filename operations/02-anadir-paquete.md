---
layout: default
title: Añadir un Paquete Personal
description: "Procedimiento para añadir paquetes personales a omarchy-pkgs mediante la bandera personal: true."
---

# Añadir un Paquete Personal

Además del par fundamental (`omarchy` y `omarchy-settings`), nuestro repositorio pacman puede empaquetar y distribuir **cualquier paquete adicional** que desees tener disponible en tus computadoras (utilidades propias, scripts o aplicaciones empaquetadas desde fuentes locales).

---

## 1. Estructura de un Paquete Personal

Cada paquete se declara dentro del repositorio `robert-flo/omarchy-pkgs` bajo el directorio `pkgbuilds/<nombre-paquete>/`:

```text
pkgbuilds/mi-paquete/
├── PKGBUILD            # Receta estándar de empaquetado de Arch Linux
└── .omarchy/
    └── package.json    # Metadatos del sistema Omarchy (ADR-005)
```

### El archivo `.omarchy/package.json`
El archivo de metadatos debe declarar explícitamente el marcador `"personal": true`:

```json
{
  "source": "local",
  "release_ring": "fast",
  "personal": true
}
```

> [!IMPORTANT]
> El atributo `"personal": true` es el interruptor que indica al pipeline de compilación que este paquete forma parte del catálogo personal y debe construirse y firmarse junto con el repositorio.

---

## 2. Caso de Estudio Real: `hola-mundo`

En el repositorio existe un paquete funcional de referencia llamado `hola-mundo`.

### Contenido de `pkgbuilds/hola-mundo/PKGBUILD`:

```bash
# Maintainer: Roberto Flores <25asab015@ujmd.edu.sv>
pkgname=hola-mundo
pkgver=1.0.0
pkgrel=1
pkgdesc="Paquete de prueba para validar el repositorio personal de Omarchy"
arch=('any')
license=('MIT')
source=("hola-mundo.sh")
sha256sums=('SKIP')

package() {
  install -Dm755 "${srcdir}/hola-mundo.sh" "${pkgdir}/usr/bin/hola-mundo"
}
```

---

## 3. Flujo de Publicación e Instalación

### Paso 1: Crear los archivos en `omarchy-pkgs`
```bash
cd ~/Work/omarchy/robert-flo_omarchy-pkgs
mkdir -p pkgbuilds/mi-herramienta/.omarchy

# Escribe el PKGBUILD y los archivos fuente en pkgbuilds/mi-herramienta/
# Escribe .omarchy/package.json con {"source": "local", "release_ring": "fast", "personal": true}

git add pkgbuilds/mi-herramienta
git commit -m "feat: add paquete mi-herramienta"
git push origin personal
```

### Paso 2: Disparar la Publicación en CI/CD
```bash
gh workflow run release-personal.yml -R robert-flo/omarchy-pkgs \
  --ref personal -f version=v4.0.4
```

Espera a que la Action finalice en verde:
```bash
gh run watch -R robert-flo/omarchy-pkgs --exit-status
```

### Paso 3: Instalar por Primera Vez en tus Máquinas
Una vez publicado en el CDN, instálalo con `pacman` en cualquier computadora:

```bash
sudo pacman -S mi-herramienta
```

De ahí en adelante, cada invocación de `omarchy update` mantendrá actualizado este paquete automáticamente junto con el resto del sistema.
