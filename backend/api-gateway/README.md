# API Gateway

Serviço responsável por centralizar as requisições do cliente e encaminhá-las para as APIs internas do EcoScan.

## Tecnologias

- NestJS
- TypeScript
- Axios
- HttpModule

## Porta padrão

`3004`

## Instalação

```bash
npm install
```

## Execução

```bash
npm run start:dev
```

## Rotas disponibilizadas

### Autenticação

| Método | Rota |
|---|---|
| POST | `/auth/register` |
| POST | `/auth/login` |
| GET | `/auth/me` |

### Materiais

| Método | Rota |
|---|---|
| GET | `/materials` |

### Fotografias

| Método | Rota |
|---|---|
| POST | `/photos` |
| GET | `/photos` |
| GET | `/photos/:id` |
| GET | `/photos/:id/file` |

### Histórico

| Método | Rota |
|---|---|
| POST | `/history` |
| GET | `/history` |

## Serviços de destino

| Serviço | Endereço interno |
|---|---|
| Access | `http://localhost:3000` |
| Photos | `http://localhost:3001` |
| Materials | `http://localhost:3002` |
| History | `http://localhost:3003` |

## Autenticação

Nas operações protegidas, o Gateway encaminha o cabeçalho:

```http
Authorization: Bearer TOKEN
```

A validação do JWT é realizada pelos serviços responsáveis.

## Comunicação

O Gateway utiliza requisições HTTP para se comunicar com as APIs internas.

As chamadas possuem limites de tempo configurados e tratamento de erros de comunicação.

## Testes e compilação

```bash
npm run test
npm run build
```

## Observação

As operações administrativas de materiais disponíveis diretamente na Materials API não estão todas expostas pelo Gateway.
