---
layout: default
title: Onboarding de Máquinas
description: "Guía completa de 7 pasos para incorporar cualquier máquina Arch Linux al repositorio personal de forma reproducible y completa."
---

# Onboarding de Máquinas

Esta guía detalla el procedimiento exacto para incorporar una máquina nueva (laptop, desktop o máquina virtual Arch Linux con Omarchy) al repositorio personal.

Una vez completado este proceso de 7 pasos, la máquina quedará vinculada permanentemente y recibirá todas las personalizaciones a través del comando estándar `omarchy update`.

> **Importante:** No saltes pasos. Los pasos 5 y 6 son críticos: sin ellos la máquina queda con los paquetes instalados pero los launchers, stubs y configuraciones de usuario **no se materializan** en `$HOME`. `omarchy update` no re-provisiona un `$HOME` existente por diseño (ADR-009).

---

## Procedimiento Manual en 7 Pasos

### Paso 1: Importar y firmar localmente la clave GPG del repositorio

El repositorio personal firma criptográficamente cada paquete y la base de datos `omarchy.db`. Para que `pacman` confíe en el repositorio, descarga la clave pública e impórtala en el llavero del sistema:

```bash
# Descargar la clave pública oficial del repositorio
curl -fsSL https://robert-flo.github.io/omarchy-personal-repo/keys/omarchy-personal-repo.pub.asc -o /tmp/omarchy-personal-repo.pub.asc

# Importar y confiar localmente en la clave (ID: 76AFFCC217DB9FC4)
sudo pacman-key --add /tmp/omarchy-personal-repo.pub.asc
sudo pacman-key --lsign-key 76AFFCC217DB9FC4
rm -f /tmp/omarchy-personal-repo.pub.asc
```

> **Nota:** La huella dactilar (*fingerprint*) canónica de la clave RSA 4096-bit es:
> `CD92 AB07 B1D2 4DC9 A74E  B60E 76AF FCC2 17DB 9FC4`
>
> Consulta el **[Estado Actual del Sistema](/fork-docs/reference/historial-cambios/)** para verificar que este ID es el vigente antes de importar.

---

### Paso 2: Instalar el par personal por primera vez (bootstrap sin repo configurado)

Descarga e instala directamente el par personal desde el CDN **antes** de registrar el repositorio en `pacman.conf`. Esto garantiza que el par personal tenga prioridad desde el primer `pacman -Syu`:

```bash
REPO="https://robert-flo.github.io/omarchy-personal-repo/stable/x86_64"
# Consulta reference/historial-cambios para la versión actual del par
VER="<versión-actual>"

curl -O "$REPO/omarchy-${VER}-any.pkg.tar.zst"
curl -O "$REPO/omarchy-${VER}-any.pkg.tar.zst.sig"
curl -O "$REPO/omarchy-settings-${VER}-any.pkg.tar.zst"
curl -O "$REPO/omarchy-settings-${VER}-any.pkg.tar.zst.sig"

sudo pacman -U omarchy-${VER}-any.pkg.tar.zst \
               omarchy-settings-${VER}-any.pkg.tar.zst
```

> **Nota:** Este paso garantiza que el par personal (`pkgrel=99+`) esté instalado antes de que `pacman -Syu` pueda instalar el par oficial (`pkgrel=1`). Sin este paso, el paso 3 podría instalar el par oficial primero.

---

### Paso 3: Registrar el repositorio en `/etc/pacman.conf`

Edita `/etc/pacman.conf` y añade el bloque `[omarchy-personal]` **inmediatamente antes** de las secciones estándar de Arch Linux (`[core]`, `[extra]`) o del repositorio oficial de Omarchy.

La posición al inicio garantiza que pacman resuelva paquetes sombreados prioritariamente desde nuestro CDN:

```ini
[omarchy-personal]
SigLevel = Required DatabaseOptional
Server = https://robert-flo.github.io/omarchy-personal-repo/stable/$arch
```

Puedes agregarlo automáticamente con este comando seguro:

```bash
sudo sed -i '/^\[core\]/i \[omarchy-personal\]\nSigLevel = Required DatabaseOptional\nServer = https://robert-flo.github.io/omarchy-personal-repo/stable/$arch\n' /etc/pacman.conf
```

---

### Paso 4: Sincronizar la configuración de pacman

Aplica la nueva configuración de repositorios al sistema sin reemplazar los paquetes ya instalados:

```bash
sudo omarchy refresh pacman
```

Este comando reescribe `pacman.conf` con el orden correcto de repositorios (personal → oficial) y sincroniza la base de datos de pacman.

---

### Paso 5: Actualizar vía `omarchy update`

Ejecuta la actualización completa para que todas las personalizaciones del par queden instaladas y sincronizadas:

```bash
omarchy update
```

---

### Paso 6: Provisionar el entorno de usuario (CRÍTICO)

Este paso es obligatorio. `omarchy update` instala los paquetes en el sistema pero **no materializa automáticamente** launchers, stubs y configuraciones en el `$HOME` de usuarios existentes (por diseño, ADR-009).

Ejecuta el provisioning forzado para materializar todos los archivos del par en tu `$HOME`:

```bash
omarchy provision user --force
```

Esto crea:
- Launchers `.desktop` en `~/.local/share/applications/`
- Stubs y wrappers de mise en `~/.local/bin/`
- Configuraciones de usuario en `~/.config/`
- El directorio de trabajo `~/src` si algún launcher lo requiere

Luego, reconcilia el conjunto de paquetes del sistema para instalar todo lo declarado en el fork:

```bash
omarchy reinstall pkgs
```

---

### Paso 7: Verificar la instalación

Comprueba que la máquina está consumiendo la versión personal correcta:

```bash
pacman -Q omarchy omarchy-settings
```

**Resultado esperado:**
Ambos paquetes deben reportar una versión con sufijo `-99` o superior (por ejemplo: `omarchy 4.0.4-99` y `omarchy-settings 4.0.4-99`).

También puedes comprobar el empaquetador oficial:

```bash
pacman -Qi omarchy | grep "Packager"
# Salida esperada: Packager : Roberto Flores <25asab015@ujmd.edu.sv>
```

---

## Script Automatizado de Bootstrap

Si prefieres aprovisionar una máquina con una sola línea de comandos desatendida, puedes ejecutar el script de bootstrap oficial:

```bash
curl -fsSL https://raw.githubusercontent.com/robert-flo/fork-docs/main/scripts/bootstrap-omarchy-machine.sh | bash
```

Este script realiza automáticamente todos los 7 pasos del procedimiento manual:
1. Verificación de permisos de superusuario (`sudo`).
2. Descarga e importación segura de la clave pública GPG con validación de huella.
3. Instalación bootstrap del par personal directamente desde el CDN.
4. Inyección idempotente de la sección `[omarchy-personal]` en `/etc/pacman.conf`.
5. Sincronización de la configuración de pacman (`omarchy refresh pacman`).
6. Ejecución de `omarchy update`.
7. Provisioning del entorno de usuario (`omarchy provision user --force` + `omarchy reinstall pkgs`).
