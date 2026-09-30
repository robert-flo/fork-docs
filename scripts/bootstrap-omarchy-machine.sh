#!/usr/bin/env bash
# bootstrap-omarchy-machine.sh — Aprovisionamiento desatendido para máquinas cliente
# Ecosistema Omarchy Personal Fork (Roberto Flores)
# https://robert-flo.github.io/fork-docs/
set -euo pipefail

KEY_URL="https://robert-flo.github.io/omarchy-personal-repo/keys/omarchy-personal-repo.pub.asc"
KEY_ID="76AFFCC217DB9FC4"
FINGERPRINT="CD92AB07B1D24DC9A74EB60E76AFFCC217DB9FC4"
REPO_URL="https://robert-flo.github.io/omarchy-personal-repo/stable/\$arch"
PACMAN_CONF="/etc/pacman.conf"

echo "=== Iniciando Onboarding de Omarchy Personal Fork ==="

# 1. Comprobar permisos de sudo
if [[ $EUID -ne 0 ]]; then
  SUDO="sudo"
else
  SUDO=""
fi

# 2. Descargar e importar clave GPG
echo "[1/3] Importando clave pública de firma GPG (${KEY_ID})..."
TMP_KEY="$(mktemp /tmp/omarchy-key.XXXXXX.asc)"
curl -fsSL "${KEY_URL}" -o "${TMP_KEY}"

${SUDO} pacman-key --add "${TMP_KEY}"
${SUDO} pacman-key --lsign-key "${KEY_ID}"
rm -f "${TMP_KEY}"
echo "✓ Clave GPG confiada con éxito."

# 3. Inyectar [omarchy-personal] en /etc/pacman.conf
echo "[2/3] Configurando repositorio en ${PACMAN_CONF}..."
if grep -q "\[omarchy-personal\]" "${PACMAN_CONF}"; then
  echo "✓ Repositorio [omarchy-personal] ya estaba presente en ${PACMAN_CONF}."
else
  ${SUDO} sed -i '/^\[core\]/i \[omarchy-personal\]\nSigLevel = Required DatabaseOptional\nServer = '"${REPO_URL}"'\n' "${PACMAN_CONF}"
  echo "✓ Sección [omarchy-personal] agregada antes de [core]."
fi

# 4. Sincronizar y actualizar
echo "[3/3] Sincronizando bases de datos y actualizando paquetes..."
${SUDO} pacman -Sy

echo ""
echo "=== Onboarding Completado Exitosamente ==="
echo "Ahora puedes ejecutar 'omarchy update' para instalar la última versión sombreada."
echo "Para más detalles visita: https://robert-flo.github.io/fork-docs/"
