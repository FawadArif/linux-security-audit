#!/usr/bin/env bash
set -euo pipefail

LOG="setup_$(date +%F_%H%M).log"
exec > >(tee -a "$LOG") 2>&1

[ "$EUID" -eq 0 ] || { echo "Run with sudo"; exit 1; }

TOOLS=(git curl wget vim htop unzip jq python3 python3-pip docker.io)

echo "Updating package index..."
apt-get update -y

for pkg in "${TOOLS[@]}"; do
  if dpkg -s "$pkg" >/dev/null 2>&1; then
    echo "[SKIP] $pkg already installed"
  else
    echo "[INSTALL] $pkg"
    apt-get install -y "$pkg" || echo "[FAIL] $pkg"
  fi
done


systemctl enable --now docker
if [ -n "${SUDO_USER:-}" ]; then
  usermod -aG docker "$SUDO_USER"
  echo "Log out and back in so docker works without sudo"
fi

if ! command -v terraform >/dev/null; then
  wget -qO- https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/hashicorp.gpg
  echo "deb [signed-by=/usr/share/keyrings/hashicorp.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" \
    > /etc/apt/sources.list.d/hashicorp.list
  apt-get update -y && apt-get install -y terraform
fi


if ! command -v aws >/dev/null; then
  curl -s "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o /tmp/awscli.zip
  unzip -q /tmp/awscli.zip -d /tmp && /tmp/aws/install
fi

echo "Versions:"
for c in git docker terraform aws python3; do
  printf "%-10s" "$c"; "$c" --version 2>&1 | head -1
done
echo "Setup complete. Log: $LOG"
