#!/bin/sh
set -eu
apk add --no-cache curl jq >/dev/null

TOKEN_RESPONSE=$(curl -fsS \
  -u "${POLARIS_CLIENT_ID}:${POLARIS_CLIENT_SECRET}" \
  -H 'Polaris-Realm: POLARIS' \
  -d 'grant_type=client_credentials' \
  -d 'scope=PRINCIPAL_ROLE:ALL' \
  http://polaris:8181/api/catalog/v1/oauth/tokens)
TOKEN=$(printf '%s' "$TOKEN_RESPONSE" | jq -er '.access_token')
AUTH="Authorization: Bearer ${TOKEN}"
REALM='Polaris-Realm: POLARIS'
CATALOG_URL='http://polaris:8181/api/management/v1/catalogs/quickstart_catalog'

STATUS=$(curl -sS -o /tmp/catalog.json -w '%{http_code}' -H "$AUTH" -H "$REALM" "$CATALOG_URL")
if [ "$STATUS" = '404' ]; then
  cat >/tmp/create-catalog.json <<'JSON'
{
  "catalog": {
    "name": "quickstart_catalog",
    "type": "INTERNAL",
    "readOnly": false,
    "properties": {
      "default-base-location": "s3://lakehouse/warehouse"
    },
    "storageConfigInfo": {
      "storageType": "S3",
      "allowedLocations": ["s3://lakehouse"],
      "endpoint": "http://silo:9000",
      "endpointInternal": "http://silo:9000",
      "pathStyleAccess": true
    }
  }
}
JSON
  curl -fsS -H "$AUTH" -H "$REALM" \
    -H 'Content-Type: application/json' \
    -X POST http://polaris:8181/api/management/v1/catalogs \
    --data-binary @/tmp/create-catalog.json >/dev/null
  echo 'Catálogo quickstart_catalog criado.'
elif [ "$STATUS" = '200' ]; then
  echo 'Catálogo quickstart_catalog já existe.'
else
  echo "Falha ao consultar catálogo: HTTP $STATUS" >&2
  cat /tmp/catalog.json >&2
  exit 1
fi

GRANT_STATUS=$(curl -sS -o /tmp/grant.json -w '%{http_code}' \
  -H "$AUTH" -H "$REALM" -H 'Content-Type: application/json' \
  -X PUT \
  "$CATALOG_URL/catalog-roles/catalog_admin/grants" \
  -d '{"type":"catalog","privilege":"CATALOG_MANAGE_CONTENT"}')
case "$GRANT_STATUS" in
  200|201|204|409) echo 'Privilégio de gestão de conteúdo pronto.' ;;
  *) echo "Falha ao conceder privilégio: HTTP $GRANT_STATUS" >&2; cat /tmp/grant.json >&2; exit 1 ;;
esac
