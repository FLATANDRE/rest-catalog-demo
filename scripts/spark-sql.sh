#!/usr/bin/env bash
set -euo pipefail
FILE=${1:?Uso: ./scripts/spark-sql.sh sql/spark/arquivo.sql}
[[ -f "$FILE" ]] || { echo "Arquivo não encontrado: $FILE" >&2; exit 1; }
CONTAINER_FILE="/demo/${FILE#./}"

docker compose exec -T spark /opt/spark/bin/spark-sql \
  --packages org.apache.iceberg:iceberg-spark-runtime-3.5_2.12:1.9.1,org.apache.iceberg:iceberg-aws-bundle:1.9.1 \
  --conf spark.sql.extensions=org.apache.iceberg.spark.extensions.IcebergSparkSessionExtensions \
  --conf spark.sql.catalog.polaris=org.apache.iceberg.spark.SparkCatalog \
  --conf spark.sql.catalog.polaris.type=rest \
  --conf spark.sql.catalog.polaris.uri=http://polaris:8181/api/catalog \
  --conf spark.sql.catalog.polaris.warehouse=quickstart_catalog \
  --conf spark.sql.catalog.polaris.credential=root:s3cr3t \
  --conf spark.sql.catalog.polaris.scope=PRINCIPAL_ROLE:ALL \
  --conf spark.sql.catalog.polaris.header.X-Iceberg-Access-Delegation=vended-credentials \
  --conf spark.sql.catalog.polaris.client.region=us-east-1 \
  --conf spark.sql.iceberg.vectorization.enabled=false \
  --conf spark.driver.extraJavaOptions='-Divy.cache.dir=/tmp -Divy.home=/tmp' \
  -f "$CONTAINER_FILE"
