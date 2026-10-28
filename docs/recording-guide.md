# Guia rápido de gravação

## Antes da tomada

1. Execute `make reset` para remover ensaios anteriores.
2. Execute `make start` e aguarde a saúde de todos os serviços.
3. Execute `DEMO_AUTO=1 ./scripts/demo.sh` uma vez para baixar dependências Maven e validar o fluxo.
4. Limpe a tela e aumente a fonte do terminal.
5. Execute `make demo` durante a gravação; o script pausa entre as etapas.

## Enquadramento sugerido

- Mostre `compose.yaml` apenas nas linhas da URI REST e do warehouse.
- Na primeira etapa, destaque `CREATE TABLE` e os três registros.
- Na segunda, destaque que o Trino usa `iceberg.catalog.type=rest`.
- Na terceira, destaque o `INSERT` feito por outro engine.
- Na quarta, destaque os quatro registros e a tabela de snapshots.
- Execute `make inspect` para tornar o contrato HTTP visível.

## Plano B

Grave uma execução completa antes da tomada principal. O primeiro uso baixa imagens Docker e dependências Maven e, portanto, requer internet e pode demorar. Se a escrita do Trino falhar por incompatibilidade de versão, preserve os logs, execute `make reset` e confirme as versões em `.env` antes de regravar.
