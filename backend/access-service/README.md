# Access Service

Serviço responsável pelo cadastro, login e autenticação dos usuários do EcoScan.

## Tecnologias

- NestJS
- TypeScript
- Prisma
- PostgreSQL
- JWT

## Porta padrão

`3000`

## Configuração

Crie o arquivo `.env` com base no `.env.example`.

Variáveis:

| Variável | Finalidade |
|---|---|
| DATABASE_URL | Conexão com o PostgreSQL |
| JWT_SECRET | Segredo utilizado na autenticação JWT |
| PORT | Porta do serviço |

Não compartilhe valores reais dessas variáveis.

## Instalação

```bash
npm install
```

## Execução

```bash
npm run start:dev
```

## Rotas

| Método | Rota | Descrição |
|---|---|---|
| POST | `/auth/register` | Cadastro |
| POST | `/auth/login` | Login |
| GET | `/auth/me` | Perfil autenticado |

A rota `/auth/me` exige JWT.

## Testes e compilação

```bash
npm run test
npm run build
```

## Observação

O API Gateway encaminha as requisições de autenticação para este serviço.
