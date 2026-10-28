#!/usr/bin/env bash
set -euo pipefail
printf '\n==> Iniciando o laboratório...\n'
docker compose up -d --wait --wait-timeout 300
printf '\n==> Serviços prontos.\n'
docker compose ps
printf '\nInterfaces:\n- Polaris: http://localhost:8181\n- Console: http://localhost:8088\n- Silo:    http://localhost:9001\n- Trino:   http://localhost:8080\n\n'
