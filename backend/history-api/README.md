# History API

Serviço responsável pelo registro e pela consulta do histórico de atividades dos usuários do EcoScan.

## Tecnologias

- NestJS
- TypeScript
- Prisma
- PostgreSQL
- JWT

## Porta padrão

`3003`

## Configuração

Variáveis utilizadas:

| Variável | Finalidade |
|---|---|
| DATABASE_URL | Conexão com o PostgreSQL |
| SHADOW_DATABASE_URL | Banco auxiliar utilizado na configuração do Prisma |
| JWT_SECRET | Validação dos tokens JWT |
| PORT | Porta do serviço |
| PHOTOS_API_URL | Endereço da API de fotografias |

Configure os valores no `.env` local. Não compartilhe segredos.

## Instalação

```bash
npm install
```

## Execução

```bash
npm run start:dev
```

## Rotas

Todas as rotas exigem autenticação JWT.

| Método | Rota | Descrição |
|---|---|---|
| POST | `/history` | Criar registro |
| GET | `/history` | Listar histórico do usuário |
| GET | `/history/:id` | Consultar registro |

## Criar registro

Exemplo:

```json
{
  "materialId": 1,
  "fotografiaId": 1
}
```

O campo `fotografiaId` é opcional e pode ser nulo.

O usuário é identificado pelo token JWT.

## Integração

A History API está integrada ao API Gateway.

O Gateway encaminha as operações de criação e consulta, preservando o cabeçalho Authorization.

## Testes e compilação

```bash
npm run test
npm run build
```
