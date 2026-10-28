-- Dados inteiramente fictícios para demonstração técnica.
CREATE NAMESPACE IF NOT EXISTS polaris.governo;

DROP TABLE IF EXISTS polaris.governo.contratos;

CREATE TABLE polaris.governo.contratos (
  contrato_id BIGINT,
  orgao STRING,
  fornecedor STRING,
  valor DECIMAL(14,2),
  atualizado_em TIMESTAMP
) USING iceberg;

INSERT INTO polaris.governo.contratos VALUES
  (1001, 'Secretaria de Dados',    'Alpha Tecnologia', CAST(125000.00 AS DECIMAL(14,2)), TIMESTAMP '2026-10-20 10:00:00'),
  (1002, 'Secretaria de Saude',    'Beta Servicos',     CAST(84500.00 AS DECIMAL(14,2)), TIMESTAMP '2026-10-21 11:30:00'),
  (1003, 'Secretaria de Educacao', 'Gamma Cloud',      CAST(210000.00 AS DECIMAL(14,2)), TIMESTAMP '2026-10-22 09:15:00');

SELECT contrato_id, orgao, fornecedor, valor, atualizado_em
FROM polaris.governo.contratos
ORDER BY contrato_id;
