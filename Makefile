SHELL := /usr/bin/env bash
.DEFAULT_GOAL := help

.PHONY: help start demo demo-auto spark-create trino-read trino-insert spark-verify inspect status logs stop reset validate

help:
	@printf '%s\n' \
	  'Comandos disponíveis:' \
	  '  make start         Sobe o laboratório' \
	  '  make demo          Executa a demonstração com pausas' \
	  '  make demo-auto     Executa toda a demonstração sem pausas' \
	  '  make spark-create  Spark cria tabela e três registros' \
	  '  make trino-read    Trino lê a tabela' \
	  '  make trino-insert  Trino inclui o quarto registro' \
	  '  make spark-verify  Spark relê e mostra snapshots' \
	  '  make inspect       Mostra respostas do REST Catalog' \
	  '  make status        Exibe containers e saúde' \
	  '  make logs          Acompanha logs' \
	  '  make stop          Para containers e preserva o volume' \
	  '  make reset         Remove containers e dados do Silo' \
	  '  make validate      Valida arquivos locais sem subir Docker'

start:
	@./scripts/start.sh

demo:
	@./scripts/demo.sh

demo-auto:
	@DEMO_AUTO=1 ./scripts/demo.sh

spark-create:
	@./scripts/spark-sql.sh sql/spark/01-create.sql

trino-read:
	@./scripts/trino-sql.sh sql/trino/01-read.sql

trino-insert:
	@./scripts/trino-sql.sh sql/trino/02-insert.sql

spark-verify:
	@./scripts/spark-sql.sh sql/spark/02-read-after-trino.sql

inspect:
	@./scripts/inspect-rest.sh

status:
	@docker compose ps

logs:
	@docker compose logs -f --tail=200

stop:
	@docker compose stop

reset:
	@docker compose down -v --remove-orphans

validate:
	@bash -n scripts/*.sh
	@python3 -c 'import yaml; yaml.safe_load(open("compose.yaml")); print("compose.yaml: sintaxe YAML válida")'
	@echo 'Scripts shell: sintaxe válida'
