#!/usr/bin/env bash
set -euo pipefail
ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
cd "$ROOT"

pause() {
  if [[ "${DEMO_AUTO:-0}" != "1" ]]; then
    read -r -p $'\nPressione ENTER para continuar... ' _
  fi
}

./scripts/start.sh
printf '\n\033[1;34mETAPA 1 — Spark cria a tabela e grava três registros\033[0m\n'
pause
./scripts/spark-sql.sh sql/spark/01-create.sql

printf '\n\033[1;34mETAPA 2 — Trino descobre e lê a mesma tabela\033[0m\n'
pause
./scripts/trino-sql.sh sql/trino/01-read.sql

printf '\n\033[1;34mETAPA 3 — Trino inclui o quarto registro\033[0m\n'
pause
./scripts/trino-sql.sh sql/trino/02-insert.sql

printf '\n\033[1;34mETAPA 4 — Spark relê a tabela e encontra o commit do Trino\033[0m\n'
pause
./scripts/spark-sql.sh sql/spark/02-read-after-trino.sql

printf '\n\033[1;32mDemonstração concluída: dois engines, um catálogo REST, uma tabela Iceberg.\033[0m\n'
