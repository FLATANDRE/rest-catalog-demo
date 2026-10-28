INSERT INTO iceberg.governo.contratos VALUES (
  1004,
  'Controladoria Geral',
  'Delta Analytics',
  CAST(97000.00 AS DECIMAL(14,2)),
  TIMESTAMP '2026-10-23 14:00:00'
);

SELECT COUNT(*) AS total_esperado_4
FROM iceberg.governo.contratos;

SELECT contrato_id, orgao, fornecedor, valor
FROM iceberg.governo.contratos
ORDER BY contrato_id;
