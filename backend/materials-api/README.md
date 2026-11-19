# Materials API

API responsável pelo gerenciamento dos materiais recicláveis e das orientações de descarte do EcoScan.

## Tecnologias

- NestJS
- TypeScript
- Prisma
- PostgreSQL

## Porta padrão

`3002`

## Configuração

O ambiente local utiliza:

| Variável | Finalidade |
|---|---|
| DATABASE_URL | Conexão com o PostgreSQL |
| JWT_SECRET | Configuração relacionada à autenticação |

Configure os valores no arquivo `.env` local. Não publique credenciais ou segredos.

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
| GET | `/materials` | Listar materiais |
| GET | `/materials/:id` | Consultar material |
| POST | `/materials` | Cadastrar material |
| PATCH | `/materials/:id` | Atualizar material |
| PATCH | `/materials/:id/deactivate` | Desativar material |
| POST | `/materials/:id/orientation` | Cadastrar orientação |
| PATCH | `/materials/:id/orientation` | Atualizar orientação |

## Cadastro de material

Campos:

- `nome`: obrigatório, máximo de 100 caracteres.
- `categoria`: obrigatória, máximo de 60 caracteres.
- `reciclavel`: booleano.

Exemplo:

```json
{
  "nome": "Garrafa PET",
  "categoria": "Plástico",
  "reciclavel": true
}
```

## Orientações

O cadastro de orientação utiliza:

- `preparo`: obrigatório, máximo de 1000 caracteres.
- `destino`: obrigatório, máximo de 1000 caracteres.

## Testes e compilação

```bash
npm run test
npm run build
```

## Integrações

O API Gateway disponibiliza a listagem de materiais.

O GraphQL Service consulta esta API para disponibilizar a consulta `materiais`.
