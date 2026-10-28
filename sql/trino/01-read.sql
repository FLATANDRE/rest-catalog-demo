SHOW CATALOGS;
SHOW SCHEMAS FROM iceberg;
SHOW TABLES FROM iceberg.governo;

SELECT contrato_id, orgao, fornecedor, valor, atualizado_em
FROM iceberg.governo.contratos
ORDER BY contrato_id;
