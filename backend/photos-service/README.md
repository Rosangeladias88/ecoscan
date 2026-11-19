# Photos Service

Serviço responsável pelo recebimento, armazenamento e recuperação das fotografias dos usuários do EcoScan.

## Tecnologias

- NestJS
- TypeScript
- PostgreSQL
- Prisma
- JWT
- Multer

## Porta padrão

`3001`

## Configuração

O serviço possui um `.env.example` com a variável:

| Variável | Finalidade |
|---|---|
| PORT | Porta do serviço |

A configuração local também utiliza variáveis de conexão com banco e autenticação:

- DATABASE_URL
- SHADOW_DATABASE_URL
- JWT_SECRET

Configure os valores localmente sem compartilhá-los.

## Instalação

```bash
npm install
```

## Execução

```bash
npm run start:dev
```

## Rotas

Todas as rotas de fotografias exigem autenticação JWT.

| Método | Rota | Descrição |
|---|---|---|
| POST | `/photos` | Envio de fotografia |
| GET | `/photos` | Listagem de fotografias |
| GET | `/photos/:id` | Consulta de metadados |
| GET | `/photos/:id/file` | Recuperação do arquivo |

## Envio de arquivos

O envio utiliza `multipart/form-data`.

Campo obrigatório:

`file`

Limite de tamanho: 5 MB.

## Segurança

O serviço verifica a propriedade da fotografia antes de disponibilizar seus metadados ou arquivo.

## Testes e compilação

```bash
npm run test
npm run build
```
