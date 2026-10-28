#!/usr/bin/env bash
set -euo pipefail
FILE=${1:?Uso: ./scripts/trino-sql.sh sql/trino/arquivo.sql}
[[ -f "$FILE" ]] || { echo "Arquivo não encontrado: $FILE" >&2; exit 1; }
CONTAINER_FILE="/demo/${FILE#./}"
docker compose exec -T trino trino --file "$CONTAINER_FILE"
