# Catálogo REST: Spark + Trino + Polaris + Iceberg

Projeto de demonstração para o vídeo **“Catálogo REST e o fim do vendor lock-in”**. O laboratório mostra dois engines independentes operando a mesma tabela Apache Iceberg por meio do Apache Polaris e armazenando os objetos no Silo.

> Uso educacional e local. As credenciais são públicas e inseguras; não use esta configuração em produção. Todos os nomes e registros são fictícios.

## O que será provado

1. Spark cria `polaris.governo.contratos` e grava três linhas.
2. Trino descobre e consulta a mesma tabela pelo Iceberg REST Catalog.
3. Trino grava um quarto registro.
4. Spark atualiza sua visão e encontra o registro e o novo snapshot.
5. A API REST pode ser inspecionada diretamente para fins didáticos.

## Arquitetura

```text
Spark SQL ─┐                         ┌─ metadados Iceberg
           ├── Iceberg REST ─ Polaris ─┤
Trino ─────┘                         └─ credenciais temporárias
       │
       └──────── Parquet + metadata ───────▶ Silo (S3)
```

Consulte `docs/architecture.md` para o diagrama Mermaid.

## Pré-requisitos

- Docker Engine 24 ou superior com Docker Compose v2.
- Aproximadamente 8 GB de RAM disponíveis para Docker.
- `make`, Bash e `curl`; `jq` é necessário apenas para `make inspect`.
- Internet no primeiro uso para baixar imagens e dependências Maven.

O projeto foi preparado com:

- Apache Polaris e Admin Tool `1.8.0`, mais o Polaris Console (construído a partir do `apache/polaris-tools`, pois ainda não há imagem oficial publicada).
- PostgreSQL `17.6` para persistência do catálogo.
- Apache Spark `3.5.6` com Apache Iceberg `1.9.1`.
- Trino `484`.
- Silo como armazenamento compatível com S3, e MCLI para preparar o bucket.

As tags podem ser alteradas em `.env`, mas qualquer mudança deve ser ensaiada antes da gravação.

## Início rápido

```bash
cp .env.example .env       # opcional; o ZIP já inclui um .env de laboratório
make start
make demo
```

Para executar sem pausas:

```bash
make demo-auto
```

O primeiro comando do Spark pode demorar enquanto resolve os pacotes Iceberg no Maven Central.

## Execução manual

```bash
make start
make spark-create
make trino-read
make trino-insert
make spark-verify
make inspect
```

Essa forma é recomendada para a gravação porque permite explicar cada transição.

## Interfaces

| Serviço | URL | Credenciais |
|---|---|---|
| Polaris REST | http://localhost:8181 | `root` / `s3cr3t` |
| Polaris Console | http://localhost:8088 | `root` / `s3cr3t` (realm `POLARIS`) |
| Polaris health | http://localhost:8182/q/health | — |
| Trino | http://localhost:8080 | sem login (UI como `admin`) |
| Silo Console | http://localhost:9001 | `minio_root` / `m1n1opwd` |
| Silo S3 API | http://localhost:9000 | mesmas credenciais |

## Arquivos principais

```text
.
├── compose.yaml
├── Makefile
├── scripts/
│   ├── demo.sh
│   ├── inspect-rest.sh
│   ├── setup-catalog.sh
│   ├── spark-sql.sh
│   ├── start.sh
│   └── trino-sql.sh
├── sql/
│   ├── spark/
│   │   ├── 01-create.sql
│   │   └── 02-read-after-trino.sql
│   └── trino/
│       ├── 01-read.sql
│       └── 02-insert.sql
└── trino/catalog/iceberg.properties
```

## Comandos úteis

```bash
make help
make status
make logs
make stop       # preserva objetos no volume
make reset      # remove containers e volume Silo
make validate   # valida YAML e sintaxe dos scripts
```

## Como funciona

O catálogo `quickstart_catalog` é criado pelo serviço `polaris-setup`. Sua base é `s3://lakehouse/warehouse`, com acesso ao Silo pela rede interna do Compose. Spark e Trino apontam para `http://polaris:8181/api/catalog`, usam OAuth2 client credentials e solicitam credenciais temporárias para o armazenamento. Silo mantém compatibilidade com as variáveis de configuração `MINIO_*` utilizadas no serviço.

O estado interno do Polaris é persistido no PostgreSQL. `make reset` remove o banco e também os objetos do Silo, permitindo uma gravação limpa. O volume de objetos conserva o nome legado `minio-data` para reutilizar dados de uma execução anterior do laboratório. Uma implantação real exigiria persistência relacional, TLS, gestão externa de segredos, identidade corporativa, observabilidade, backup e alta disponibilidade.

## Solução de problemas

### Porta ocupada

Verifique as portas 8080, 8181, 8182, 9000 e 9001:

```bash
ss -lntp | grep -E ':8080|:8181|:8182|:9000|:9001'
```

### Spark demora na primeira execução

O script usa `--packages` para buscar os JARs Iceberg. Execute `make spark-create` antes da gravação para aquecer o cache do container. Se o container for recriado, o download pode ocorrer novamente.

### Ambiente inconsistente

```bash
make reset
make start
make demo-auto
```

### Inspeção de logs

```bash
docker compose logs --tail=200 polaris polaris-setup trino spark silo
```

## Fontes técnicas

- Apache Polaris Quickstart: https://polaris.apache.org/releases/1.8.0/getting-started/quickstart/
- Silo: https://silo.pgsty.com/docs/
- Silo download e imagens: https://silo.pgsty.com/download/
- Apache Iceberg REST Catalog: https://iceberg.apache.org/docs/latest/rest-catalog/
- Trino Iceberg connector: https://trino.io/docs/current/connector/iceberg.html
- Especificação OpenAPI do catálogo: https://github.com/apache/iceberg/blob/main/open-api/rest-catalog-open-api.yaml
