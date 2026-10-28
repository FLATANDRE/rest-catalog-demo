REFRESH TABLE polaris.governo.contratos;

SELECT contrato_id, orgao, fornecedor, valor, atualizado_em
FROM polaris.governo.contratos
ORDER BY contrato_id;

SELECT COUNT(*) AS total_esperado_4
FROM polaris.governo.contratos;

SELECT committed_at, snapshot_id, operation
FROM polaris.governo.contratos.snapshots
ORDER BY committed_at;
