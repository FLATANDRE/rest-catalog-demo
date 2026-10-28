#!/usr/bin/env bash
set -euo pipefail
command -v jq >/dev/null || { echo 'Instale jq para executar este script.' >&2; exit 1; }
set -a
source .env
set +a
TOKEN=$(curl -fsS -u "${POLARIS_CLIENT_ID}:${POLARIS_CLIENT_SECRET}" \
  -H 'Polaris-Realm: POLARIS' \
  -d 'grant_type=client_credentials' \
  -d 'scope=PRINCIPAL_ROLE:ALL' \
  http://localhost:8181/api/catalog/v1/oauth/tokens | jq -r '.access_token')

echo '=== Configuração REST ==='
curl -fsS -H "Authorization: Bearer $TOKEN" -H 'Polaris-Realm: POLARIS' \
  'http://localhost:8181/api/catalog/v1/config?warehouse=quickstart_catalog' | jq

echo '=== Namespaces ==='
curl -fsS -H "Authorization: Bearer $TOKEN" -H 'Polaris-Realm: POLARIS' \
  'http://localhost:8181/api/catalog/v1/quickstart_catalog/namespaces' | jq
