---
layout: default
title: Onboarding de Máquinas
description: "Guía de 3 pasos y script de bootstrap para incorporar cualquier máquina Arch Linux al repositorio personal."
---

# Onboarding de Máquinas

Esta guía detalla el procedimiento exacto para incorporar una máquina nueva (laptop, desktop o máquina virtual Arch Linux con Omarchy) al repositorio personal. 

Una vez completado este proceso de 3 pasos, la máquina quedará vinculada permanentemente y recibirá todas las personalizaciones a través del comando estándar `omarchy update`.

---

## Procedimiento Manual en 3 Pasos

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

> [!NOTE]
> La huella dactilar (*fingerprint*) canónica de la clave RSA 4096-bit es:  
> `CD92 AB07 B1D2 4DC9 A74E  B60E 76AF FCC2 17DB 9FC4`

---

### Paso 2: Registrar el repositorio en `/etc/pacman.conf`

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

### Paso 3: Sincronizar y actualizar

Actualiza las bases de datos de paquetes e instala las versiones sombreadas del par personal:

```bash
omarchy update
```

---

## Verificación de Instalación Exitosa

Para comprobar que la máquina está consumiendo la versión personal correcta, consulta la versión instalada de los paquetes principales:

```bash
pacman -Q omarchy omarchy-settings
```

**Resultado esperado:**
Ambos paquetes deben reportar una versión con sufijo `-99` o superior (por ejemplo: `omarchy 4.0.4-99` y `omarchy-settings 4.0.4-99`).

También puedes comprobar los detalles del empaquetado para verificar el empaquetador oficial:

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

Este script realiza automáticamente:
1. Verificación de permisos de superusuario (`sudo`).
2. Descarga e importación segura de la clave pública GPG con validación de huella.
3. Inyección idempotente de la sección `[omarchy-personal]` en `/etc/pacman.conf`.
4. Ejecución de `pacman -Sy` y validación de conectividad al CDN en GitHub Pages.
