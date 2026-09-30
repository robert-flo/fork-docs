---
layout: default
title: Rotación de Claves GPG & DR
description: "Guía operativa de rotación de claves GPG y plan de contingencia ante pérdida de claves."
---

# Rotación de Claves GPG & Disaster Recovery

Este procedimiento documenta el protocolo operativo para **rotar la clave de firma del repositorio** o recuperar el sistema en caso de pérdida o compromiso de la clave privada anterior.

Este flujo fue ejecutado y validado en producción el **2026-09-30**, formalizado bajo el **ADR-006 DR**.

---

## 1. Generación de un Nuevo Par de Claves RSA 4096-bit

En una máquina segura de desarrollo con GnuPG:

```bash
cat << 'EOF' > /tmp/gen-key.conf
Key-Type: RSA
Key-Length: 4096
Subkey-Type: RSA
Subkey-Length: 4096
Name-Real: Roberto Flores
Name-Email: 25asab015@ujmd.edu.sv
Expire-Date: 0
%no-protection
%commit
EOF

# Generar la clave sin passphrase para uso desatendido en CI
gpg --batch --generate-key /tmp/gen-key.conf
rm -f /tmp/gen-key.conf
```

Obtén el ID y fingerprint de la clave recién generada:

```bash
gpg --list-secret-keys --keyid-format LONG "25asab015@ujmd.edu.sv"
```

Identifica:
* **Fingerprint:** ej. `CD92 AB07 B1D2 4DC9 A74E  B60E 76AF FCC2 17DB 9FC4`
* **Key ID (corto):** ej. `76AFFCC217DB9FC4`

---

## 2. Actualización de Secretos en GitHub Actions

Exporta la clave privada completa en formato ASCII blindado:

```bash
gpg --armor --export-secret-keys 76AFFCC217DB9FC4 > /tmp/new_private.key
```

Actualiza el secreto de GitHub Actions en el repositorio de empaquetado:

```bash
gh secret set GPG_PRIVATE_KEY -R robert-flo/omarchy-pkgs < /tmp/new_private.key
rm -f /tmp/new_private.key
```

---

## 3. Actualización de la Clave Pública en los Repositorios

Exporta la clave pública:

```bash
gpg --armor --export 76AFFCC217DB9FC4 > /tmp/omarchy-personal-repo.pub.asc
```

Copia la clave pública a los repositorios correspondientes:

1. **En `robert-flo/omarchy-personal-repo`:**
   ```bash
   cp /tmp/omarchy-personal-repo.pub.asc ~/Work/omarchy/robert-flo-omarchy-personal-repo/keys/
   cd ~/Work/omarchy/robert-flo-omarchy-personal-repo
   git add keys/omarchy-personal-repo.pub.asc
   git commit -m "security: rotate personal repo signing key (ADR-006)"
   git push origin gh-pages
   ```

2. **En `robert-flo/omarchy`:**
   ```bash
   cp /tmp/omarchy-personal-repo.pub.asc ~/Work/omarchy/robert-flo_omarchy-personal/keys/
   cd ~/Work/omarchy/robert-flo_omarchy-personal
   # Actualiza el fingerprint en default/pacman/pacman-stable.conf y README.md
   git commit -am "security: update public signing key to 76AFFCC217DB9FC4"
   git push origin personal
   ```

---

## 4. Recompilación y Firma de Paquetes en Producción

Dispara el workflow de release para regenerar la base de datos firmada con la nueva clave:

```bash
gh workflow run release-personal.yml -R robert-flo/omarchy-pkgs \
  --ref personal -f version=v4.0.4
```

Espera a que finalice y verifica que el CDN sirva la base de datos firmada:

```bash
curl -sI https://robert-flo.github.io/omarchy-personal-repo/stable/x86_64/omarchy.db.tar.zst.sig | grep "HTTP/2 200"
```

---

## 5. Actualización de Máquinas Cliente Existentes

En cada computadora configurada con el repositorio:

```bash
# Descargar e importar la nueva clave pública
curl -fsSL https://robert-flo.github.io/omarchy-personal-repo/keys/omarchy-personal-repo.pub.asc -o /tmp/omarchy-personal-repo.pub.asc
sudo pacman-key --add /tmp/omarchy-personal-repo.pub.asc
sudo pacman-key --lsign-key 76AFFCC217DB9FC4
rm -f /tmp/omarchy-personal-repo.pub.asc

# Probar actualización con la nueva clave
omarchy update
```
