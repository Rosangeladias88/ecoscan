# Documentação das APIs - EcoScan

Este documento descreve as rotas identificadas na implementação atual do backend.

## 1. Endereços locais

| Serviço | Endereço |
|---|---|
| Access | http://localhost:3000 |
| Photos | http://localhost:3001 |
| Materials | http://localhost:3002 |
| History | http://localhost:3003 |
| API Gateway | http://localhost:3004 |
| GraphQL | http://localhost:3005 |

As rotas do Gateway são utilizadas como ponto de entrada pelo cliente.

## 2. Autenticação

As rotas protegidas utilizam JWT.

Envie o token no cabeçalho:

```http
Authorization: Bearer SEU_TOKEN
```

## 3. Access Service

Base URL: `http://localhost:3000`

### Cadastro

`POST /auth/register`

Exemplo de corpo:

```json
{
  "nome": "Usuário",
  "email": "usuario@email.com",
  "senha": "senha123",
  "papel": "usuario"
}
```

Campos:
- `nome`: obrigatório.
- `email`: obrigatório e deve ser válido.
- `senha`: obrigatória, mínimo de 8 caracteres.
- `papel`: opcional.

Os papéis conhecidos na tipagem do Gateway são `usuario`, `coletador` e `empresa`.

### Login

`POST /auth/login`

```json
{
  "email": "usuario@email.com",
  "senha": "senha123"
}
```

### Perfil autenticado

`GET /auth/me`

Requer JWT.

## 4. Photos Service

Base URL: `http://localhost:3001`

As rotas abaixo exigem autenticação JWT.

### Enviar fotografia

`POST /photos`

Tipo de conteúdo: `multipart/form-data`.

Campo:
- `file`: arquivo da fotografia.

Limite de tamanho: 5 MB.

### Listar fotografias

`GET /photos`

Retorna as fotografias associadas ao usuário autenticado.

### Consultar metadados

`GET /photos/:id`

Consulta uma fotografia pelo identificador, respeitando a propriedade do usuário.

### Recuperar arquivo

`GET /photos/:id/file`

Retorna o arquivo da fotografia.

## 5. Materials API

Base URL: `http://localhost:3002`

### Listar materiais

`GET /materials`

### Consultar material

`GET /materials/:id`

### Cadastrar material

`POST /materials`

```json
{
  "nome": "Garrafa PET",
  "categoria": "Plástico",
  "reciclavel": true
}
```

### Atualizar material

`PATCH /materials/:id`

Aceita os campos de cadastro de forma opcional.

### Desativar material

`PATCH /materials/:id/deactivate`

### Cadastrar orientação

`POST /materials/:id/orientation`

```json
{
  "preparo": "Lavar e retirar os resíduos.",
  "destino": "Encaminhar para a coleta seletiva."
}
```

### Atualizar orientação

`PATCH /materials/:id/orientation`

Aceita os campos `preparo` e `destino` de forma opcional.

## 6. History API

Base URL: `http://localhost:3003`

As rotas exigem autenticação JWT.

### Criar registro

`POST /history`

```json
{
  "materialId": 1,
  "fotografiaId": 1
}
```

O campo `fotografiaId` é opcional e pode ser nulo.

O usuário é identificado pelo token, não pelo corpo da requisição.

### Listar histórico

`GET /history`

Retorna os registros do usuário autenticado.

### Consultar registro

`GET /history/:id`

Consulta um registro pertencente ao usuário autenticado.

## 7. API Gateway

Base URL: `http://localhost:3004`

O Gateway encaminha as requisições para os serviços correspondentes.

| Método | Rota | Serviço de destino |
|---|---|---|
| POST | `/auth/register` | Access |
| POST | `/auth/login` | Access |
| GET | `/auth/me` | Access |
| GET | `/materials` | Materials |
| POST | `/photos` | Photos |
| GET | `/photos` | Photos |
| GET | `/photos/:id` | Photos |
| GET | `/photos/:id/file` | Photos |
| POST | `/history` | History |
| GET | `/history` | History |

As rotas que exigem autenticação devem receber o cabeçalho Authorization.

Observação: o Gateway disponibiliza atualmente a listagem de materiais. As operações administrativas de cadastro, atualização e desativação estão documentadas na Materials API, mas não devem ser consideradas rotas do Gateway.

## 8. GraphQL Service

Base URL: `http://localhost:3005`

Endpoint:

`POST /graphql`

A interface GraphiQL está habilitada na configuração atual.

### Consulta de materiais

```graphql
query {
  materiais
}
```

A consulta retorna uma lista de nomes:

```json
{
  "data": {
    "materiais": [
      "Garrafa PET"
    ]
  }
}
```

A lista acima é apenas um exemplo ilustrativo. Os resultados dependem dos dados cadastrados na Materials API.

## 9. Observações

- Os exemplos de corpos representam os DTOs identificados no código.
- Os formatos completos das respostas dependem da implementação dos respectivos serviços.
- Os identificadores devem corresponder a registros existentes.
- As rotas devem ser testadas no ambiente local antes de serem utilizadas em produção.
