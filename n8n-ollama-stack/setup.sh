#!/usr/bin/env bash
# One-time local setup helper: generates a self-signed TLS cert for nginx
# and an .htpasswd file for the extra nginx-level basic auth layer.
#
# For a real deployment with a domain name, replace the self-signed cert
# with a Let's Encrypt certificate (e.g. via certbot) instead.

set -euo pipefail

cd "$(dirname "$0")"

echo "== 1. Creating .env from template (if missing) =="
if [ ! -f .env ]; then
  cp .env.example .env
  ENC_KEY=$(openssl rand -hex 32)
  # macOS/BSD sed vs GNU sed compatibility
  if sed --version >/dev/null 2>&1; then
    sed -i "s/replace-with-openssl-rand-hex-32-output/${ENC_KEY}/" .env
  else
    sed -i '' "s/replace-with-openssl-rand-hex-32-output/${ENC_KEY}/" .env
  fi
  echo "Created .env with a generated N8N_ENCRYPTION_KEY."
  echo "!!! Edit .env now and set N8N_BASIC_AUTH_USER / N8N_BASIC_AUTH_PASSWORD !!!"
else
  echo ".env already exists, skipping."
fi

echo "== 2. Generating self-signed TLS certificate for nginx =="
mkdir -p nginx/certs
if [ ! -f nginx/certs/fullchain.pem ]; then
  openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout nginx/certs/privkey.pem \
    -out nginx/certs/fullchain.pem \
    -subj "/CN=localhost"
  echo "Self-signed cert generated (valid 365 days, CN=localhost)."
  echo "Your browser will warn about this cert — that's expected for local use."
else
  echo "Certificate already exists, skipping."
fi

echo "== 3. Creating nginx .htpasswd file =="
if [ ! -f nginx/.htpasswd ]; then
  read -rp "Choose an nginx basic-auth username: " NGINX_USER
  if command -v htpasswd >/dev/null 2>&1; then
    htpasswd -c nginx/.htpasswd "$NGINX_USER"
  else
    # Fallback if apache2-utils isn't installed: use openssl to hash
    read -rsp "Choose a password: " NGINX_PASS
    echo
    HASH=$(openssl passwd -apr1 "$NGINX_PASS")
    echo "${NGINX_USER}:${HASH}" > nginx/.htpasswd
  fi
  echo "nginx/.htpasswd created."
else
  echo "nginx/.htpasswd already exists, skipping."
fi

echo
echo "Setup complete. Review .env, then run:"
echo "  docker compose up -d"
